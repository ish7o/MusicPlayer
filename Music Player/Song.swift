import Foundation

struct Song: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let filename: String
    let coverArt: Data?
    
    var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
}

extension Song: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, artist, filename, url, coverArt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        coverArt = try container.decodeIfPresent(Data.self, forKey: .coverArt)
        
        if let filename = try container.decodeIfPresent(String.self, forKey: .filename) {
            self.filename = filename
        } else {
            let oldUrl = try container.decode(URL.self, forKey: .url)
            self.filename = oldUrl.lastPathComponent
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(filename, forKey: .filename)
        try container.encodeIfPresent(coverArt, forKey: .coverArt)
    }
}
