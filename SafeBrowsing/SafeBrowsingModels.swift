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

public enum ThreatType: String, Codable {
    case unspecified = "THREAT_TYPE_UNSPECIFIED"
    case malware = "MALWARE"
    case socialEngineering = "SOCIAL_ENGINEERING"
    case unwantedSoftware = "UNWANTED_SOFTWARE"
    case potenciallyHarmfulApplication = "POTENTIALLY_HARMFUL_APPLICATION"
}

public enum PlatformType: String, Codable {
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

public enum ThreatEntryType: String, Codable {
    case unspecified = "THREAT_ENTRY_TYPE_UNSPECIFIED"
    case url = "URL"
    case executable = "EXECUTABLE"
}

public struct ErrorDetail: Codable, Equatable {
    public let status: String
    public let message: String
    public let code: Int

    public static func ==(lhs: ErrorDetail, rhs: ErrorDetail) -> Bool {
        return lhs.status == rhs.status &&
            lhs.message == rhs.message &&
            lhs.code == rhs.code
    }
}

public struct ThreatMatch: Codable, Equatable {
    public let threatType: ThreatType
    public let platformType: PlatformType
    public let threatEntryType: ThreatEntryType
    public let threat: ThreatEntry
    public let threatEntryMetadata: ThreatEntryMetadata?
    public let cacheDuration: String

    public static func ==(lhs: ThreatMatch, rhs: ThreatMatch) -> Bool {
        return lhs.threatType == rhs.threatType &&
            lhs.platformType == rhs.platformType &&
            lhs.threatEntryType == rhs.threatEntryType &&
            lhs.threat == rhs.threat &&
            lhs.threatEntryMetadata == rhs.threatEntryMetadata &&
            lhs.cacheDuration == rhs.cacheDuration
    }
}

public struct ThreatEntry: Codable, Equatable {
    public let hash: String?
    public let url: String?
    public let digest: String?

    public static func ==(lhs: ThreatEntry, rhs: ThreatEntry) -> Bool {
        return lhs.hash == rhs.hash &&
            lhs.url == rhs.url &&
            lhs.digest == rhs.digest
    }
}

public struct ThreatEntryMetadata: Codable, Equatable {
    public let entries: [MetadataEntry]

    public static func ==(lhs: ThreatEntryMetadata, rhs: ThreatEntryMetadata) -> Bool {
        return lhs.entries == rhs.entries
    }
}

public struct MetadataEntry: Codable, Equatable {
    public let key: String
    public let value: String

    public static func ==(lhs: MetadataEntry, rhs: MetadataEntry) -> Bool {
        return lhs.key == rhs.key &&
            lhs.key == rhs.key
    }
}

struct ThreatMatchesRequest: Codable, Equatable {
    let client: ClientInfo
    let threatInfo: ThreatInfo

    static func ==(lhs: ThreatMatchesRequest, rhs: ThreatMatchesRequest) -> Bool {
        return lhs.client == rhs.client &&
            lhs.threatInfo == rhs.threatInfo
    }
}

struct ClientInfo: Codable, Equatable {
    let clientId: String
    let clientVersion: String

    static func ==(lhs: ClientInfo, rhs: ClientInfo) -> Bool {
        return lhs.clientId == rhs.clientId &&
            lhs.clientVersion == rhs.clientVersion
    }
}

struct ThreatInfo: Codable, Equatable {
    let threatTypes: [ThreatType]
    let platformTypes: [PlatformType]
    let threatEntryTypes: [ThreatEntryType]
    let threatEntries: [ThreatEntry]

    static func ==(lhs: ThreatInfo, rhs: ThreatInfo) -> Bool {
        return lhs.threatTypes == rhs.threatTypes &&
            lhs.platformTypes == rhs.platformTypes &&
            lhs.threatEntryTypes == rhs.threatEntryTypes &&
            lhs.threatEntries == rhs.threatEntries
    }
}

struct ErrorResponse: Codable, Equatable {
    let error: ErrorDetail

    static func ==(lhs: ErrorResponse, rhs: ErrorResponse) -> Bool {
        return lhs.error == rhs.error
    }
}

struct ThreatMatches: Codable, Equatable {
    let matches: [ThreatMatch]

    static func ==(lhs: ThreatMatches, rhs: ThreatMatches) -> Bool {
        return lhs.matches == rhs.matches
    }
}
