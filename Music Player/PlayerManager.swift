import AVFoundation
import Combine

class PlayerManager: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var progress: Double = 0

    let songs: [Song] = [
        Song(title: "Fake your death", artist: "My Chemical Romance", filename: "01 Fake Your Death.mp3"),
        Song(title: "Witch", artist: "My Chemical Romance", filename: "02 Witch.mp3"),
        Song(title: "Bike Thief", artist: "My Chemical Romance", filename: "03 Bike Thief.mp3"),
    ]

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var currentSong: Song { songs[currentIndex] }

    func play(index: Int) {
        currentIndex = index
        guard let url = Bundle.main.url(forResource: songs[index].filename, withExtension: nil) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
        isPlaying = true
        startTimer()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying { player.pause() } else { player.play() }
        isPlaying = !isPlaying
    }

    func next() {
        play(index: (currentIndex + 1) % songs.count)
    }

    func previous() {
        play(index: (currentIndex - 1 + songs.count) % songs.count)
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
        }
    }
}
