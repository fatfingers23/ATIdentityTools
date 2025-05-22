//
//  DIDResolver.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-21.
//

import Foundation

/// A structure for resolving decentralized identifiers (DIDs).
public struct DIDResolver: DIDDocumentResolverProtocol {

    /// A llist of options for resolving decentralized identifiers (DIDs).
    public let options: DIDResolverOptions

    /// A dictionary of `did` method resolvers.
    public let methods: [String: DIDDocumentResolverProtocol]

    /// A cache related to decentralized identifiers (DIDs). Optional.
    public var didCache: DIDCache?

    /// The URL session instances used for requests.
    private let urlSession: URLSession

    /// Initializes a new instance of `DIDResolver`.
    ///
    /// - Parameters:
    ///   - options: A llist of options for resolving decentralized identifiers (DIDs).
    ///   - urlSession: The URL session instances used for requests. Defaults to `.shared`.
    public init(options: DIDResolverOptions, urlSession: URLSession = .shared) {
        self.didCache = options.didCache
        self.options = options
        self.urlSession = urlSession

        let plcURL = options.plcURL?.absoluteString ?? "https://plc.directory"
        let timeout = options.timeout ?? 3_000

        self.methods = [
            "plc": DIDPLCResolver(
                plcURL: plcURL,
                timeout: timeout,
                didCache: options.didCache,
                urlSession: urlSession
            ),
            "web": DIDWebResolver(
                timeout: timeout,
                urlSession: urlSession
            )
        ]
    }

    public func resolveRawDIDDocument(did: String) async throws -> String {
        let splitdDID = did.split(separator: ":")
        guard splitdDID[0] == "did" else {
            throw ATIdentityToolsError.poorlyFormattedDID(did: did)
        }

        let method = self.methods.first { $0.key == String(splitdDID[1])}

        guard let method = method else {
            throw ATIdentityToolsError.unsupportedDIDMethod(didMethod: String(splitdDID[1]))
        }

        return try await method.value.resolveRawDIDDocument(did: did)
    }
}
