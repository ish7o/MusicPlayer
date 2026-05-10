import SwiftUICore
import SwiftUI
import UniformTypeIdentifiers
struct LibraryView: View {
    @EnvironmentObject var player: PlayerManager
    @State var showPlayer = false
    @State var showImporter = false

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
                    Button { showImporter = true } label: {
                        Image(systemName: "plus")
                    }
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
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                guard !urls.isEmpty else { return }
                Task {
                    for url in urls {
                        await player.importFile(url)
                    }
                }
            case .failure(let error):
                print("Import error: \(error)")
            }
        }
    }
}
