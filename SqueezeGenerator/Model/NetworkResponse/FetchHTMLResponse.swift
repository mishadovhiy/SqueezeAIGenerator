//
//  FetchHTMLResponse.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkResponse {
    struct FetchHTMLResponse:Codable {

        let response: String?

        init(data: Data?, extractedKeyStart: String? = nil, extractedKeyEnd: String? = nil) {
            var response = String(data: data ?? .init(), encoding: .utf8) ?? ""
            if let extractedKeyStart, let extractedKeyEnd {
                response = response.extractSubstring(key: extractedKeyStart, key2: extractedKeyEnd) ?? response
            }
            self.response = """
<!DOCTYPE html>
<html lang="en">
<head>
</head>
<style>
html, body{background: #3A3A3A;}
h2{ font-size: 18px; color: white; }h1{font-size: 32px; color: white;}
p{font-size: 12px; color: white;}
</style>
<body>
""" + response + """
    </body>
    </html>
    """
        }
    }

}
