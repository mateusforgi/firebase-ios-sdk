// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription
import class Foundation.ProcessInfo

let firebaseVersion = "10.5.0"

let package = Package(
  name: "Firebase",
  platforms: [.iOS(.v11), .macOS(.v10_13), .tvOS(.v12), .watchOS(.v7)],
  products: [
    .library(
      name: "FirebaseAnalytics",
      targets: ["FirebaseAnalyticsTarget"]
    ),
    .library(
      name: "FirebaseInstallations",
      targets: ["FirebaseInstallations"]
    ),
  ],
  dependencies: [
    .package(
        name: "Promises",
        url: "https://github.com/google/promises.git",
        "2.1.0" ..< "3.0.0"
      ),
    .package(
      name: "GoogleAppMeasurement",
      url: "https://github.com/google/GoogleAppMeasurement.git",
      // Note that CI changes the version to the head of main for CI.
      // See scripts/setup_spm_tests.sh.
      .exact("10.4.0")
    ),
    .package(
      name: "GoogleUtilities",
      url: "https://github.com/google/GoogleUtilities.git",
      "7.10.0" ..< "8.0.0"
    ),
    .package(
      name: "nanopb",
      url: "https://github.com/firebase/nanopb.git",
      "2.30909.0" ..< "2.30910.0"
    ),
  ],
  targets: [
    .target(
       name: "Firebase",
       path: "CoreOnly/Sources",
       publicHeadersPath: "./"
     ),
    .target(
      name: "FirebaseCoreInternal",
      dependencies: [
        .product(name: "GULNSData", package: "GoogleUtilities"),
      ],
      path: "FirebaseCore/Internal/Sources"
    ),
    
    .target(
      name: "FirebaseCore",
      dependencies: [
        "Firebase",
        "FirebaseCoreInternal",
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
        .product(name: "GULLogger", package: "GoogleUtilities"),
      ],
      path: "FirebaseCore/Sources",
      publicHeadersPath: "Public",
      cSettings: [
        .headerSearchPath("../.."),
        .define("Firebase_VERSION", to: firebaseVersion),
        // TODO: - Add support for cflags cSetting so that we can set the -fno-autolink option
      ],
      linkerSettings: [
        .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS])),
        .linkedFramework("AppKit", .when(platforms: [.macOS])),
      ]
    ),
    .target(
      name: "FirebaseAnalyticsTarget",
      dependencies: [.target(name: "FirebaseAnalyticsWrapper")],
      path: "SwiftPM-PlatformExclude/FirebaseAnalyticsWrap"
    ),
    .target(
        name: "FirebaseInstallations",
        dependencies: [
          "FirebaseCore",
          .product(name: "FBLPromises", package: "Promises"),
          .product(name: "GULEnvironment", package: "GoogleUtilities"),
          .product(name: "GULUserDefaults", package: "GoogleUtilities"),
        ],
        path: "FirebaseInstallations/Source/Library",
        publicHeadersPath: "Public",
        cSettings: [
          .headerSearchPath("../../../"),
        ],
        linkerSettings: [
          .linkedFramework("Security"),
        ]
      ),

    .target(
      name: "FirebaseAnalyticsWrapper",
      dependencies: [
        .target(name: "FirebaseAnalytics"),
        .product(name: "GoogleAppMeasurement",
                 package: "GoogleAppMeasurement"),
        "FirebaseCore",
        "FirebaseInstallations",
        .product(name: "GULAppDelegateSwizzler", package: "GoogleUtilities"),
        .product(name: "GULMethodSwizzler", package: "GoogleUtilities"),
        .product(name: "GULNSData", package: "GoogleUtilities"),
        .product(name: "GULNetwork", package: "GoogleUtilities"),
        .product(name: "nanopb", package: "nanopb"),
      ],
      path: "FirebaseAnalyticsWrapper",
      linkerSettings: [
        .linkedLibrary("sqlite3"),
        .linkedLibrary("c++"),
        .linkedLibrary("z"),
        .linkedFramework("StoreKit"),
      ]
    ),
    .binaryTarget(
      name: "FirebaseAnalytics",
      url: "https://dl.google.com/firebase/ios/swiftpm/10.4.0/FirebaseAnalytics.zip",
      checksum: "d5098cd2d731104dddb11c39b2cbbd3aab11a604c528706a16ff0114abd8d53a"
    )
  ],
  cLanguageStandard: .c99,
  cxxLanguageStandard: CXXLanguageStandard.gnucxx14
)

