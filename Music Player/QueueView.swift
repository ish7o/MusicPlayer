import SwiftUI

struct QueueView: View {
    @EnvironmentObject var player: PlayerManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                if player.queue.isEmpty && !player.repeatQueue {
                    ContentUnavailableView(
                        "Queue is empty",
                        systemImage: "text.line.first.and.arrowtriangle.forward",
                        description: Text("Swipe right on a song to add it to the queue.")
                    )
                }
                ForEach(player.queue) { song in
                    HStack(spacing: 12) {
                        AlbumArt(coverData: song.coverArt,
                                 size: CGSize(width: 36, height: 36))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.title).font(.body)
                            Text(song.artist).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { player.queue.remove(atOffsets: $0) }
                .onMove { player.queue.move(fromOffsets: $0, toOffset: $1) }
            }
            .navigationTitle("Queue (\(player.queue.count))")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Button {
                            player.toggleQueueRepeat()
                        } label: {
                            Image(systemName: player.repeatQueue ? "repeat" : "repeat")
                                .foregroundStyle(player.repeatQueue ? .accentColor : .gray)
                        }
                        Button("Clear") { player.queue.removeAll() }
                    }
                }
            }
        }
    }
}
