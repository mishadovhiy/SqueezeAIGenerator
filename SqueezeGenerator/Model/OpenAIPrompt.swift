//
//  OpenAIPrompt.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkRequest {
    protocol OpenAIPrompt: CaseIterable {
        var keyDescription: String { get }
        static var divider: String { get }
        var subOptionType: [any OpenAIPrompt.Type]? { get }
        associatedtype RawValue
        var rawValue: RawValue { get }
    }
}

extension NetworkRequest.OpenAIPrompt {
    
    static var prompt: String {
        "<\(Self.divider)>" + Self.allCases.compactMap { key in
            let suboptions: String
            if let suboptionType = key.subOptionType {
                suboptions = suboptionType.compactMap({
                    $0.prompt
                }).joined()
            } else {
                suboptions = ""
            }
            //= "in structure: \($0.subOption ?? "")" + "add key after last option:"
            return "<\(key.rawValue)>" + key.keyDescription + "</\(key.rawValue)>" + suboptions
        }.joined() + "</\(Self.divider)>"
        
    }
}
