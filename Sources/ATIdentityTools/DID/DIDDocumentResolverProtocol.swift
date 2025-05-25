//
//  DIDDocumentResolverProtocol.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-19.
//

import Foundation
import ATCommonWeb
import ATCryptography

/// A protocol used for resolving DID Documents.
public protocol DIDDocumentResolverProtocol {

    /// A cache related to decentralized identifiers (DIDs).
    var didCache: DIDCache? { get set }

    /// Retrieves the raw DID Document JSON.
    ///
    /// - Parameter did: The decentralized identifier (DID) attached to the DID Document.
    /// - Returns: A raw JSON object, containing the DID Document.
    ///
    /// - Throws: An error if the resolution fails.
    func resolveRawDIDDocument(did: String) async throws -> String

    /// Validates the DID Document.
    ///
    /// - Parameters:
    ///   - didDocumentJSON: The DID Document in JSON form.
    ///   - did: The decentralized identifier (DID) attached to the DID Document.
    /// - Returns: A `DIDDocument` object, containing the information contained from the JSON object.
    ///
    /// - Throws: An error if the DID Document is somehow invalid.
    func validateDIDDocument(_ didDocumentJSON: String, did: String) async throws -> DIDDocument

    /// Resolve the DID Document without the need for caching.
    ///
    /// - Parameter did: The decentralized identifier (DID) attached to the DID Document.
    /// - Returns: A `DIDDocument` object, containing the valid DID Document details.
    ///
    /// - Throws: An error if the resolution fails.
    func resolveWithoutCaching(did: String) async throws -> DIDDocument

    /// Refreshes the cache.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) related to the cached result.
    ///   - previousCache: The currently used cached result. Optional.
    mutating func refreshCache(did: String, previousCache: CacheResult?) async throws

    /// Resolves a DID Document.
    ///
    /// This is different from ``DIDDocumentResolverProtocol/resolveRawDIDDocument(did:)``, where it grabs
    /// the DID Document as a raw JSON object.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) attached to the DID Document.
    ///   - willForceRefresh: Determines whether the method should bypass any cached values and
    ///   forcefully refresh.
    /// - Returns:
    mutating func resolve(did: String, willForceRefresh: Bool) async throws -> DIDDocument

    /// Resolves the AT Protocol–specific metadata from a DID Document.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) to resolve.
    ///   - willForceRefresh: Determines whether the method should bypass any cached values and
    ///   forcefully refresh.
    /// - Returns: An `ATProtoData` object, containing extracted metadata specific to the AT Protocol.
    ///
    /// - Throws: An error if the resolution or parsing fails.
    mutating func resolveATProtocolData(for did: String, willForceRefresh: Bool) async throws -> ATProtoData

    /// Resolves the `did:key` signing key.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) attached to the signing key.
    ///   - willForceRefresh: Determines whether to force refresh the resolution.
    /// - Returns: The signing key.
    mutating func resolveSigningKey(for did: String, willForceRefresh: Bool) async throws -> String

    /// Determines whether the signature provided is valid.
    ///
    /// - Parameters:
    ///   - did: The decentralized identifier (DID) attached to the signature.
    ///   - data: The original message that was signed.
    ///   - signature: The signature to verify.
    ///   - willForceRefresh: Determines whether the method should bypass any cached values and
    ///   forcefully refresh.
    /// - Returns: `true` if the signature is valid, or `false` if it isn't.
    mutating func isSignatureValid(for did: String, data: Data, signature: Data, willForceRefresh: Bool) async throws -> Bool
}

extension DIDDocumentResolverProtocol {

    public func validateDIDDocument(_ didDocumentJSON: String, did: String) async throws -> DIDDocument {
        guard let jsonData = didDocumentJSON.data(using: .utf8) else {
            throw ATIdentityToolsError.invalidJSON
        }

        let decoder = JSONDecoder()
        let didDocument = try decoder.decode(DIDDocument.self, from: jsonData)

        guard didDocument.id == did else {
            throw ATIdentityToolsError.poorlyFormattedDIDDocument(did: did)
        }

        return didDocument
    }

    public func resolveWithoutCaching(did: String) async throws -> DIDDocument {
        let rawJSON = try await self.resolveRawDIDDocument(did: did)
        return try await self.validateDIDDocument(rawJSON, did: did)
    }

    public mutating func refreshCache(did: String, previousCache: CacheResult? = nil) async throws {
        var localCache = self.didCache
        try await localCache?.refreshCache(from: did, didDocument: { [self] in
            try await self.resolveWithoutCaching(did: did)
        }, previousCache: previousCache)
        self.didCache = localCache
    }

    public mutating func resolve(did: String, willForceRefresh: Bool = false) async throws -> DIDDocument {
        var fromCache: CacheResult? = nil

        if self.didCache != nil && !willForceRefresh {
            fromCache = try await self.didCache?.checkCache(from: did)

            if let fromCache = fromCache, !fromCache.isExpired {
                if fromCache.isStale {
                    try await self.refreshCache(did: did, previousCache: fromCache)
                }

                return fromCache.didDocument
            }
        }

        do {
            let didDocument = try await self.resolveWithoutCaching(did: did)

            try await self.didCache?.cacheDID(did, didDocument: didDocument, previousCache: fromCache)
            return didDocument
        } catch {
            try await self.didCache?.clearEntry(did: did)
            throw error
        }

    }

    public mutating func resolveATProtocolData(for did: String, willForceRefresh: Bool = false) async throws -> ATProtoData {
        let didDocument = try await resolve(did: did, willForceRefresh: willForceRefresh)

        let atProtoData = ATProtocolDataUtilities.parseToATProtoDocument(didDocument: didDocument)

        guard let atProtoData = atProtoData else {
            throw ATIdentityToolsError.poorlyFormattedDIDDocument(did: did)
        }
        return atProtoData
    }

    public mutating func resolveSigningKey(for did: String, willForceRefresh: Bool = false) async throws -> String {
        if did.starts(with: "did:key") {
            return did
        } else {
            let didDocument = try await self.resolve(did: did, willForceRefresh: willForceRefresh)
            let atProtoData = ATProtocolDataUtilities.parseToATProtoDocument(didDocument: didDocument)

            guard let atProtoData = atProtoData else {
                throw ATProtoDocumentError.signingKeyNotFound
            }

            return atProtoData.signingKey
        }
    }

    public mutating func isSignatureValid(for did: String, data: Data, signature: Data, willForceRefresh: Bool = false) async throws -> Bool {
        let signingKey = try await self.resolveSigningKey(for: did, willForceRefresh: willForceRefresh)
        return try await SignatureVerifier.verifySignature(didKey: signingKey, data: [UInt8](data), signature: [UInt8](signature))
    }
}
