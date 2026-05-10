import SwiftUICore
import SwiftUI
import UniformTypeIdentifiers
struct LibraryView: View {
    @EnvironmentObject var player: PlayerManager
    @State var showPlayer = false
    @State var showImporter = false
    @State var showQueue = false
    @State var searchText: String = ""
    var filteredSongs: [Song] {
        guard !searchText.isEmpty else {
            return player.songs
        }
        let q = searchText.lowercased()
        return player.songs.filter { $0.artist.lowercased().contains(q) || $0.title.lowercased().contains(q)}
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                List(filteredSongs.indices, id: \.self) { i in
                    let song = filteredSongs[i]
                    Button {
                        guard let index = player.songs.firstIndex(where: { $0.id == filteredSongs[i].id }) else { return }
                        player.play(index)
                        showPlayer = true
                    } label: {
                        HStack(spacing: 12) {
                            AlbumArt(coverData: song.coverArt,
                                     size: CGSize(width: 40, height: 40))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.body)
                                    .foregroundStyle(player.currentSong?.id == song.id && player.isPlaying ? .pink : .primary)
                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if player.currentSong?.id == song.id && player.isPlaying {
                                Image(systemName: "waveform")
                                    .foregroundStyle(.black)
                                    .symbolEffect(.variableColor)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            player.addToQueue(song)
                        } label: {
                            Label("Queue", systemImage: "text.line.first.and.arrowtriangle.forward")
                        }
                        .tint(.accentColor)
                    }
                }
                .searchable(text: $searchText, prompt: "Search for artists and songs...")
                .navigationTitle("Library")
                .toolbar {
                    Button { showImporter = true } label: {
                        Image(systemName: "plus")
                    }
                    Button { showQueue = true } label: {
                        Image(systemName: "list.number")
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
        .sheet(isPresented: $showQueue) {
            QueueView().environmentObject(player)
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
