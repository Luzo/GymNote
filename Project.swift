import ProjectDescription

public enum Feature: CaseIterable {
  case app
  case newRecord

  var name: String {
    switch self {
    case .app:
      return "App"

    case .newRecord:
      return "NewRecord"
    }
  }

  var dependencies: [TargetDependency] {
    switch self {
    case .app:
      return [
        Domain.exercise.targetDependency,
        Feature.newRecord.targetDependency,
        Package.casePaths.package,
        Package.composableArchitecture.package,
        Package.dependencies.package,
        Service.targetDependency,
      ]

    case .newRecord:
      return [
        Domain.exercise.targetDependency,
        Package.casePaths.package,
        Package.composableArchitecture.package,
        Package.dependencies.package,
        Service.targetDependency,
        Utils.targetDependency,
      ]
    }
  }

  public var targetDependency: TargetDependency {
    .target(name: name)
  }

  public var target: Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "lubos.lehota.GymNote.\(name)",
      sources: ["GymNote/Sources/Feature/\(name)/**"],
      dependencies: dependencies
    )
  }
}

public enum Domain: CaseIterable {
  case exercise

  var name: String {
    switch self {
    case .exercise:
      return "Exercise"
    }
  }

  var dependencies: [TargetDependency] {
    switch self {
    case .exercise:
      return [
        Utils.targetDependency,
      ]
    }
  }

  public var targetDependency: TargetDependency {
    .target(name: name)
  }

  public var target: Target {
    switch self {
    case .exercise:
        return .target(
          name: name,
          destinations: .iOS,
          product: .framework,
          bundleId: "lubos.lehota.GymNote.\(name)",
          sources: ["GymNote/Sources/Domain/\(name)/**"],
          dependencies: dependencies
        )
    }
  }
}

public enum Utils: CaseIterable {
  static var name: String {
    return "Utils"
  }

  public static var targetDependency: TargetDependency {
    .target(name: name)
  }

  public static var target: Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "lubos.lehota.GymNote.\(name)",
      sources: ["GymNote/Sources/\(name)/**"],
      dependencies: []
    )
  }
}

public enum Service: CaseIterable {
  static var name: String {
    return "Service"
  }

  public static var targetDependency: TargetDependency {
    .target(name: name)
  }

  public static var target: Target {
    .target(
      name: name,
      destinations: .iOS,
      product: .framework,
      bundleId: "lubos.lehota.GymNote.\(name)",
      sources: ["GymNote/Sources/\(name)/**"],
      dependencies: [
        Domain.exercise.targetDependency,
        Package.dependencies.package,
      ]
    )
  }
}

public enum Package: CaseIterable {
  case casePaths
  case composableArchitecture
  case dependencies

  var name: String {
    switch self {
    case .casePaths:
      return "CasePaths"

    case .composableArchitecture:
      return "ComposableArchitecture"

    case .dependencies:
       return "Dependencies"
    }
  }

  var package: TargetDependency {
    .package(product: name)
  }
}

let project = Project(
  name: "GymNote",
  packages: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.17.0")
  ],
  settings: .settings(
    base: [:],
    configurations: [
      .debug(name: "Debug", xcconfig: .relativeToRoot("GymNote/Configurations/Debug.xcconfig")),
      .release(name: "Release", xcconfig: .relativeToRoot("GymNote/Configurations/Release.xcconfig")),
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
      sources: [
        "GymNote/Sources/App/**"
      ],
      resources: [
        "GymNote/Resources/**"
      ],
      dependencies: [
        Package.composableArchitecture.package,
      ] +
      Feature.allCases.map {
        .target(name: $0.name)
      }
    ),
    .target(
      name: "GymNoteTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "lubos.lehota.GymNoteTests",
      infoPlist: .default,
      sources: ["GymNoteTests/**"],
      resources: [],
      dependencies: [
        .target(name: "GymNote")
      ]
    ),
    Utils.target,
    Service.target
  ]
  + Target.featureTargets()
  + Target.domainTargets()
)

extension Target {
  public static func featureTargets() -> [Target] {
    Feature.allCases.map(\.target)
  }

  public static func domainTargets() -> [Target] {
    Domain.allCases.map(\.target)
  }
}
