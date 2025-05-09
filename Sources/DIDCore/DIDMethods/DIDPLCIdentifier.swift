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
        try DIDPLCIdentifier.validate(did: didString)

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

        guard did.hasPrefix(DIDPLCIdentifier.prefix) else {
            throw DIDValidatorError.missingPrefix
        }

        guard did.hasPrefix("\(DIDPLCIdentifier.prefix):") else {
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

        let methodString = String(methodComponent)
        guard DIDMethod.plc.rawValue == methodString else {
            throw DIDValidatorError.notABlessedMethodName(unblessedMethodName: methodString)
        }

        // Now validate length
        guard did.count == DIDPLCIdentifier.maxCount else {
            if did.count < DIDPLCIdentifier.maxCount {
                throw DIDValidatorError.tooShort
            } else {
                throw DIDValidatorError.tooLongForDIDPLC
            }
        }

        guard let data = did.data(using: .utf8) else {
            throw DIDValidatorError.encodingFailed
        }

        // Check if data size is less than 2 KB.
        guard data.count < 2_048 else {
            throw DIDValidatorError.exceedsMaximumSize
        }

        try DIDPLCIdentifier.validate(didIdentifier: String(components[2]))
    }

    private static func validate(didIdentifier: String) throws {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz234567")

        for (index, character) in didIdentifier.unicodeScalars.enumerated() {
            guard allowedCharacters.contains(character) else {
                // "did" + ":" + "plc" + ":" + identifier
                let finalIndex = 3 + 1 + 3 + 1 + index
                throw DIDValidatorError.disallowedCharacter(position: finalIndex, character: Character(character))
            }
        }

        if didIdentifier.hasSuffix(":") {
            throw DIDValidatorError.trailingColonNotAllowed
        }
    }
}
