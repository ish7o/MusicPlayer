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
                if player.songs.isEmpty {
                    ContentUnavailableView(
                        "No Music Yet",
                        systemImage: "music.note.list",
                        description: Text("Tap + to import songs from Files, or refresh to scan.")
                    )
                }
                List(filteredSongs.indices, id: \.self) { i in
                    let song = filteredSongs[i]
                    Button {
                        guard let index = player.songs.firstIndex(where: { $0.id == filteredSongs[i].id }) else { return }
                        player.play(index)
                        showPlayer = true
                    } label: {
                        HStack(spacing: 12) {
                            AlbumArt(coverData: song.coverArt,
                                     size: CGSize(width: 44, height: 44))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.body)
                                    .fontWeight(player.currentSong?.id == song.id && player.isPlaying ? .semibold : .regular)
                                    .foregroundStyle(player.currentSong?.id == song.id && player.isPlaying ? .purple : .primary)
                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if player.currentSong?.id == song.id && player.isPlaying {
                                Image(systemName: "waveform")
                                    .foregroundStyle(.purple)
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
                            Label("Queue", systemImage: "forward.fill")
                        }
                        .tint(.purple)
                    }
                }
                .searchable(text: $searchText, prompt: "Search songs or artists...")
                .navigationTitle("Library")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 2) {
                            Button { showImporter = true } label: {
                                Image(systemName: "plus")
                            }
                            Button { showQueue = true } label: {
                                Image(systemName: "line.3.horizontal")
                            }
                            Button { Task { await player.scanDocuments() } } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
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
