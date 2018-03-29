# SafeBrowsing
### Protect your users against malware and phishing threats using Google Safe Browsing

![SafeBrowsing](https://github.com/alexruperez/SafeBrowsing/raw/master/Logo.jpg)

[![Twitter](https://img.shields.io/badge/contact-@alexruperez-0FABFF.svg?style=flat)](http://twitter.com/alexruperez)
[![Version](https://img.shields.io/cocoapods/v/SafeBrowsing.svg?style=flat)](http://cocoapods.org/pods/SafeBrowsing)
[![License](https://img.shields.io/cocoapods/l/SafeBrowsing.svg?style=flat)](http://cocoapods.org/pods/SafeBrowsing)
[![Platform](https://img.shields.io/cocoapods/p/SafeBrowsing.svg?style=flat)](http://cocoapods.org/pods/SafeBrowsing)
[![Swift](https://img.shields.io/badge/Swift-4-orange.svg?style=flat)](https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Build Status](https://travis-ci.org/alexruperez/SafeBrowsing.svg?branch=master)](https://travis-ci.org/alexruperez/SafeBrowsing)

## 🌟 Features

- [x] Check multiple URLs asynchronously
- [x] Check single URL asynchronously
- [x] Check single URL synchronously
- [x] Open URL in Safari only if it's safe
- [x] UIApplication extension

## 📲 Installation

SafeBrowsing is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SafeBrowsing'
```

#### Or you can install it with [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "alexruperez/SafeBrowsing"
```

#### Or install it with [Swift Package Manager](https://swift.org/package-manager/):

```swift
dependencies: [
    .package(url: "https://github.com/alexruperez/SafeBrowsing.git", from: "0.1.0")
]
```

## 🛠 Configuration

### Required configuration

Just [enable Google Safe Browsing API](https://console.developers.google.com/apis/api/safebrowsing.googleapis.com/overview) and [get your API key](https://console.cloud.google.com/apis/credentials).

```swift
SafeBrowsing.apiKey = "YOUR_API_KEY_HERE"
```

##### Advanced optional configuration

You can easily customize [threat types](https://developers.google.com/safe-browsing/v4/reference/rest/v4/ThreatType), [platform types](https://developers.google.com/safe-browsing/v4/reference/rest/v4/PlatformType) or [threat entry types](https://developers.google.com/safe-browsing/v4/reference/rest/v4/ThreatEntryType).

```swift
SafeBrowsing.clientId = "YOUR_CLIENT_ID" // By default your bundle identifier.
SafeBrowsing.clientVersion = "YOUR_CLIENT_VERSION" // By default your bundle short version.
SafeBrowsing.threatTypes = [.malware, .socialEngineering, .unwantedSoftware, .potenciallyHarmfulApplication]
SafeBrowsing.platformTypes = [.any]
SafeBrowsing.threatEntryTypes = [.url, .executable]
```

## 🐒 Usage

#### Check multiple URLs asynchronously:

```swift
SafeBrowsing.isSafe([anURL, anotherURL]) { isSafe, error in
    // Your code here
}
```

#### Check single URL asynchronously:

```swift
SafeBrowsing.isSafe(anURL) { isSafe, error in
    // Your code here
}
```

#### Check single URL synchronously:

###### **Caution**: Don't call it in main thread

```swift
if SafeBrowsing.isSafe(anURL) {
    // Your code here
}
```

#### Open URL in Safari only if it's safe:

```swift
SafeBrowsing.safeOpen(anURL) { opened, error in
    // Your code here
}
```

### UIApplication extension

Yes, you can use SafeBrowsing with UIApplication, just like [open(_:options:completionHandler:)](https://developer.apple.com/documentation/uikit/uiapplication/1648685-open) method works.

You also have all isSafe(_:) methods available with this extension.

```swift
UIApplication.shared.safeOpen(anURL) { opened, error in
    // Your code here
}
```

### Testing Google Safe Browsing

```swift
let testingURL = URL(string: "http://malware.testing.google.test/testing/malware/")!
SafeBrowsing.isSafe(testingURL) { isSafe, error in
    print(String(describing: error))
}
```

## ❤️ Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## 👨‍💻 Authors

[alexruperez](https://github.com/alexruperez), contact@alexruperez.com

## 👮‍♂️ License

SafeBrowsing is available under the MIT license. See the LICENSE file for more info.