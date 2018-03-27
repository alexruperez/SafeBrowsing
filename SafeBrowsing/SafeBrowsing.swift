//
//  SafeBrowsing.swift
//  SafeBrowsing
//
//  Created by Alex Rupérez on 26/3/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UIKit

public struct SafeBrowsing {

    public static var apiKey: String?
    public static var clientId = Bundle.main.bundleIdentifier ?? "com.alexruperez.SafeBrowsing"
    public static var clientVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    public static var threatTypes: [ThreatType] = [.malware, .socialEngineering, .unwantedSoftware, .potenciallyHarmfulApplication]
    public static var platformTypes: [PlatformType] = [.any]
    public static var threatEntryTypes: [ThreatEntryType] = [.url, .executable]

    public static func isSafe(_ urls: [URL], urlSession: URLSession = .shared, completionHandler completion: @escaping SafeBrowsingHandler) {
        let clientInfo = ClientInfo(clientId: SafeBrowsing.clientId, clientVersion: SafeBrowsing.clientVersion)
        let threatEntries = urls.map { ThreatEntry(hash: nil, url: $0.absoluteString, digest: nil) }
        let threatInfo = ThreatInfo(threatTypes: SafeBrowsing.threatTypes, platformTypes: SafeBrowsing.platformTypes, threatEntryTypes: SafeBrowsing.threatEntryTypes, threatEntries: threatEntries)
        let request = ThreatMatchesRequest(client: clientInfo, threatInfo: threatInfo)
        isSafe(request, urlSession: urlSession, completionHandler: completion)
    }

    public static func isSafe(_ url: URL, urlSession: URLSession = .shared, completionHandler completion: @escaping SafeBrowsingHandler) {
        isSafe([url], urlSession: urlSession, completionHandler: completion)
    }

    public static func isSafe(_ url: URL, urlSession: URLSession = .shared, dispatchSemaphore: DispatchSemaphore = DispatchSemaphore(value: 0)) throws -> Bool {
        var safe = false
        var safeBrowsingError: SafeBrowsingError?
        isSafe(url, urlSession: urlSession) { success, error in
            safe = success
            safeBrowsingError = error
            dispatchSemaphore.signal()
        }
        dispatchSemaphore.wait()
        if let error = safeBrowsingError {
            throw error
        }
        return safe
    }

    public static func safeOpen(_ url: URL, application: UIApplication = .shared, urlSession: URLSession = .shared, dispatchQueue: DispatchQueue = .main, options: [String : Any] = [:], completionHandler completion: SafeBrowsingHandler? = nil) {
        isSafe(url, urlSession: urlSession) { safe, error in
            dispatchQueue.async {
                guard safe else {
                    completion?(safe, error)
                    return
                }
                if #available(iOS 10.0, *) {
                    application.open(url, options: options, completionHandler: { success in
                        completion?(success, error)
                    })
                } else {
                    completion?(application.openURL(url), error)
                }
            }
        }
    }

    static func isSafe(_ threatMatchesRequest: ThreatMatchesRequest, urlSession: URLSession = .shared, completionHandler completion: @escaping SafeBrowsingHandler) {
        do {
            let urlRequest = try request(threatMatchesRequest)
            let dataTask = task(urlRequest, urlSession: urlSession, completion: completion)
            dataTask.resume()
        } catch let error as SafeBrowsingError {
            completion(false, error)
        } catch {
            completion(false, .unknown(error: error))
        }
    }

    static func request(_ threatMatchesRequest: ThreatMatchesRequest, jsonEncoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        guard let apiKey = SafeBrowsing.apiKey,
            let apiURL = URL(string: "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=" + apiKey) else {
                let errorDetail = ErrorDetail(status: "API_KEY_REQUIRED", message: "Get your key from https://console.cloud.google.com/apis/credentials and set SafeBrowsing.apiKey = \"YOUR_API_KEY_HERE\".", code: 401)
                throw SafeBrowsingError.api(detail: errorDetail)
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try jsonEncoder.encode(threatMatchesRequest)
            return request
        } catch let error as EncodingError {
            throw SafeBrowsingError.encoding(error: error)
        } catch {
            throw SafeBrowsingError.unknown(error: error)
        }
    }

    static func task(_ request: URLRequest, urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = JSONDecoder(), completion: @escaping SafeBrowsingHandler) -> URLSessionDataTask {
        return urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else {
                completion(false, .unknown(error: error))
                return
            }
            if let errorResponse = try? jsonDecoder.decode(ErrorResponse.self, from: data) {
                completion(false, .api(detail: errorResponse.error))
            } else if let threats = try? jsonDecoder.decode(ThreatMatches.self, from: data) {
                completion(false, .threat(matches: threats.matches))
            } else {
                completion(true, nil)
            }
        })
    }

}
