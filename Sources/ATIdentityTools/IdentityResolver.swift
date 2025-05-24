//
//  IdentityResolver.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-23.
//

import Foundation

/// A structure representing an identity resolver.
public struct IdentityResolver {

    /// An instance of a handle resolver.
    public let handle: HandleResolver

    /// An instance of a decentralized identifier (DID) resolver.
    public let did: DIDResolver

    /// The URL session instances used for requests.
    private let urlSession: URLSession

    /// Initializes an instance of `IDResolver`.
    ///
    /// - Parameters:
    ///   - options: A list of options for resolving identities.
    ///   - urlSession: The URL session instances used for requests.
    public init(options: IdentityResolverOptions, urlSession: URLSession = .shared) {
        self.urlSession = urlSession

        let timeout = options.timeout ?? 3_000
        let plcURL = options.plcURL ?? URL(string: "https://plc.directory")
        let didCache = options.didCache
        let backupNameservers = options.backupNameservers

        let handleResolverOptions = HandleResolverOptions(timeout: timeout, backupNameservers: backupNameservers)
        let didResolverOptions = DIDResolverOptions(timeout: timeout, plcURL: plcURL, didCache: didCache)

        self.handle = HandleResolver(options: handleResolverOptions)
        self.did = DIDResolver(options: didResolverOptions, urlSession: urlSession)
    }


}
