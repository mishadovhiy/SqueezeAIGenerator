//
//  ResultResponse.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkResponse {
    struct ResultResponse: Codable, Hashable, Equatable {
        typealias Key = NetworkRequest.ResultRequest.ResponseStructure
        var data: [NetworkRequest.ResultRequest.ResponseStructure: String]

        init(response: String) {
            data = [:]
            NetworkRequest.ResultRequest.ResponseStructure.allCases.forEach { key in
                let value = response.extractSubstring(key: key.key)
                data.updateValue(value?.replacingOccurrences(of: "\n", with: "") ?? "", forKey: key)
            }
        }
    }

}
