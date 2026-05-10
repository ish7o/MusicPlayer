import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: PlayerManager
    @State private var dragProgress: Double = 0

    var body: some View {
        ZStack {
            if let coverData = player.coverArtData,
               let uiImage = UIImage(data: coverData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .blur(radius: 30, opaque: true)
                    .overlay(.black.opacity(0.6))
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack(spacing: 20) {
                AlbumArt(coverData: player.coverArtData,
                         size: CGSize(width: 260, height: 260))

                VStack(spacing: 4) {
                    Text(player.currentSong?.title ?? "")
                        .font(.title2).bold()
                    Text(player.currentSong?.artist ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    HStack {
                        Text(player.currentTime)
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(player.duration)
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $dragProgress) { editing in
                        if editing {
                            dragProgress = player.progress
                        } else {
                            player.seek(to: dragProgress)
                        }
                    }
                    .tint(.purple)
                }

                HStack(spacing: 48) {
                    Button { player.previous() } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 28))
                    }
                    Button { player.togglePlayPause() } label: {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 72))
                    }
                    Button { player.next() } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 28))
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
    }
}
