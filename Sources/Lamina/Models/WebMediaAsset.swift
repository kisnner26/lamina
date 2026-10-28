import Foundation

struct WebMediaAsset: Codable, Sendable {
    let localPath: String
    let title: String
    let creator: String
    let license: String
    let licenseURL: String
    let sourceURL: String
}
