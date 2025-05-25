//
//  Models.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-10.
//

import Foundation
import ATCommonWeb

/// A list of options as a result of resolving an identity.
public struct IdentityResolverOptions {

    /// The amount of seconds before the request times out. Optional.
    public let timeout: Int?

    /// The URL of the `did:plc`. Optional.
    public let plcURL: URL?

    /// A cache of the identity.
    public let didCache: DIDCache

    /// An array of backup nameservers for the identity. Optional.
    public let backupNameservers: [String]?
}

/// A list of options as a result of resolving a handle.
public struct HandleResolverOptions {

    /// The amount of seconds before the request times out. Optional.
    public let timeout: Int?

    /// An array of backup nameservers for the identity. Optional.
    public let backupNameservers: [String]?
}

/// A list of options as a result of resolving a decentralized identifier (DID).
public struct DIDResolverOptions {

    /// The amount of seconds before the request times out. Optional.
    public let timeout: Int?

    /// The URL of the `did:plc`. Optional.
    public let plcURL: URL?

    /// A model that caches decentralized identifiers (DIDs).
    public let didCache: DIDCache?
}

/// A container of an AT Protocol identity.
public struct ATProtoData {

    /// The decentralized identifier (DID) of the identity.
    public let did: String

    /// The identity's signing key.
    public let signingKey: String

    /// The identiy's handle.
    public let handle: String

    /// The identity's Personal Data Server (PDS).
    public let pds: String
}

/// A structure that contains the result of a DID cache.
public struct CacheResult {

    /// The decentralized identifier (DID) of the identity.
    public let did: String

    /// THe DID document attached to the identity.
    public let didDocument: DIDDocument

    /// The date and time the cache as been updated.
    public let updatedAt: Date

    /// Determines if the cache is stale.
    public let isStale: Bool

    /// Determines whether the cache has expired.
    public let isExpired: Bool
}

/// A protocol used to manage caches for decentralized identifiers (DIDs).
public protocol DIDCache: Sendable {

    /// Caches the given DID document, optionally using a previous cache result.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID).
    ///   - didDocument: The DID document.
    ///   - previousCache: The previous instance of `CacheResult`, containing the previous cache. Optional.
    mutating func cacheDID(_ did: String, didDocument: DIDDocument, previousCache: CacheResult?) async throws

    /// Checks if the decentralized identifier (DID) is in the cache.
    ///
    /// - Parameter did: The decentralized identifier (DID).
    /// - Returns: An instance of `CacheResult`, containing
    func checkCache(from did: String) async throws -> CacheResult?

    /// Refreshes a cache from a given decentralized identifier (DID).
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID).
    ///   - didDocument: An asyncronous closure with respect to the DID Document. Returns an instance
    ///   of `DIDDocument`.
    ///   - previousCache: The previous instance of `CacheResult`, containing the previous cache. Optional.
    mutating func refreshCache(from did: String, didDocument: @escaping () async throws -> DIDDocument?, previousCache: CacheResult?) async throws

    /// Clears the cache entry for the given decentralized identifier (DID).
    ///
    /// - Parameter did: The decentralized identifier (DID) to clear.
    mutating func clearEntry(did: String) async throws
}
