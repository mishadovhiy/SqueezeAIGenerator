//
//  NetworkRequest.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

enum NetworkRequest:Codable {
    case support(SupportRequest)
    case squeeze(SqueezeRequest)
    case fetchHTML(FetchHTMLRequest)
    case fetchAppData
    
    var advice:SqueezeRequest? {
        switch self {
        case .squeeze(let advice):
            return advice
        default:return nil
        }
    }
    var promt:String {
        switch self {
        case .fetchHTML:
            return ""
        case .squeeze(let advice):
            var result = advice
            if result.category.isEmpty {
                result.category = SqueezeRequest.default.category
            }
            if result.type.isEmpty {
                result.type = SqueezeRequest.default.type
            }
            if result.description.isEmpty {
                result.description = SqueezeRequest.default.description
            }
            let pro =  """
             generate squeeze for \(result.type) test on \(result.category), representing questions - \(result.description). structure: <requstStart> each question wrapp in structure:\(SqueezeRequest.Question.prompt).</requstStart>. minimum 20 questions. questions difficulty is: \(result.difficulty?.rawValue ?? "")
             """
            print(pro)
            return pro
            /**
             provide response for each total grade range options in structure:\(SqueezeRequest.Question.Response.allCases.compactMap({
             "<" + $0.rawValue + ">" + $0.keyDescription + "</" + $0.rawValue + ">"
             }))
             */
            //generate request
            //choose cv button
            //job title
            //top skills
            //desireble job or job duties
            //
        default:return ""
        }
    }
    
}

extension NetworkRequest {
    protocol OpenAIPrompt: CaseIterable {
        var keyDescription: String { get }
        static var divider: String { get }
        var subOptionType: [any OpenAIPrompt.Type]? { get }
        associatedtype RawValue
        var rawValue: RawValue { get }
    }
    
    
    struct SupportRequest:Codable {
        var text:String = ""
        var header:String = ""
        var title:String = ""
    }
    
    struct FetchHTMLRequest:Codable {
        var url:String
    }
    
    
    enum SqueezeResultRequest: Codable {
        case recommendation
        case potentil
    }
    
    protocol ResponseKeys:CaseIterable {
        /// describes response for request
        var valueDescription:String { get }
        var identifier:String { get }
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
