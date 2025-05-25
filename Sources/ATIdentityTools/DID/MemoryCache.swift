//
//  MemoryCache.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-24.
//

import Foundation
import ATCommonWeb

/// An in-memory cache for storing and retrieving DID Documents with automatic staleness and
/// expiration handling.
public struct MemoryCache: DIDCache {

    /// Represents how long (in milliseconds) a cached entry is considered fresh before it becomes stale.
    ///
    /// "TTL" stands for "time to live."
    public let staleTTL: TimeInterval

    /// Represents the absolute maximum duration (in milliseconds) that a cached entry can be used before
    /// it expires.
    ///
    /// "TTL" stands for "time to live."
    public let maxTTL: TimeInterval

    /// A dictionary of caches.
    public var cache: [String: CacheValue] = [:]

    /// Initializes an instance of `MemoryCache`.
    ///
    /// - Parameters:
    ///   - staleTTL: Represents how long (in milliseconds) a cached entry is considered fresh before it
    ///   becomes stale. Defaults to `TimeUtilities.hour`.
    ///   - maxTTL: Represents the absolute maximum duration (in milliseconds) that a cached entry can be
    ///   used before it expires. Defaults to `TimeUtilities.day`.
    public init(staleTTL: TimeInterval = TimeUtilities.hour, maxTTL: TimeInterval = TimeUtilities.day) {
        self.staleTTL = staleTTL
        self.maxTTL = maxTTL
    }

    public mutating func cacheDID(_ did: String, didDocument: ATCommonWeb.DIDDocument, previousCache: CacheResult?) async throws {
        self.cache[did] = CacheValue(didDocument: didDocument, updateAt: Date())
    }

    public func checkCache(from did: String) async throws -> CacheResult? {
        let cacheValue = self.cache[did]

        guard let cacheValue = cacheValue else {
            return nil
        }

        let now = Date()
        let isExpired = now > cacheValue.updateAt.addingTimeInterval(self.maxTTL)
        let isStale = now > cacheValue.updateAt.addingTimeInterval(self.staleTTL)

        return CacheResult(
            did: did,
            didDocument: cacheValue.didDocument,
            updatedAt: cacheValue.updateAt,
            isStale: isStale,
            isExpired: isExpired
        )
    }

    public mutating func refreshCache(
        from did: String,
        didDocument: @escaping () async throws -> ATCommonWeb.DIDDocument?,
        previousCache: CacheResult?
    ) async throws {
        let didDocument = try await didDocument()

        if let didDocument = didDocument {
            try await self.cacheDID(did, didDocument: didDocument, previousCache: previousCache)
        }
    }

    public mutating func clearEntry(did: String) async throws {
        self.cache.removeValue(forKey: did)
    }

    /// Removes all of the entries in the cache.
    public mutating func clearAll() async throws {
        self.cache.removeAll()
    }

    /// A cached value, containing some important information of a DID Document.
    public struct CacheValue : Sendable {

        /// The DID Document of the cached value.
        public let didDocument: ATCommonWeb.DIDDocument

        /// The date and time the cache was updated.
        public let updateAt: Date
    }
}
