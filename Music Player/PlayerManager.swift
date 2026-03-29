import AVFoundation
import Combine

class PlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0
    @Published var currentTime: String = "0:00"
    @Published var duration: String = "0:00"

    let songs: [Song] = [
        Song(title: "Fake your death", artist: "My Chemical Romance", filename: "01 Fake Your Death.mp3"),
        Song(title: "Witch", artist: "My Chemical Romance", filename: "02 Witch.mp3"),
        Song(title: "Bike Thief", artist: "My Chemical Romance", filename: "03 Bike Thief.mp3"),
    ]

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var currentSong: Song { songs[currentIndex] }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
    
    func load(_ index: Int) {
        currentIndex = index
        guard let url = Bundle.main.url(forResource: songs[index].filename, withExtension: nil) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        duration = formatTime(player?.duration ?? 0)
        currentTime = "0:00"
        player?.delegate = self
        player?.prepareToPlay()
        startTimer()
    }
    
    override init() {
        super.init()
        load(0)
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
        play((currentIndex + 1) % songs.count)
    }

    func previous() {
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
