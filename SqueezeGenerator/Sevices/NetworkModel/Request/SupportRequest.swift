//
//  SupportRequest.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkRequest {
    struct SupportRequest: Codable, Equatable, Hashable {
        var text: String = ""
        var header: String = ""
        var title: String = ""
        var error: [CodingKeys: String] = [:]

        mutating func validate() {
            error = [:]
            let errorText = "This field is mandatory"
            CodingKeys.allCases.forEach({
                if !$0.isOptional {
                    switch $0 {
                    case .title:
                        if self.title.isEmpty {
                            error.updateValue(errorText, forKey: $0)
                        }
                    case .header:
                        if self.header.isEmpty {
                            error.updateValue(errorText, forKey: $0)
                        }
                    case .text:
                        if self.text.isEmpty {
                            error.updateValue(errorText, forKey: $0)
                        }
                    }
                }
            })
        }
                
        enum CodingKeys: CodingKey, CaseIterable {
            case text
            case header
            case title
            
            var isOptional: Bool {
                switch self {
                case .text: false
                default: true
                }
            }
        }
    }
}
