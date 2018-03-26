//
//  UIApplication+SafeBrowsing.swift
//  SafeBrowsing
//
//  Created by Alex Rupérez on 26/3/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UIKit

public typealias SafeBrowsingHandler = (Bool, Error?) -> Swift.Void

public struct SafeBrowsing {

    public enum SafeBrowsingError: Error {
        case api(status: String?, message: String?, code: Int?)
    }

    public enum ThreatTypes: String {
        case unspecified = "THREAT_TYPE_UNSPECIFIED"
        case malware = "MALWARE"
        case socialEngineering = "SOCIAL_ENGINEERING"
        case unwantedSoftware = "UNWANTED_SOFTWARE"
        case potenciallyHarmfulApplication = "POTENTIALLY_HARMFUL_APPLICATION"
    }

    public enum PlatformTypes: String {
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

    public enum ThreatEntryTypes: String {
        case unspecified = "THREAT_ENTRY_TYPE_UNSPECIFIED"
        case url = "URL"
        case executable = "EXECUTABLE"
    }

    public static var apiKey: String?
    public static var clientId = Bundle.main.bundleIdentifier!
    public static var clientVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    public static var threatTypes = [ThreatTypes]()
    public static var platformTypes = [PlatformTypes]()
    public static var threatEntryTypes = [ThreatEntryTypes]()

    public static func isSafeSync(_ url: URL) -> Bool {
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        var safe = false
        isSafe(url) { success, error in
            safe = success
            dispatchSemaphore.signal()
        }
        dispatchSemaphore.wait()
        return safe
    }

    public static func isSafe(_ url: URL, completionHandler completion: @escaping SafeBrowsingHandler) {
        guard let apiKey = SafeBrowsing.apiKey,
            let apiURL = URL(string: "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=" + apiKey) else {
                completion(false, SafeBrowsingError.api(status: "API_KEY_REQUIRED", message: "Get your key from https://console.cloud.google.com/apis/credentials and set SafeBrowsing.apiKey = \"YOUR_API_KEY_HERE\".", code: 401))
                return
        }
        let threatTypes = SafeBrowsing.threatTypes.isEmpty ? [.unspecified] : SafeBrowsing.threatTypes
        let platformTypes = SafeBrowsing.platformTypes.isEmpty ? [.unspecified] : SafeBrowsing.platformTypes
        let threatEntryTypes = SafeBrowsing.threatEntryTypes.isEmpty ? [.url] : SafeBrowsing.threatEntryTypes
        let jsonObject = ["client" : ["clientId" : SafeBrowsing.clientId, "clientVersion" : SafeBrowsing.clientVersion], "threatInfo": ["threatTypes": threatTypes.map { $0.rawValue }, "platformTypes": platformTypes.map { $0.rawValue }, "threatEntryTypes": threatEntryTypes.map { $0.rawValue }, "threatEntries": ["url" : url.absoluteString]]]
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data else {
                    completion(false, error)
                    return
                }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable : Any]
                    if let errorObject = jsonObject?["error"] as? [AnyHashable : Any] {
                        completion(false, error ?? SafeBrowsingError.api(status: errorObject["status"] as? String, message: errorObject["message"] as? String, code: errorObject["code"] as? Int))
                    } else {
                        completion(jsonObject?.count == 0, error)
                    }
                } catch {
                    completion(false, error)
                }

            }).resume()
        } catch {
            completion(false, error)
        }
    }

    // The completion handler is called on the main queue.
    public static func safeOpen(_ url: URL, application: UIApplication = UIApplication.shared, options: [String : Any] = [:], completionHandler completion: SafeBrowsingHandler? = nil) {
        isSafe(url) { safe, error in
            DispatchQueue.main.async {
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
}

public extension UIApplication {

    public func isSafeSync(_ url: URL) -> Bool {
        return SafeBrowsing.isSafeSync(url)
    }

    public func isSafe(_ url: URL, completionHandler completion: @escaping SafeBrowsingHandler) {
        SafeBrowsing.isSafe(url, completionHandler: completion)
    }

    // The completion handler is called on the main queue.
    public func safeOpen(_ url: URL, options: [String : Any] = [:], completionHandler completion: @escaping SafeBrowsingHandler) {
        SafeBrowsing.safeOpen(url, application: self, options: options, completionHandler: completion)
    }

}
