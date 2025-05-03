import ProjectDescription

let project = Project(
    name: "GymNote",
    packages: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.17.0")
    ],
    settings: .settings(
      base: [:],
      configurations: [
        .debug(name: "Debug", xcconfig: .relativeToRoot("GymNote/Configurations/Debug.xcconfig")),
        .release(name: "Release", xcconfig: .relativeToRoot("GymNote/Configurations/Release.xcconfig"))
      ]
    ),
    targets: [
        .target(
            name: "GymNote",
            destinations: .iOS,
            product: .app,
            bundleId: "lubos.lehota.GymNote",
            infoPlist: .file(
              path: "GymNote/Info.plist"
            ),
            sources: ["GymNote/Sources/**"],
            resources: [
            "GymNote/Resources/**"
            ],
            dependencies: [
              .package(product: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "GymNoteTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "lubos.lehota.GymNoteTests",
            infoPlist: .default,
            sources: ["GymNoteTests/**"],
            resources: [],
            dependencies: [.target(name: "GymNote")]
        ),
    ]
)
