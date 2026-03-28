import SwiftUI

struct ContentView: View {
    @StateObject var player = PlayerManager()

    var body: some View {
        PlayerView().environmentObject(player)
    }
}
