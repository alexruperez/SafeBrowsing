//
//  SafeBrowsingModels.swift
//  SafeBrowsing
//
//  Created by Alejandro Ruperez Hernando on 27/3/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import Foundation

public typealias SafeBrowsingHandler = (_ success: Bool, _ error: SafeBrowsingError?) -> Swift.Void

public enum SafeBrowsingError: Error, CustomDebugStringConvertible {
    case api(detail: ErrorDetail)
    case threat(matches: [ThreatMatch])
    case encoding(error: EncodingError)
    case unknown(error: Error?)

    public var debugDescription: String {
        switch self {
        case .api(detail: let error):
            return error.message
        case .threat(matches: let matches):
            return String(describing: matches)
        case .encoding(error: let error):
            return error.localizedDescription
        case .unknown(error: let error):
            return error?.localizedDescription ?? "Unknown error."
        }
    }
}

public enum ThreatType: String, Codable, Hashable {
    case unspecified = "THREAT_TYPE_UNSPECIFIED"
    case malware = "MALWARE"
    case socialEngineering = "SOCIAL_ENGINEERING"
    case unwantedSoftware = "UNWANTED_SOFTWARE"
    case potenciallyHarmfulApplication = "POTENTIALLY_HARMFUL_APPLICATION"
}

public enum PlatformType: String, Codable, Hashable {
    case unspecified = "PLATFORM_TYPE_UNSPECIFIED"
    case windows = "WINDOWS"
    case linux = "LINUX"
    case android = "ANDROID"
    case osx = "OSX"
    case ios = "IOS"
    case any = "ANY_PLATFORM"
    case all = "ALL_PLATFORMS"
    case chrome = "CHROME"
}

public enum ThreatEntryType: String, Codable, Hashable {
    case unspecified = "THREAT_ENTRY_TYPE_UNSPECIFIED"
    case url = "URL"
    case executable = "EXECUTABLE"
}

public struct ErrorDetail: Codable, Hashable {
    public let status: String
    public let message: String
    public let code: Int
}

public struct ThreatMatch: Codable, Equatable {
    public let threatType: ThreatType
    public let platformType: PlatformType
    public let threatEntryType: ThreatEntryType
    public let threat: ThreatEntry
    public let threatEntryMetadata: ThreatEntryMetadata?
    public let cacheDuration: String
}

public struct ThreatEntry: Codable, Equatable {
    public let hash: String?
    public let url: String?
    public let digest: String?
}

public struct ThreatEntryMetadata: Codable, Equatable {
    public let entries: [MetadataEntry]
}

public struct MetadataEntry: Codable, Hashable {
    public let key: String
    public let value: String
}

struct ThreatMatchesRequest: Codable, Equatable {
    let client: ClientInfo
    let threatInfo: ThreatInfo
}

struct ClientInfo: Codable, Hashable {
    let clientId: String
    let clientVersion: String
}

struct ThreatInfo: Codable, Equatable {
    let threatTypes: [ThreatType]
    let platformTypes: [PlatformType]
    let threatEntryTypes: [ThreatEntryType]
    let threatEntries: [ThreatEntry]
}

struct ErrorResponse: Codable, Hashable {
    let error: ErrorDetail
}

struct ThreatMatches: Codable, Equatable {
    let matches: [ThreatMatch]
}
