import PackageDescription

let package = Package(
  name: "SafeBrowsing",
  products: [
    .library(name: "SafeBrowsing", targets: ["SafeBrowsing"])
  ],
  targets: [
    .target(name: "SafeBrowsing"),
    .testTarget(name: "SafeBrowsingTests", dependencies: ["SafeBrowsing"])
  ]
)
