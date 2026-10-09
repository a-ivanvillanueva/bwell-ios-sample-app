//
//  Log.swift
//  bwell-swift-ios
//
// Central place for the app's loggers (replaces ad-hoc print statements).
//
//  Created by Ivan Villanueva on 09-10-2026.
//

import Foundation
import OSLog

/// Namespaced `Logger` instances, one per feature area.
///
/// Usage: `Log.sdk.info("SDK initialized")`
///
/// Notes:
/// - Dynamic values in the message (e.g. `\(error.localizedDescription)`) are
///   redacted as `<private>` in logs captured outside the debugger. That is the
///   safe default for an app that handles health data. Never mark health or
///   profile values `privacy: .public`.
/// - Prefer logging counts and states over whole objects.
/// - View logs in Xcode's console, or in Console.app by filtering on the subsystem.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "bwell-swift-ios"

    static let sdk = Logger(subsystem: subsystem, category: "sdk")
    static let keychain = Logger(subsystem: subsystem, category: "keychain")
    static let profile = Logger(subsystem: subsystem, category: "profile")
    static let connections = Logger(subsystem: subsystem, category: "connections")
    static let health = Logger(subsystem: subsystem, category: "health")
    static let ui = Logger(subsystem: subsystem, category: "ui")
}
