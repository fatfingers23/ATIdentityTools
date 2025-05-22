//
//  Utilities.swift
//  ATIdentityTools
//
//  Created by Christopher Jr Riley on 2025-05-21.
//

import Foundation

extension String {

    /// Encodes the string for safe inclusion in a URI component.
    ///
    /// This is to more cloestly mimic JavaScript's `encodeURIComponent` behavior.
    ///
    /// Note: If the encoding fails, the original string will be returned.
    ///
    /// Example usage:
    /// ```
    /// let raw = "user:example/did"
    /// let encoded = raw.encodedForURIComponent
    /// // encoded is "user%3Aexample%2Fdid"
    /// ```
    var encodedForURIComponent: String {
        // This matches JavaScript's encodeURIComponent behavior
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)

        return self.addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}
