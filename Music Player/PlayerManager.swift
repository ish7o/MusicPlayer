import AVFoundation
import Combine

class PlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0
    @Published var currentTime: String = "0:00"
    @Published var duration: String = "0:00"
    @Published var coverArtData: Data?

    @Published var songs: [Song] = [] {
        didSet { saveLibrary() }
    }

    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var libraryURL: URL {
        get throws {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            return appSupport.appendingPathComponent("library.json")
        }
    }

    var currentSong: Song? { songs.isEmpty ? nil : songs[currentIndex] }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
    
    func load(_ index: Int) {
        guard index < songs.count else { return }
        currentIndex = index
        coverArtData = songs[index].coverArt
        player = try? AVAudioPlayer(contentsOf: songs[index].url)
        duration = formatTime(player?.duration ?? 0)
        currentTime = "0:00"
        player?.delegate = self
        player?.prepareToPlay()
        startTimer()
    }
    
    @MainActor
    func scanDocuments() async {
        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let files = try FileManager.default.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
            let onDiskFilenames = Set(files.map { $0.lastPathComponent })
            
            songs = songs.filter { song in
                let exists = onDiskFilenames.contains(song.filename)
                if !exists && currentIndex >= songs.count { currentIndex = 0 }
                return exists
            }
            
            let existingFilenames = Set(songs.map { $0.filename })
            let newAudioFiles = files.filter { url in
                ["mp3", "m4a", "wav", "flac", "ogg"].contains(url.pathExtension) &&
                !existingFilenames.contains(url.lastPathComponent)
            }
            
            var newSongs: [Song] = []
            for url in newAudioFiles {
                let metadata = await loadMetadata(url)
                newSongs.append(Song(id: UUID(), title: metadata.title, artist: metadata.artist, filename: url.lastPathComponent, coverArt: metadata.coverArt))
            }
            
            songs.append(contentsOf: newSongs)
        } catch {
            print("Error scanning Documents: \(error)")
        }
    }
    
    @MainActor
    func importFile(_ url: URL) async {
        do {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = url.lastPathComponent
            let dest = docs.appendingPathComponent(filename)
            
            if FileManager.default.fileExists(atPath: dest.path) { return }
            try FileManager.default.copyItem(at: url, to: dest)
            
            let metadata = await loadMetadata(dest)
            songs.append(Song(id: UUID(), title: metadata.title, artist: metadata.artist, filename: filename, coverArt: metadata.coverArt))
        } catch {
            print("Error importing file: \(error)")
        }
    }
    
    func loadMetadata(_ url: URL) async -> (title: String, artist: String, coverArt: Data?) {
        let asset = AVURLAsset(url: url)
        let metadata = try? await asset.load(.commonMetadata)
        
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var coverArt: Data?
    
        for item in metadata ?? [] {
            if item.commonKey == .commonKeyTitle,
               let value = try? await item.load(.stringValue) {
                title = value
            }
            if item.commonKey == .commonKeyArtist,
               let value = try? await item.load(.stringValue) {
                artist = value
            }
            if item.commonKey == .commonKeyArtwork,
               let data = try? await item.load(.dataValue) {
                coverArt = data
            }
        }
        
        return (title, artist, coverArt)
    }
    
    func saveLibrary() {
        do {
            let data = try JSONEncoder().encode(songs)
            try data.write(to: libraryURL)
        } catch {
            print("Error saving library: \(error)")
        }
    }
    
    func loadLibrary() {
        do {
            let data = try Data(contentsOf: libraryURL)
            songs = try JSONDecoder().decode([Song].self, from: data)
        } catch {
            songs = []
            print("Error loading library: \(error)")
        }
    }
    
    override init() {
        super.init()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
        loadLibrary()
        Task { await scanDocuments() }
    }
    
    func play(_ index: Int) {
        load(index)
        player?.play()
        isPlaying = true
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying = !isPlaying
    }

    func next() {
        guard !songs.isEmpty else { return }
        play((currentIndex + 1) % songs.count)
    }

    func previous() {
        guard !songs.isEmpty else { return }
        play((currentIndex - 1 + songs.count) % songs.count)
    }

    func seek(to value: Double) {
        guard let player else { return }
        player.currentTime = value * player.duration
        progress = value
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            self.progress = player.currentTime / player.duration
            self.currentTime = self.formatTime(player.currentTime)
            self.duration = self.formatTime(player.duration)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.next()
    }
}
