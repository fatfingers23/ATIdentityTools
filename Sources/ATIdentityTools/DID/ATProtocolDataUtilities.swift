//
//  ATProtocolDataUtilities.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-11.
//

import Foundation
import ATCommonWeb
import ATCryptography

/// A utility namespace for parsing and extracting AT Protocol-related data from a `DIDDocument`.
public enum ATProtocolDataUtilities {

    /// Retireves the `did:key` from the DID Document.
    ///
    /// - Parameter didDocument: The DID Document.
    /// - Returns: The `did:key`.
    public static func getDIDKey(didDocument: DIDDocument) throws -> String? {
        let signingKey = didDocument.getSigningKey()

        guard let signingKey = signingKey else { return nil }
        return try Self.getDIDKeyFromMultibase(signingKey: signingKey)
    }

    /// Retrieves the `did:key` from the multibase public key.
    ///
    ///- Parameter signingKey: A tuple, which contains the type and the multibase public key.
    public static func getDIDKeyFromMultibase(signingKey: (type: String, multibasePublicKey: String)) throws -> String {
        let keyBytes = try Multibase.multibaseToBytes(multibase: signingKey.multibasePublicKey)

        switch signingKey.type {
            case "EcdsaSecp256r1VerificationKey2019":
                return try DIDKey.formatDIDKey(jwtAlgorithm: p256JWTAlgorithm, keyBytes: keyBytes)
            case "EcdsaSecp256k1VerificationKey2019":
                return try DIDKey.formatDIDKey(jwtAlgorithm: k256JWTAlgorithm, keyBytes: keyBytes)
            case "Multikey":
                let parsedMultikey = try DIDKey.parseMultikey(signingKey.multibasePublicKey)
                return try DIDKey.formatDIDKey(jwtAlgorithm: parsedMultikey.jwtAlgorithm, keyBytes: parsedMultikey.keyBytes)
            default:
                throw ATProtoDocumentError.unsupportedKeyType(didKeyType: signingKey.type)
        }
    }

    /// Parses a `DIDDocument` to produce a complete `ATProtoData` object.
    ///
    /// - Parameter didDocument: The DID document containing AT Protocol metadata.
    /// - Returns: A fully populated `ATProtoData` if all fields are present; or, `nil` if not.
    public static func parseToATProtoDocument(didDocument: ATCommonWeb.DIDDocument) -> ATProtoData? {
        let did = didDocument.id
        let signingKey = try? Self.getDIDKey(didDocument: didDocument)
        let handle = didDocument.getHandle()
        let pds = didDocument.getPDSEndpoint()?.absoluteString

        guard let signingKey = signingKey, let handle = handle, let pds = pds else {
            return nil
        }

        let atProtoData = ATProtoData(did: did, signingKey: signingKey, handle: handle, pds: pds)
        return atProtoData
    }
}
