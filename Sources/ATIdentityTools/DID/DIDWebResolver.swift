//
//  DIDWebResolver.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-21.
//

import Foundation

/// A concrete implementation for resolving `did:web` DID documents.
public struct DIDWebResolver: DIDDocumentResolverProtocol, Sendable {

    /// The time the request can take before it times out, in milliseconds.
    public let timeout: Int

    /// A cache related to decentralized identifiers (DIDs). Optional.
    public var didCache: DIDCache?

    /// The URL session instances used for requests.
    private let urlSession: URLSession

    /// The URL slug to find the DID Document.
    private let docPath: String = "/.well-known/did.json"

    /// Initializes a new instance of `DIDWebResolver`.
    ///
    /// - Parameters:
    ///   - timeout: The time the request can take before it times out, in milliseconds. Defaults to `3000`.
    ///   - didCache: A cache related to decentralized identifiers (DIDs). Optional. Defaults to `nil`.
    ///   - urlSession: The URL session instances used for requests. Defaults to `.shared`.
    public init(timeout: Int, didCache: DIDCache? = nil, urlSession: URLSession) {
        self.timeout = timeout
        self.didCache = didCache
        self.urlSession = urlSession
    }

    public func resolveRawDIDDocument(did: String) async throws -> String {
        let parsedID = did.split(separator: ":").dropFirst(2).joined(separator: ":")
        let parts = parsedID.split(separator: ":").map { String($0) }

        let decodedParts = parts.map { $0.decodedFromURIComponent }

        let urlPath: String

        guard decodedParts.count > 1 else {
            throw ATIdentityToolsError.poorlyFormattedDID(did: did)
        }

        guard decodedParts.count == 1 else {
            throw ATIdentityToolsError.unsupportedDIDWebPath(did: did)
        }

        urlPath = "https://\(decodedParts[0])\(self.docPath)"

        var finalURLComponent = URLComponents(string: urlPath)

        if finalURLComponent?.host == "localhost" {
            finalURLComponent?.scheme = "http"
        }

        guard let finalURL = finalURLComponent?.url else {
            throw URLError(.badURL)
        }

        return try await DIDUtilities.timed(milliseconds: UInt64(self.timeout)) {
            var request = URLRequest(url: finalURL)

            request.setValue("application/did+ld+json,application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "GET"

            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            switch httpResponse.statusCode {
                case 200:
                    guard let responseString = String(data: data, encoding: .utf8) else {
                        throw URLError(.badServerResponse)
                    }

                    return responseString
                default:
                    throw DIDResolverError.requestFailed(
                        resolver: "DIDPLCResolver",
                        code: httpResponse.statusCode,
                        message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                    )
            }
        }
    }
}
