//
//  DIDUtilities.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-21.
//

import Foundation

/// A namespace for a group of utilities related to decentralized identifiers (DIDs).
public enum DIDUtilities {

    /// Executes an async operation with a timeout.
    ///
    /// If the timeout elapses, the task is cancelled. Use `Task.checkCancellation()`. to check
    /// for cancellations.
    ///
    /// - Parameters:
    ///   - milliseconds: The time in milliseconds before the operation times out.
    ///   - operation: The async closure to execute.
    /// - Returns: The result of the operation if completed within time.
    ///
    /// - Throws: `CancellationError` if the task times out or is cancelled.
    public static func timed<T: Sendable>(
        milliseconds: UInt64,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                return try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
                throw TimeoutError.timeout
            }

            guard let result = try await group.next() else {
                group.cancelAll()
                throw TimeoutError.timeout
            }

            group.cancelAll()

            return result
        }
    }
}
