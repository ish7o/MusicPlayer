import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var player: PlayerManager

    var body: some View {
        VStack(spacing: 24) {
            // placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.gradient)
                .frame(width: 250, height: 250)
                .overlay(Image(systemName: "music.note").font(.system(size: 80)).foregroundStyle(.white))

            VStack {
                Text(player.currentSong.title).font(.title2).bold()
                Text(player.currentSong.artist).foregroundStyle(.secondary)
            }

            Slider(value: Binding(
                get: { player.progress },
                set: { player.seek(to: $0) }
            ))
            .padding(.horizontal)

            HStack(spacing: 40) {
                Button { player.previous() } label: {
                    Image(systemName: "backward.fill").font(.system(size: 32))
                }
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                }
                Button { player.next() } label: {
                    Image(systemName: "forward.fill").font(.system(size: 32))
                }
            }
            .foregroundStyle(.primary)
        }
        .padding()
    }
}
