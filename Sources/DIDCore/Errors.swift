//
//  Errors.swift
//  DIDCore
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

/// Errors that can occur while validating or constructing a DID.
public enum DIDValidatorError: Error, LocalizedError, CustomStringConvertible {

    /// The string is an invalid DID.
    case invalidDID

    /// The decentralized identifier (DID) relative to the URI is invalid.
    ///
    /// - Parameter did: The raw DID value.
    case invalidDIDRelativeURI(did: String)

    /// The length of the decentralized identifier (DID) is too long.
    ///
    /// There's a maximum limit of 2,048 characters.
    case tooLong

    /// Encoding the `String` object failed.
    case encodingFailed

    /// The string of the decentralized identifier (DID) is too large of a byte size.
    ///
    /// The maximum size is 2,048 bytes.
    case exceedsMaximumSize

    /// The `did` prefix is missing.
    case missingPrefix

    /// There is a missing `:` after the `did` prefix.
    case missingColonAfterPrefix

    /// There is no method name.
    case emptyMethodName

    /// This method name has not been blessed in the AT Protocol.
    ///
    /// - Parameter unblessedMethodName: The unblessed method name.
    case notABlessedMethodName(unblessedMethodName: String)

    /// The identifier portion of the decentralized identifier (DID) is empty.
    case emptyIdentifier

    /// An invalid character in the method portion has been found.
    ///
    /// - Parameters:
    ///   - position: The position of the invalid character, relative to the identifier.
    ///   - character: The invalid character itself.
    case invalidMethodCharacter(position: Int, character: Character)

    /// An invalid character has been found in the identifier.
    ///
    /// - Parameters:
    ///   - position: The position of the invalid character, relative to the identifier.
    ///   - character: The invalid character itself.
    case disallowedCharacter(position: Int, character: Character)

    /// The percentage encoding in the identifier is invalid.
    ///
    /// - Parameter position: The position of the percentage sign, relative to the identifier.
    case invalidPercentEncoding(position: Int)

    /// A trailing colon has been found in the decentralized identifier (DID).
    case trailingColonNotAllowed

    /// The URL of the `did:web` decentralized identifier (DID) is invalid.
    ///
    /// - Parameter url: The invalid URL.
    case invalidURL(url: String)

    /// The URL of the `did:web` contains a port number, even though the URL is not "localhost."
    case urlHasPortNumberWithoutLocalhost

    public var errorDescription: String? {
        switch self {
            case .invalidDID:
                return "DID is invalid."
            case .invalidDIDRelativeURI(let did):
                return "DID '\(did)' relative URI is invalid."
            case .tooLong:
                return "DID is too long. There's a maximum limit of 2,048 characters."
            case .encodingFailed:
                return "DID failed to be encoded into a Data object."
            case .exceedsMaximumSize:
                return "DID is too large of a byte size. The maximum size is 2,048 bytes."
            case .missingPrefix:
                return "DID requires \'did\' prefix."
            case .missingColonAfterPrefix:
                return "Missing colon after the \'did\' prefix."
            case .emptyMethodName:
                return "DID method name must not be empty."
            case .notABlessedMethodName(let unblessedMethodName):
                return "Method name \'\(unblessedMethodName)\' is not blessed. Currently blessed methods include: \(DIDMethod.allCases.map(\.rawValue).joined(separator: ", "))."
            case .emptyIdentifier:
                return "DID identifier must not be empty."
            case .invalidMethodCharacter(let position, let character):
                return "Invalid character '\(character)' at position \(position) in DID method name."
            case .disallowedCharacter(let position, let character):
                return "Disallowed character '\(character)' in DID at identifier position \(position)."
            case .invalidPercentEncoding(let position):
                return "Incomplete percent-encoded sequence starting at position \(position)."
            case .trailingColonNotAllowed:
                return "Trailing colons are not allowed in a DID."
            case .invalidURL(let url):
                return "Invalid URL: \(url)"
            case .urlHasPortNumberWithoutLocalhost:
                return "URLs with a port number must include \"localhost\" as the hostname."
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }
}

/// Errors that can occur while validating or constructing a DID document.
public enum DIDDocumentValidatorError: Error, LocalizedError, CustomStringConvertible {

    /// There's a duplicate service ID.
    ///
    /// - Parameter serviceID: The service ID that's been duplicated.
    case duplicateServiceID(serviceID: String)

    /// The handle is either missing or invalid.
    case missingOrInvalidHandle

    /// The signing key is either missing or invalid.
    case missingOrInvalidSigningKey

    /// The Personal Data Server (PDS) is missing.
    case missingPDS

    /// The URL of the Personal Data Server (PDS) is missing.
    case invalidPDSURL

    public var errorDescription: String? {
        switch self {
            case .duplicateServiceID(let serviceID):
                return "Duplicate service ID: \(serviceID)"
            case .missingOrInvalidHandle:
                return "Missing or invalid handle."
            case .missingOrInvalidSigningKey:
                return "Missing or invalid signing key."
            case .missingPDS:
                return "The PDS is missing."
            case .invalidPDSURL:
                return "The URL for PDS is invalid."
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }
}
