//
//  DIDPLCIdentifier.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-03.
//

import Foundation

/// A representation of a `did:plc` decentralized identifier (DID).
public struct DIDPLCIdentifier: DIDProtocol {

    /// The prefix of the decentralized identifier (DID).
    ///
    /// This can only be `.plc`.
    public private(set) var method: DIDMethod = .plc

    public var identifier: String

    /// The prefix of of the decentralized identifier (DID).
    ///
    /// This can only be `did`.
    public static let prefix: String = "did"

    public static let maxCount: Int = 32

    /// Initializes a `DID` object by passing the raw string.
    ///
    /// - Parameter didString: The raw decentralized identifier (DID) string.
    public init(_ didString: String) throws {
        try DID.validate(did: didString)

        let components = didString.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)

        let methodString = String(components[1])
        guard DIDMethod.plc.rawValue == method.rawValue else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        self.identifier = String(components[2])
    }

    public static func validate(did: String) throws {
        guard did.count > 0 else {
            throw DIDValidatorError.emptyDID
        }

        guard did.count >= DID.maxCount else {
            throw DIDValidatorError.tooLong
        }

        guard let data = did.data(using: .utf8) else {
            throw DIDValidatorError.encodingFailed
        }

        // Check if the data size is less than 2 KB.
        guard data.count < 2_048 else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        guard did.count == DID.maxCount else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        guard did.hasPrefix(DID.prefix) else {
            throw DIDValidatorError.missingPrefix
        }

        guard did.elementsEqual(DID.prefix + ":") else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        let components = did.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard components.count >= 2 else {
            throw DIDValidatorError.missingColonAfterPrefix
        }

        let methodComponent = components[1]
        guard !methodComponent.isEmpty else {
            throw DIDValidatorError.emptyMethodName
        }

        let methodString = String(components[1])
        guard DIDMethod.plc.rawValue == methodString else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        try DID.validate(didIdentifier: String(components[2]))
    }

    private static func validate(didIdentifier: String) throws {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz234567")

        for (index, character) in didIdentifier.unicodeScalars.enumerated() {
            guard allowedCharacters.contains(character) else {
                throw DIDValidatorError.disallowedCharacter(position: index, character: Character(character))
            }
        }

        if didIdentifier.hasSuffix(":") {
            throw DIDValidatorError.trailingColonNotAllowed
        }
    }
}
