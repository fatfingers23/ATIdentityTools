//
//  Errors.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-10.
//

import Foundation

/// Errors that can occur with respect to identities.
public enum ATIdentityToolsError: Error, LocalizedError, CustomStringConvertible {

    /// The JSON object is invaalid.
    case invalidJSON

    /// The decentralized identifier (DID) was not found.
    ///
    /// - Parameter did: The decentralized identifier (DID) that wasn't found.
    case didNotFound(did: String)

    /// The decentralized identifier (DID) was not formatted propertly.
    ///
    /// - Parameter did: The decentralized identifier (DID) that was poorly formatted.
    case poorlyFormattedDID(did: String)

    /// The `did` method used is not supported.
    ///
    /// - Parameter didMethod: The method the `did` is using.
    case unsupportedDIDMethod(didMethod: String)

    /// The DID document is poorly formatted.
    ///
    /// - Parameter did: The decentralized identifier (DID) that the DID Document is linked to.
    case poorlyFormattedDIDDocument(did: String)

    /// The provided DID document is incomplete.
    ///
    /// - Parameter did: The decentralized identifier (DID) that the DID Document is linked to.
    case incompleteDIDDocument(did: String)

    /// The web path for the `did:web` is unsupported.
    ///
    /// - Parameter did: The `did:web` that contains the unsupported web path.
    case unsupportedDIDWebPath(did: String)

    public var errorDescription: String? {
        switch self {
            case .invalidJSON:
                return "The JSON object is invalid."
            case .didNotFound(let did):
                return "The DID, '\(did)', was not found."
            case .poorlyFormattedDID(let did):
                return "The DID, '\(did)', was not formatted properly."
            case .unsupportedDIDMethod(let didMethod):
                return "'did:\(didMethod)' is not supported."
            case .poorlyFormattedDIDDocument(let did):
                return "The DID Document for '\(did)' was poorly formatted."
            case .incompleteDIDDocument(let did):
                return "The DID Document for '\(did)' is incomplete."
            case .unsupportedDIDWebPath(let did):
                return "The web path for '\(did)' is unsupported."
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }
}

/// Errors that can occur with respect to ``ATProtoData``.
public enum ATProtoDocumentError: Error, LocalizedError, CustomStringConvertible {

    /// The key type is unsupported.
    ///
    /// - Parameter didKeyType: The `did:key` type.
    case unsupportedKeyType(didKeyType: String)

    /// The signing key has not been found.
    case signingKeyNotFound

    public var errorDescription: String? {
        switch self {
            case .unsupportedKeyType(let didKeyType):
                return "Unsupported did:key type: \(didKeyType)"
            case .signingKeyNotFound:
                return "Signing key not found."
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }
}

public enum DIDResolverError: Error, LocalizedError, CustomStringConvertible {

    /// The URL request failed.
    case requestFailed(resolver: String, code: Int, message: String)

    public var errorDescription: String? {
        switch self {
            case .requestFailed(let resolver, let code, let message):
                return "Request to \(resolver) failed with status code \(code): \(message)"
        }
    }

    public var description: String {
        return errorDescription ?? String(describing: self)
    }
}
