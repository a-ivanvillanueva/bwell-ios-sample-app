//
//  UserMessage.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 02-11-2026.
//

import Foundation

/// Builds what a person sees when something fails, for example:
/// "We couldn't save your profile. You appear to be offline. Check your connection and try again."
func userMessage(for error: Error, whileTrying action: String) -> String {
    let appError = AppError(error)
    return ["We couldn't \(action).", appError.errorDescription, appError.recoverySuggestion]
        .compactMap { $0 }
        .joined(separator: " ")
}
