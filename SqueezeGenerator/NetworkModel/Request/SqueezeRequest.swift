//
//  SqueezeRequest.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 13.07.2025.
//

import Foundation

extension NetworkRequest {
    static let reqStart = "requstStart"

    struct SqueezeRequest:Codable {
        var type: String
        var category: String
        var description: String
        
        static let `default`: Self = .init(type: "mental health", category: "Schizophrenia", description: "deep, obvious symptoms that strongly represents illness")
        
        enum Question: String, Codable, OpenAIPrompt, CaseIterable {
            
            static var divider: String { .init(describing: Self.self) }
            
            case questionName
            case questionDescription
            case options
            
            var key: String {
                rawValue
            }
            
            var subOptionType: [OpenAIPrompt.Type]? {
                switch self {
                case .options:
                    [Option.self]
                default: nil
                }
            }
            
            var subOption: String? {
                switch self {
                case .options: Option.allCases.compactMap({
                    "<" + $0.rawValue + ">" + $0.keyDescription + "</" + $0.rawValue + ">"
                }).joined(separator: "")
                default: nil
                }
            }
            
            var keyDescription: String {
                switch self {
                case .questionName:
                    ""
                case .options:
                    "2-6 options if possible"
                case .questionDescription: "description or examples"
                }
            }
            
            enum Option: String, Codable, OpenAIPrompt, CaseIterable {
                var subOptionType: [any NetworkRequest.OpenAIPrompt.Type]? { nil }
                
                case optionName
                case grade
                         
                var key: String {
                    rawValue
                }
            
                static var divider: String { .init(describing: Self.self) }

                var keyDescription: String {
                    switch self {
                    case .optionName:
                        "possible answare"
                    case .grade:
                        "grade for selected option"
                    }
                }
            }
            
            enum Response: String, OpenAIPrompt, CaseIterable {
                case title
                case description
                case minGrade
                case maxGrade
                static var divider: String { .init(describing: Self.self) }
                var subOptionType: [any NetworkRequest.OpenAIPrompt.Type]? { nil }

                var keyDescription: String {
                    switch self {
                    case .title:
                        "large title for possible score"
                    case .description:
                        "detailed description about this score, in 4-10 sentences"
                    case .minGrade, .maxGrade:
                        "number"
                    }
                }
            }
            
        }
        
        var dict:[String:String] = [:]
        

    }

}
