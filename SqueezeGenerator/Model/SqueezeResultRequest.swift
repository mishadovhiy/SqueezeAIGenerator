//
//  SqueezeResultRequest.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkRequest {
    enum SqueezeResultRequest: Codable {
        case recommendation
        case potentil
    }
}
