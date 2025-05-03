//
//  Errors.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-02.
//

import Foundation

/// Represents errors related to Decentralized Identifiers (DIDs).
public enum DIDError: Error, LocalizedError, CustomStringConvertible {

    /// The decentralized identifier (DID) is invalid.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID).
    ///   - message: The message given of the error.
    ///   - cause: The cause of the error. Optional. Defaults to `nil`.
    case invalidDID(did: String, message: String, cause: Error? = nil)

    /// An unknown error.
    ///
    /// This is typically going to be a 400 error.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID).
    ///   - message: The message given of the error.
    ///   - status: The status code. Defaults to `400`.
    ///   - cause: The cause of the error. Optional. Defaults to `nil`.
    case unknown(did: String, message: String, status: Int = 400, cause: Error? = nil)

    public var errorDescription: String? {
        switch self {
            case let .invalidDID(did, message, _):
                return "DIDError: did-invalid (\(did)): \(message)"
            case let .unknown(did, message, _, _):
                return "DIDError: did-unknown-error (\(did)): \(message)"
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }

    /// HTTP-style status code for frameworks that require it.
    public var statusCode: Int {
        switch self {
            case .invalidDID:
                return 400
            case let .unknown(_, _, status, _):
                return status
        }
    }

    /// A unique error code string useful for clients or logs.
    public var code: String {
        switch self {
            case .invalidDID:
                return "did-invalid"
            case .unknown:
                return "did-unknown-error"
        }
    }

    /// The DID string that caused the error.
    public var did: String {
        switch self {
            case let .invalidDID(did, _, _),
                let .unknown(did, _, _, _):
                return did
        }
    }

    /// The original underlying cause, if any.
    public var cause: Error? {
        switch self {
            case let .invalidDID(_, _, cause),
                let .unknown(_, _, _, cause):
                return cause
        }
    }
}
