# ``DIDCore``

Identify and validate Decentralized Identifiers in the AT Protocol.

## Overview

``DIDCore`` is a foundational Swift package for working with Decentralized Identifiers (DIDs) as specified by [W3C DID Core](https://www.w3.org/TR/did-core/) and used in the AT Protocol ecosystem. This library enables developers to construct, validate, parse, and work with DIDs and DID Documents—ensuring strict compliance with both the W3C standards and AT Protocol-specific requirements.

A Decentralized Identifier (DID) is a unique string, such as `did:plc:abcd1234efgh5678ijkl9012mnop3456`, that identifies an entity in a decentralized system. DIDs are used for identity, authentication, and data integrity across decentralized networks.

There are two DID methods that are considered "blessed" in the AT Protocol: `did:plc` (which is created specifically for the AT Protocol) and `did:web` (which was created by the W3C).

Further reading: [The DID section](https://atproto.com/specs/did) of the AT Protocol documentation.

### What DIDCore provides

- Enforces strict validation rules for `did:plc` and `did:web` identifiers, complying to AT Protocol requirements.
- Includes robust, type-safe representations of DIDs and DID Documents.
- Ensures DID Documents are compliant with both the W3C and AT Protocol.

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
