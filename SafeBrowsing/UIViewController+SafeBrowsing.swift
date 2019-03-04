//
//  UIViewController+SafeBrowsing.swift
//  SafeBrowsing
//
//  Created by Alex Rupérez on 4/3/19.
//  Copyright © 2019 alexruperez. All rights reserved.
//

import UIKit
import SafariServices

public extension UIViewController {

    // The completion handler is called on the main queue.
    public func safeOpenInSafariViewController(_ url: URL, application: UIApplication = .shared, animated: Bool = true, completion: SafeBrowsingHandler? = nil) {
        SafeBrowsing.safeOpen(url, application: application, options: [.universalLinksOnly: true]) { success, error in
            if !success, error == nil {
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: animated) {
                    completion?(true, error)
                }
            } else {
                completion?(success, error)
            }
        }
    }

}
