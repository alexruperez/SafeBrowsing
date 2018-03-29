//
//  SafeBrowsingTests.swift
//  SafeBrowsingTests
//
//  Created by Alex Rupérez on 28/3/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import XCTest
@testable import SafeBrowsing

class SafeBrowsingTests: XCTestCase {
    
    func testThreatMatchesRequest() {
        SafeBrowsing.apiKey = "API_KEY"
        let threatTypes: [ThreatType] = [.malware, .socialEngineering, .unwantedSoftware, .potenciallyHarmfulApplication]
        let platformTypes: [PlatformType] = [.any]
        let threatEntryTypes: [ThreatEntryType] = [.url, .executable]
        let clientInfo = ClientInfo(clientId: "clientId", clientVersion: "clientVersion")
        let threatEntry = ThreatEntry(hash: nil, url: "http://google.com", digest: nil)
        let threatInfo = ThreatInfo(threatTypes: threatTypes, platformTypes: platformTypes, threatEntryTypes: threatEntryTypes, threatEntries: [threatEntry])
        let threatMatchesRequest = ThreatMatchesRequest(client: clientInfo, threatInfo: threatInfo)
        let request = try! SafeBrowsing.request(threatMatchesRequest)
        let decodedThreatMatchesRequest = try! JSONDecoder().decode(ThreatMatchesRequest.self, from: request.httpBody!)
        XCTAssertEqual(request.url?.absoluteString, "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=API_KEY")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(threatMatchesRequest, decodedThreatMatchesRequest)
    }

    func testThreatMatches() {
        let threatEntry = ThreatEntry(hash: nil, url: "http://google.com", digest: nil)
        let metadataEntry = MetadataEntry(key: "key", value: "value")
        let threatEntryMetadata = ThreatEntryMetadata(entries: [metadataEntry])
        let threatMatch = ThreatMatch(threatType: ThreatType.malware, platformType: PlatformType.any, threatEntryType: ThreatEntryType.url, threat: threatEntry, threatEntryMetadata: threatEntryMetadata, cacheDuration: "300s")
        let threatMatches = ThreatMatches(matches: [threatMatch])
        let encodedThreatMatches = try! JSONEncoder().encode(threatMatches)
        let decodedThreatMatches = try! JSONDecoder().decode(ThreatMatches.self, from: encodedThreatMatches)
        XCTAssertEqual(threatMatches, decodedThreatMatches)
    }

    func testErrorResponse() {
        let errorDetail = ErrorDetail(status: "status", message: "message", code: 0)
        let errorResponse = ErrorResponse(error: errorDetail)
        let encodedErrorResponse = try! JSONEncoder().encode(errorResponse)
        let decodedErrorResponse = try! JSONDecoder().decode(ErrorResponse.self, from: encodedErrorResponse)
        XCTAssertEqual(errorResponse, decodedErrorResponse)
    }

    func testSafeBrowsingAPIError() {
        let errorDetail = ErrorDetail(status: "status", message: "message", code: 0)
        let apiError = SafeBrowsingError.api(detail: errorDetail)
        XCTAssertEqual(apiError.debugDescription, "message")
    }

    func testSafeBrowsingThreatError() {
        let threatEntry = ThreatEntry(hash: nil, url: "http://google.com", digest: nil)
        let metadataEntry = MetadataEntry(key: "key", value: "value")
        let threatEntryMetadata = ThreatEntryMetadata(entries: [metadataEntry])
        let threatMatch = ThreatMatch(threatType: ThreatType.malware, platformType: PlatformType.any, threatEntryType: ThreatEntryType.url, threat: threatEntry, threatEntryMetadata: threatEntryMetadata, cacheDuration: "300s")
        let threatError = SafeBrowsingError.threat(matches: [threatMatch])
        XCTAssertEqual(threatError.debugDescription, String(describing: [threatMatch]))
    }

    func testSafeBrowsingEncodingError() {
        let error = EncodingError.invalidValue("value", EncodingError.Context(codingPath: [], debugDescription: "debugDescription"))
        let encodingError = SafeBrowsingError.encoding(error: error)
        XCTAssertEqual(encodingError.debugDescription, "The data couldn’t be written because it isn’t in the correct format.")
    }

    func testSafeBrowsingUnknownError() {
        let error = CocoaError(.featureUnsupported)
        let unknownError = SafeBrowsingError.unknown(error: error)
        XCTAssertEqual(unknownError.debugDescription, "The requested operation couldn’t be completed because the feature is not supported.")
    }

    func testSafeBrowsingDefaultError() {
        let defaultError = SafeBrowsingError.unknown(error: nil)
        XCTAssertEqual(defaultError.debugDescription, "Unknown error.")
    }

    func testSafeBrowsingAPIKeyMissingError() {
        do {
            _ = try UIApplication.shared.isSafe(URL(string: "http://google.com")!)
            XCTFail()
        } catch {
            XCTAssertEqual((error as! SafeBrowsingError).debugDescription, "Get your key from https://console.cloud.google.com/apis/credentials and set SafeBrowsing.apiKey = \"YOUR_API_KEY_HERE\".")
        }
    }
    
}
