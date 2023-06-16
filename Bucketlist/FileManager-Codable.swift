//
//  FileManager-Codable.swift
//  Bucketlist
//
//  Created by Theós on 15/06/2023.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func readContent<T: Decodable>(of fileURL: URL) throws -> T {
        let data = try Data(contentsOf: fileURL)
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
    }
    
    func writeContents<T: Encodable>(of item: T, to fileURL: URL) throws {
        let encoded = try JSONEncoder().encode(item)
        try encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }
}
