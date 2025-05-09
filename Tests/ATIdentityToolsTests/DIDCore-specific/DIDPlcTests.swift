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
        func identifyInvalidDIDPlcs(invalidDID: String, didValidationError: String) throws {
            #expect(throws: DIDValidatorError.self, "did:plc \(invalidDID) should not be valid: \(didValidationError)", performing: {
                try DIDPLCIdentifier(invalidDID)
            })
        }
    }

    @Suite("Validate did:plc DIDs.") struct ValidateDIDPlc {

        @Test("Validates the valid did:plc DIDs.", arguments: DIDs.valid)
        func validateValidDIDPlcs(did: String) throws {
            #expect(throws: Never.self, "DID \(did) should be valid.", performing: {
                try DIDPLCIdentifier.validate(did: did)
            })
        }

        @Test("Invalidate invalid did:plc DIDs.", arguments: zip(DIDs.invalid.keys, DIDs.invalid.values))
        func invalidateInvalidDIDPlcs(invalidDID: String, didValidationError: String) throws {
            #expect(throws: DIDValidatorError.self, "did:plc \(invalidDID) should not be valid: \(didValidationError)", performing: {
                try DIDPLCIdentifier.validate(did: invalidDID)
            })
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

        public static var invalid: [String: String] {
            return [
                "did:plc:l3rouwludahu3ui3bt66mfv0": "Disallowed character '0' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv1": "Disallowed character '1' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv9": "Disallowed character '9' in DID at identifier position 31.",
                "did:plc:l3rouwludahu3ui3bt66mfv": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "did:plc:l3rouwludahu3ui3bt66mfvja": "did:plc is too long. There's a maximum limit of 32 characters.",
                "did:plc:example.com:": "tooShort",
                "did:plc:exam%3Aple.com%3A8080": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "did::l3rouwludahu3ui3bt66mfvj": "DID method name must not be empty.",
                "did:plc:foo.com": "DID is too short. did:plc DIDs must have the exact size of 32 characters.",
                "": "DID is empty.",
                "random-string": "DID requires \'did\' prefix.",
                "did plc": "Missing colon after the \'did\' prefix.",
                "lorem ipsum dolor sit": "DID requires \'did\' prefix."
            ]
        }
    }
}
