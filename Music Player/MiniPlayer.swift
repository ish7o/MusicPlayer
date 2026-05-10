import SwiftUICore
import SwiftUI
struct MiniPlayer : View {
    @EnvironmentObject var player: PlayerManager
    @Binding var showPlayer: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            AlbumArt(coverData: player.coverArtData,
                     size: CGSize(width: 40, height: 40))
            VStack(alignment: .leading, spacing: 2) {
                if player.currentSong != nil {
                    Text(player.currentSong!.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(player.currentSong!.artist)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("No song selected")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button { player.previous() } label: {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                }
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                }
                Button { player.next() } label: {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
            }
            .foregroundStyle(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 8, y: -2)
        .padding(.horizontal, 8)
        .onTapGesture {
            showPlayer = true
        }
    }
}
