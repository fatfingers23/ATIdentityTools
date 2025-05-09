//
//  DIDWebIdentifier.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-03.
//

import Foundation

/// A representation of a `did:web` decentralized identifier (DID).
public struct DIDWebIdentifier: DIDProtocol {

    /// The prefix of the decentralized identifier (DID).
    ///
    /// This can only be `.web`.
    public private(set) var method: DIDMethod = .web

    public var identifier: String

    /// The prefix of of the decentralized identifier (DID).
    ///
    /// This can only be `did`.
    public static let prefix: String = "did"

    public static let maxCount: Int = 2_048

    /// Initializes a `DID` object by passing the raw string.
    ///
    /// - Parameter didString: The raw decentralized identifier (DID) string.
    public init(_ didString: String) throws {
        try DIDWebIdentifier.validate(did: didString)

        let components = didString.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)

        let methodString = String(components[1])
        guard self.method.rawValue == methodString else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        self.identifier = String(components[2])
    }

    public static func validate(did: String) throws {
        guard did.count > 0 else {
            throw DIDValidatorError.emptyDID
        }

        guard did.hasPrefix(DID.prefix) else {
            throw DIDValidatorError.missingPrefix
        }

        guard did.hasPrefix("\(DIDWebIdentifier.prefix):") else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        let components = did.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard components.count >= 2 else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        guard components.count == 3 else {
            throw DIDValidatorError.invalidDID
        }

        let identifier = String(components[2])
        guard !identifier.isEmpty else {
            throw DIDValidatorError.emptyIdentifier
        }

        guard !identifier.hasPrefix(":"), !identifier.hasSuffix(":") else {
            throw DIDValidatorError.methodSegmentStartsOrEndsWithColon
        }

        let methodComponent = components[1]
        guard !methodComponent.isEmpty else {
            throw DIDValidatorError.emptyMethodName
        }

        let methodString = String(methodComponent)
        guard DIDMethod.web.rawValue == methodString else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        guard did.count <= DID.maxCount else {
            throw DIDValidatorError.tooLong
        }

        guard let data = did.data(using: .utf8) else {
            throw DIDValidatorError.encodingFailed
        }

        // Check if the data size is less than 2 KB.
        guard data.count < 2_048 else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        _ = try Self.convertDIDWebToURL(identifier: String(components[2]))
    }

    /// Converts the identifier portion of a `did:web` to a URL.
    ///
    /// - Parameter identifier: The identifier portion of the decentralized identifier (DID).
    public static func convertDIDWebToURL(identifier: String) throws -> URL {
        guard var urlComponents = URLComponents(string: identifier) else {
            throw DIDValidatorError.invalidURL(url: identifier)
        }

        if urlComponents.host == "localhost" {
            urlComponents.scheme = "http"

            guard let localhostPort = urlComponents.port,
                  let localhostURL = URL(string: "http://localhost:\(localhostPort)") else {
                throw DIDValidatorError.invalidURL(url: identifier)
            }

            return localhostURL
        } else {
            guard urlComponents.port == nil else {
                throw DIDValidatorError.urlHasPortNumberWithoutLocalhost
            }
        }

        let allowedWebsiteCharacters = CharacterSet.uppercaseLetters
            .union(.lowercaseLetters)
            .union(.decimalDigits)
            .union(CharacterSet(charactersIn: "-._~"))

        guard identifier.rangeOfCharacter(from: allowedWebsiteCharacters.inverted) == nil else {
            throw DIDValidatorError.invalidURL(url: identifier)
        }

        guard let newURL = urlComponents.url else {
            throw DIDValidatorError.invalidURL(url: urlComponents.url?.absoluteString ?? "Unknown URL")
        }

        return newURL
    }

    /// Converts a URL to a `did:web` decentralized identifier (DID) as a `String` object.
    ///
    /// - Parameter url: The URL to convert.
    /// - Returns: A `String` representation of a `did:web` DID.
    public static func convertURLToDIDWeb(url: URL) -> String {
        return "did:web:\(url.absoluteString)"
    }

    /// Determines if the string is a `did:web` decentralized identifier (DID).
    ///
    /// - Parameter did: The decentralized identifier (DID) to convert.
    /// - Returns: `true` if it is a `did:web` DID, or `false` if it's not (or an incompatible DID).
    public static func isDIDWeb(_ did: String) -> Bool {
        do {
            try Self.validate(did: did)
        } catch {
            return false
        }

        let components = did.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard URLComponents(string: String(components[1])) != nil else {
            return false
        }

        do {
            _ = try Self.convertDIDWebToURL(identifier: String(components[2]))

            return true
        } catch {
            return false
        }
    }
}
