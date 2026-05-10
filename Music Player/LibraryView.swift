import SwiftUICore
import SwiftUI
struct LibraryView: View {
    @EnvironmentObject var player: PlayerManager
    @State var showPlayer = false

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                List(player.songs.indices, id: \.self) { i in
                    let song = player.songs[i]
                    Button {
                        player.play(i)
                        showPlayer = true
                    } label: {
                        HStack(spacing: 12) {
                            AlbumArt(coverData: song.coverArt,
                                     size: CGSize(width: 40, height: 40))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.body)
                                    .foregroundStyle(player.currentIndex == i && player.isPlaying ? .pink : .primary)
                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if player.currentIndex == i && player.isPlaying {
                                Image(systemName: "waveform")
                                    .foregroundStyle(.black)
                                    .symbolEffect(.variableColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Library")
                .toolbar {
                    Button { Task { await player.scanDocuments() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 72) }
            MiniPlayer(showPlayer: $showPlayer).environmentObject(player)
        }.sheet(isPresented: $showPlayer) {
            PlayerView().environmentObject(player)
        }
    }
}
