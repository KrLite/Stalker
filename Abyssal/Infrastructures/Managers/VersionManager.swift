//
//  VersionManager.swift
//  Abyssal
//
//  Created by KrLite on 2024/6/24.
//

import Foundation

struct Version: Codable {
    var components: [UInt]
    
    var string: String {
        components
            .map { String($0) }
            .joined(separator: ".")
    }
    
    static var empty: Version = .init(components: [])
    static var app: Version {
        .init(from: Bundle.main.appVersion) ?? .empty
    }
    static var remote: Version {
        VersionManager.remoteVersion
    }
    
    static var hasUpdate: Bool {
        app < remote
    }
    
    init(components: [UInt]) {
        self.components = components
    }
    
    init?(from: String) {
        let parts = from.replacing(/[^\d\.]/, with: "").split(separator: ".")
        let components = parts.compactMap({ UInt($0) })
        
        if components.isEmpty {
            return nil
        } else {
            self.components = components
        }
    }
}

extension Version: Comparable {
    func raisedSum(decimal: UInt) -> Double {
        let count = components.count
        var sum: Double = 0
        
        for (index, component) in self.components.enumerated() {
            let power = count - index
            sum += Double(component) * pow(10, Double(power))
        }
        
        return sum
    }
    
    static func <(lhs: Version, rhs: Version) -> Bool {
        guard lhs != rhs else { return false }
        
        let count = UInt(max(lhs.components.count, rhs.components.count))
        return lhs.raisedSum(decimal: count) < rhs.raisedSum(decimal: count)
    }
}

struct VersionManager {
    fileprivate static var remoteVersion: Version = .app
    
    private static let task = URLSession.shared.dataTask(with: .releaseTags) { (data, response, error) in
        print(data, response, error)
        guard let data else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                let tags = json
                    .compactMap { element in
                        element["name"] as? String
                    }
                    .compactMap { Version(from: $0) }
                    .sorted(by: >)
                
                if let remote = tags.first, remote > .app {
                    VersionManager.remoteVersion = remote
                    print("Fetched latest version: \(remote)")
                } else {
                    print("No newer version available.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func fetchLatest() {
        task.cancel()
        print("Started fetching latest version...")
        task.resume()
    }
}
