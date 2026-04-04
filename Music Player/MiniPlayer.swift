import SwiftUICore
import SwiftUI
struct MiniPlayer : View {
    @EnvironmentObject var player: PlayerManager
    @Binding var showPlayer: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.gradient)
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "music.note").foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                Text(player.currentSong?.title ?? "")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(player.currentSong?.artist ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 2)
            
            Spacer()
            
            Button { player.previous() } label: {
                Image(systemName: "backward.fill")
                    .font(.title3)
                    .foregroundColor(.black)
            }
            Button { player.togglePlayPause() } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
            }
            Button { player.next() } label: {
                Image(systemName: "forward.fill")
                    .font(.title3)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            showPlayer = true
        }
    }
}
