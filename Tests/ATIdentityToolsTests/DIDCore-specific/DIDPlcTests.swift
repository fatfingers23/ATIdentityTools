//
//  DIDPlcTests.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-05.
//

import Testing
@testable import DIDCore

@Suite("did:plc Tests") struct DIDPlcTests {

    @Suite("Identify did:plc DIDs.") struct DIDPlcIdentity {

        @Test("Identify all valid did:plc DIDs.", arguments: DIDs.valid)
        func identifyValidDIDPlcs(did: String) throws {
            let didPlc = try DIDPLCIdentifier(did)

            #expect(didPlc.method == .plc, "DID \(did) should be valid.")
        }

        @Test("Identify all invalid did:plc DIDs.", arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func identifyInvalidDIDPlcs(invalidDID: String, didValidationError: DIDValidatorError) throws {

        }
    }

    @Suite("Validate did:plc DIDs.") struct ValidateDIDPlc {

        @Test("Validates the valid did:plc DIDs.", arguments: DIDs.valid)
        func validateValidDIDPlcs(did: String) throws {

        }

        @Test("Invalidate invalid did:plc DIDs.", arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func invalidateInvalidDIDPlcs(invalidDID: String, didValidationError: DIDValidatorError) throws {
            
        }
    }

    public enum DIDs {
        public static var valid: [String] {
            return [
                "did:plc:l3rouwludahu3ui3bt66mfvj",
                "did:plc:aaaaaaaaaaaaaaaaaaaaaaaa",
                "did:plc:zzzzzzzzzzzzzzzzzzzzzzzz"
            ]
        }

        public static var invalid: [String: DIDValidatorError] {
            return [
                "did:plc:l3rouwludahu3ui3bt66mfv0": .disallowedCharacter(position: 31, character: "0"),
                "did:plc:l3rouwludahu3ui3bt66mfv1": .disallowedCharacter(position: 31, character: "1"),
                "did:plc:l3rouwludahu3ui3bt66mfv9": .disallowedCharacter(position: 31, character: "9"),
                "did:plc:l3rouwludahu3ui3bt66mfv": .tooShort,
                "did:plc:l3rouwludahu3ui3bt66mfvja": .tooShort,
                "did:plc:example.com:": .tooShort,
                "did:plc:exam%3Aple.com%3A8080": .tooShort,
                "did::l3rouwludahu3ui3bt66mfvj": .emptyMethodName,
                "did:plc:foo.com": .tooShort,
                "": .emptyDID,
                "random-string": .missingPrefix,
                "did plc": .missingColonAfterPrefix,
                "lorem ipsum dolor sit": .missingPrefix
            ]
        }
    }
}
