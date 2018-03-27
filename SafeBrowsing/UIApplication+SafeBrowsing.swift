//
//  UIApplication+SafeBrowsing.swift
//  SafeBrowsing
//
//  Created by Alex Rupérez on 26/3/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UIKit

public extension UIApplication {

    public func isSafe(_ urls: [URL], completionHandler completion: @escaping SafeBrowsingHandler) {
        SafeBrowsing.isSafe(urls, completionHandler: completion)
    }

    public func isSafe(_ url: URL, completionHandler completion: @escaping SafeBrowsingHandler) {
        SafeBrowsing.isSafe(url, completionHandler: completion)
    }

    public func isSafe(_ url: URL) throws -> Bool {
        return try SafeBrowsing.isSafe(url)
    }

    // The completion handler is called on the main queue.
    public func safeOpen(_ url: URL, options: [String : Any] = [:], completionHandler completion: @escaping SafeBrowsingHandler) {
        SafeBrowsing.safeOpen(url, application: self, options: options, completionHandler: completion)
    }

}
