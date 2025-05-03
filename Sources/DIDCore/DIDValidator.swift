//
//  DIDValidator.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-02.
//

/// A service protocol for validating a decentralized identifier (DID).
public protocol DIDValidator {

    /// Validates the raw decentralized identifier (DID).
    ///
    /// - Parameter did: The decentralized identifier (DID) to validate.
    /// - Returns: A tuple, which contains the method and identifier of the DID.
    func validate(_ did: String) throws -> (method: String, identifier: String)
}
