//
//  DIDDocument.swift
//  DIDCore
//
//  Created by Christopher Jr Riley on 2025-05-04.
//

import Foundation

/// Represents a DID document in the AT Protocol, containing crucial information fo
/// AT Protocol functionality.
///
/// The DID document includes the decentralized identifier (DID), verification methods, and
/// service endpoints necessary for interacting with the AT Protocol ecosystem, such as
/// authentication and data storage locations.
public struct DIDDocument: Codable, Equatable {

    /// Represents the `@context` field in a DID Document, which defines the JSON-LD processing context.
    public let context: Context

    /// A representation of a decentralized identifier (DID).
    public let id: DID

    /// A type that represents either a single decentralized identifier (DID) or a collection of DIDs for
    /// use as a controller reference. Optional.
    public let controller: DIDController?

    /// An array of URL aliases for the DID document. Optional.
    public let alsoKnownAs: [URL]?

    /// An array of service entries within a DID Document,. Optional.
    public let service: [DIDService]?

    /// An array of `authentication` entries. Optional.
    public let authentication: [DIDAuthentication]?

    /// An array of `verificationMethod` entries, which can be either a reference to a verification method
    /// by URI or an inline verification method definition.
    public let verificationMethod: [DIDVerificationMethodOrReference]?

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case id
        case controller
        case alsoKnownAs
        case service
        case authentication
        case verificationMethod
    }

    // Enums and Structs

    // MARK: @context -
    /// Represents the `@context` field in a DID Document, which defines the JSON-LD processing context.
    public enum Context: Codable, Equatable {
        case string(String)
        case array([String])

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                guard str == "https://www.w3.org/ns/did/v1" else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "@context must be https://www.w3.org/ns/did/v1"
                    )
                }
                self = .string(str)
            } else {
                let arr = try container.decode([String].self)
                guard let first = arr.first, first == "https://www.w3.org/ns/did/v1" else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "First element of @context must be https://www.w3.org/ns/did/v1"
                    )
                }
                self = .array(arr)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .string(let str): try container.encode(str)
                case .array(let arr): try container.encode(arr)
            }
        }
    }

    // MARK: controller -
    /// A type that represents either a single decentralized identifier (DID) or a collection of DIDs for use
    /// as a controller reference.
    public enum DIDController: CustomStringConvertible, Codable, Equatable {

        /// Reference a single instance of `DID` object.
        case single(DID)

        /// References an array of `DID` objects.
        case multiple([DID])

        public var description: String {
            switch self {
                case .single(let did):
                    return did.description
                case .multiple(let dids):
                    return dids.map(\.description).joined(separator: ", ")
            }
        }

        /// Attempts to parse either a single or an array of DIDs from any input.
        ///
        /// - Parameter input: An array of `DID` objects.
        /// - Returns: An instance of `DIDController`, filled with one of the cases.
        public static func parse(_ input: [String]) throws -> DIDController {
            switch input.count {
                case 0:
                    throw DIDValidatorError.invalidDID
                case 1:
                    return .single(try DID(input[0]))
                default:
                    return .multiple(try input.map { try DID($0)})
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let single = try? container.decode(String.self) {
                self = .single(try DID(single))
            } else if let multiple = try? container.decode([String].self) {
                self = .multiple(try multiple.map(DID.init))
            } else {
                throw DecodingError.typeMismatch(
                    DIDController.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected a single DID string or array of DID strings"
                    )
                )
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .single(let did):
                    try container.encode(did.description)
                case .multiple(let dids):
                    try container.encode(dids.map(\.description))
            }
        }

        public static func == (lhs: DIDController, rhs: DIDController) -> Bool {
            switch (lhs, rhs) {
                case let (.single(a), .single(b)):
                    return a.description == b.description
                case let (.multiple(a), .multiple(b)):
                    return a.map(\.description) == b.map(\.description)
                default:
                    return false
            }
        }
    }

    // MARK: service -
    /// Represents a service entry within a DID Document, including its type and endpoint information.
    public struct DIDService: Codable, Equatable {

        /// A type representing a URI used within a DID Document that may be an absolute URI or a
        /// relative fragment.
        public let id: DIDRelativeURI

        /// A type property of a DID service, which may be a single string or an array of strings.
        public let type: DIDServiceType

        /// Represents the `serviceEndpoint` property of a DID service.
        public let serviceEndpoint: DIDServiceEndpoint

        /// Initializes an instance of `DIDService`.
        ///
        /// - Parameters:
        ///   - id: A type representing a URI used within a DID Document that may be an absolute URI or a
        ///   relative fragment.
        ///   - type: A type property of a DID service, which may be a single string or an array of strings.
        ///   - serviceEndpoint: Represents the `serviceEndpoint` property of a DID service.
        public init(id: DIDRelativeURI, type: DIDServiceType, serviceEndpoint: DIDServiceEndpoint) {
            self.id = id
            self.type = type
            self.serviceEndpoint = serviceEndpoint
        }

        // Enums and Structs
        /// A type representing a URI used within a DID Document that may be an absolute URI or a relative fragment.
        public enum DIDRelativeURI: CustomStringConvertible, Codable, Equatable {

            /// A fully qualified, RFC 3986-compliant absolute URI.
            case absolute(URL)

            /// A relative fragment reference, such as `#key-1`.
            case fragment(String)

            /// Initializes a `DIDRelativeURI` from a raw string.
            ///
            /// - Parameter raw: The URI string to parse.
            ///
            /// - Throws: `DIDValidatorError.invalidDIDRelativeURI` if the input is not a valid URI or fragment.
            public init(_ did: String) throws {
                if did.hasPrefix("#"), did.dropFirst().contains("#") == false {
                    self = .fragment(did)
                    return
                }

                guard let url = URL(string: did), url.scheme != nil else {
                    throw DIDValidatorError.invalidDIDRelativeURI(did: did)
                }

                self = .absolute(url)
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let raw = try container.decode(String.self)
                self = try DIDRelativeURI(raw)
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(description)
            }

            public var description: String {
                switch self {
                    case .absolute(let url): return url.absoluteString
                    case .fragment(let fragment): return fragment
                }
            }

            public static func == (lhs: DIDRelativeURI, rhs: DIDRelativeURI) -> Bool {
                switch (lhs, rhs) {
                    case let (.absolute(a), .absolute(b)):
                        return a.absoluteString == b.absoluteString
                    case let (.fragment(a), .fragment(b)):
                        return a == b
                    default:
                        return false
                }
            }
        }

        /// Represents the `type` property of a DID service, which may be a single string or an array of strings.
        public enum DIDServiceType: Codable, Equatable {

            /// Represents a single `String` object.
            case single(String)

            /// Represents an array of `String` objects.
            case multiple([String])

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let single = try? container.decode(String.self) {
                    self = .single(single)
                } else if let multiple = try? container.decode([String].self) {
                    self = .multiple(multiple)
                } else {
                    throw DecodingError.typeMismatch(
                        DIDServiceType.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected a string or an array of strings"
                        )
                    )
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                    case .single(let value):
                        try container.encode(value)
                    case .multiple(let values):
                        try container.encode(values)
                }
            }
        }

        /// Represents the `serviceEndpoint` property of a DID service.
        public enum DIDServiceEndpoint: Codable, Equatable {

            /// A single RFC3986-compliant URI.
            case uri(URL)

            /// A key-value map with URI values.
            case map([String: URL])

            /// A list of URIs and/or maps.
            case set([DIDServiceEndpoint])

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()

                if let string = try? container.decode(String.self),
                   let url = URL(string: string), url.scheme != nil {
                    self = .uri(url)
                } else if let map = try? container.decode([String: String].self) {
                    var urlMap: [String: URL] = [:]
                    for (key, value) in map {
                        guard let url = URL(string: value), url.scheme != nil else {
                            throw DecodingError.dataCorruptedError(
                                in: container,
                                debugDescription: "Value for key '\(key)' is not a valid URI."
                            )
                        }
                        urlMap[key] = url
                    }
                    self = .map(urlMap)
                } else if let array = try? container.decode([DIDServiceEndpoint].self) {
                    guard !array.isEmpty else {
                        throw DecodingError.dataCorruptedError(
                            in: container,
                            debugDescription: "Array for serviceEndpoint must be non-empty"
                        )
                    }
                    self = .set(array)
                } else {
                    throw DecodingError.typeMismatch(
                        DIDServiceEndpoint.self,
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Expected a URI string, map of URI strings, or array of either"
                        )
                    )
                }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                    case .uri(let url):
                        try container.encode(url.absoluteString)
                    case .map(let dict):
                        let encoded = dict.mapValues { $0.absoluteString }
                        try container.encode(encoded)
                    case .set(let values):
                        try container.encode(values)
                }
            }
        }
    }

    // MARK: authentication -
    /// Represents an entry in the `authentication` array of a DID Document.
    ///
    /// This can be either a reference (e.g. `#key-1`) or an inline verification method definition.
    public enum DIDAuthentication: Codable, Equatable {

        /// A relative URI reference to a verification method.
        case reference(DIDService.DIDRelativeURI)

        /// An inline verification method object.
        case method(DIDVerificationMethod)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let raw = try? container.decode(String.self) {
                self = .reference(try DIDService.DIDRelativeURI(raw))
            } else {
                let method = try container.decode(DIDVerificationMethod.self)
                self = .method(method)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .reference(let ref):
                    try container.encode(ref.description)
                case .method(let method):
                    try container.encode(method)
            }
        }

        public static func == (lhs: DIDAuthentication, rhs: DIDAuthentication) -> Bool {
            switch (lhs, rhs) {
                case let (.reference(a), .reference(b)):
                    return a == b
                case let (.method(a), .method(b)):
                    return a == b
                default:
                    return false
            }
        }
    }

    // MARK: verificationMethod -
    /// A verification method entry in a DID Document.
    public struct DIDVerificationMethod: Codable, Equatable {

        /// The unique identifier for this service entry. Must be an RFC3986 URI or fragment.
        public let id: DIDService.DIDRelativeURI

        /// The type of verification key.
        public let type: String

        /// The controller of this verification method.
        ///
        /// It can be either a single DID or multiple DIDs.
        public let controller: DIDController

        /// A public key in JSON Web Key (JWK) format. Optional.
        public let jwkPublicKey: [String: String]?

        /// A public key encoded using multibase. Optional.
        public let multibasePublicKey: String?

        /// Initializes a `DIDVerificationMethod`.
        ///
        /// - Parameters:
        ///   - id: The identifier of the verification method (e.g. `#key-1`).
        ///   - type: The type of verification key.
        ///   - controller: The controller of this verification method.
        ///   - jwkPublicKey: A public key in JSON Web Key (JWK) format. Optional.
        ///   - multibasePublicKey: A public key encoded using multibase. Optional.
        public init(id: DIDService.DIDRelativeURI, type: String, controller: DIDController, jwkPublicKey: [String: String]? = nil,
                    multibasePublicKey: String? = nil) {
            self.id = id
            self.type = type
            self.controller = controller
            self.jwkPublicKey = jwkPublicKey
            self.multibasePublicKey = multibasePublicKey
        }
    }

    /// Represents an entry in `verificationMethod`, which can be either a reference to a verification method
    /// by URI or an inline verification method definition.
    public enum DIDVerificationMethodOrReference: Codable, Equatable {
        case reference(DIDService.DIDRelativeURI)
        case method(DIDVerificationMethod)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let raw = try? container.decode(String.self) {
                self = .reference(try DIDService.DIDRelativeURI(raw))
            } else {
                let method = try container.decode(DIDVerificationMethod.self)
                self = .method(method)
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
                case .reference(let ref): try container.encode(ref.description)
                case .method(let method): try container.encode(method)
            }
        }
    }

    // MARK: Validation -
    /// Validates W3C compliance rules such as unique service IDs.
    ///
    /// - Throws: `DIDDocumentValidatorError` if any W3C rules are violated.
    public func validateW3CCompliance() throws {
        guard let serviceArray = service else { return }

        var seen = Set<String>()
        for serviceEntry in serviceArray {
            let fullID = serviceEntry.id.description.hasPrefix("#") ? "\(id.description)\(serviceEntry.id.description)" : serviceEntry.id.description
            if seen.contains(fullID) {
                throw DIDDocumentValidatorError.duplicateServiceID(serviceID: fullID)
            }
            seen.insert(fullID)
        }
    }

    /// Validates AT Protocol-specific constraints on the DID Document.
    ///
    /// - Throws: `DIDDocumentValidatorError` if any AT Protocol-related requirements are not met.
    public func validateATProtocolCompliance() throws {
        // Handle (alsoKnownAs must contain at://[handle]).
        guard let handles = alsoKnownAs,
              let _ = handles.first(where: {
                  $0.scheme == "at" &&
                  $0.host?.isEmpty == false &&
                  ($0.path.isEmpty || $0.path == "/") &&
                  $0.query == nil &&
                  $0.fragment == nil
              }) else {
            throw DIDDocumentValidatorError.missingOrInvalidHandle
        }

        // Signing key must:
        // - Have `id` ending in `#atproto`.
        // - Use `type` "Multikey".
        // - `controller` must match the DID.
        // - `publicKeyMultibase` must start with "z" (multibase prefix).
        guard (verificationMethod?.compactMap({ entry -> DIDVerificationMethod? in
            if case let .method(method) = entry {
                return method.id.description.hasSuffix("#atproto") &&
                method.type == "Multikey" &&
                controller(method.controller, contains: id) == true &&
                method.multibasePublicKey?.starts(with: "z") == true
                ? method : nil
            }
            return nil
        }).first) != nil else {
            throw DIDDocumentValidatorError.missingOrInvalidSigningKey
        }

        // PDS entry must:
        // - Have id ending in `#atproto_pds`.
        // - `type` must be "AtprotoPersonalDataServer".
        // - `serviceEndpoint` must be a valid https:// URI (or "http://localhost").
        guard let pds = service?.first(where: { service in
            service.id.description.hasSuffix("#atproto_pds") &&
            {
                switch service.type {
                    case .single(let type): return type == "AtprotoPersonalDataServer"
                    case .multiple(let types): return types.contains("AtprotoPersonalDataServer")
                }
            }()
        }) else {
            throw DIDDocumentValidatorError.missingPDS
        }

        guard case let .uri(serviceURL) = pds.serviceEndpoint else {
            throw DIDDocumentValidatorError.invalidPDSURL
        }

        let isLocalhost = serviceURL.host == "localhost" && serviceURL.scheme == "http"
        let isSecureRemote = serviceURL.scheme == "https"

        let isCleanURL = serviceURL.user == nil &&
        serviceURL.password == nil &&
        (serviceURL.path.isEmpty || serviceURL.path == "/") &&
        serviceURL.query == nil &&
        serviceURL.fragment == nil

        guard (isLocalhost || isSecureRemote) && isCleanURL else {
            throw DIDDocumentValidatorError.invalidPDSURL
        }
    }

    /// Determines whether the decentralized identifier (DID) is found inside the `controller` portion of
    /// the DID Document.
    ///
    /// - Parameters:
    ///   - controller: The `controller` to check.
    ///   - did: The decentralized identifier (DID) to match.
    /// - Returns: `true` if the DID is found in the controller, or `false` if it doesn't.
    private func controller(_ controller: DIDController, contains did: DID) -> Bool {
        switch controller {
            case .single(let singleDID):
                return singleDID == did
            case .multiple(let multipleDIDs):
                return multipleDIDs.contains(did)
        }
    }

}
