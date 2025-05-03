//
//  DID.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-02.
//

import Foundation

/// A representation of a decentralized identifier (DID).
///
/// This structure both constructs and validates the DID.
///
/// - SeeAlso: The [DID Syntax](https://www.w3.org/TR/did-core/#did-syntax) specifications from the W3C.
public struct DID: DIDProtocol {

    /// The method name component of the decentralized identifier (DID).
    ///
    /// Currently, the AT Protocol "blesses" `plc` and `web`.
    public let method: DIDMethod

    /// The method-specific identifier component.
    public let identifier: String

    public var description: String {
        return "\(DID.prefix):\(self.method.rawValue):\(self.identifier)"
    }

    /// The prefix of of the decentralized identifier (DID).
    public static let prefix = "did"

    /// The maximum length of the decentralized identifier (DID).
    public static let maxCount = 2_048

    /// Initializes a `DID` object by passing the raw string.
    ///
    /// - Parameter didString: The raw decentralized identifier (DID) string.
    public init(_ didString: String) throws {
        try DID.validate(did: didString)

        let components = didString.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)

        let methodString = String(components[1])
        guard let method = DIDMethod(rawValue: methodString) else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        self.method = method
        self.identifier = String(components[2])
    }
}

/// The method name component of the decentralized identifier (DID).
///
/// Currently, the AT Protocol considers `plc` and `web` as "blessed."
public enum DIDMethod: String, CaseIterable {

    /// The `did:plc` method.
    case plc = "plc"

    /// The `did:web` method.
    case web = "web"
    }
