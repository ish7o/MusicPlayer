import SwiftUI

struct AlbumArt: View {
    let coverData: Data?
    let size: CGSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: size.width * 0.08)
            .fill(
                LinearGradient(colors: [.purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .frame(width: size.width, height: size.height)
            .overlay {
                if let coverData, let uiImage = UIImage(data: coverData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: size.width * 0.08))
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: size.width * 0.32))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
    }
}
