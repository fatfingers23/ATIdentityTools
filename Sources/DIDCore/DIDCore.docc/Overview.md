# ``DIDCore``

Identify and validate Decentralized Identifiers in the AT Protocol.

## Overview

``DIDCore`` is a foundational Swift package for working with Decentralized Identifiers (DIDs) as specified by the [W3C DID Specifications](https://www.w3.org/TR/did-core/) and used in the AT Protocol ecosystem. This library enables developers to construct, validate, parse, and work with DIDs and DID Documents—ensuring strict compliance with both the W3C standards and AT Protocol-specific requirements.

A Decentralized Identifier (DID) is a unique string, such as `did:plc:abcd1234efgh5678ijkl9012mnop3456`, that identifies an entity in a decentralized system. DIDs are used for identity, authentication, and data integrity across decentralized networks.

There are two DID methods that are considered "blessed" in the AT Protocol: `did:plc` (which is created specifically for the AT Protocol) and `did:web` (which was created by the W3C).

Further reading: [The DID section](https://atproto.com/specs/did) of the AT Protocol documentation.

### What DIDCore provides

- Enforces strict validation rules for `did:plc` and `did:web` identifiers, complying to AT Protocol requirements.
- Includes robust, type-safe representations of DIDs and DID Documents.
- Ensures DID Documents are compliant with both the W3C and AT Protocol.

ATIdentityTools is fully open source under the [Apache 2.0 license](https://github.com/ATProtoKit/ATIdentityTools/blob/main/LICENSE.md). You can take a look at it and make contributions to it [on GitHub](https://github.com/ATProtoKit/ATIdentityTools).

## Topics

### DIDs

- ``DID``
- ``DIDProtocol``

### DID Methods

- ``DIDPLCIdentifier``
- ``DIDWebIdentifier``
- ``DIDMethod``

### DID Documents

- ``DIDDocument``

### Error Handling

- ``DIDError``
- ``DIDValidatorError``
- ``DIDDocumentValidatorError``
