//
//  SupportRequest.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkRequest {
    struct SupportRequest:Codable {
        var text:String = ""
        var header:String = ""
        var title:String = ""
    }
}
