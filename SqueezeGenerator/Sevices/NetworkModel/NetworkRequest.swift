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
    case result(ResultRequest)
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
        case .result(let request):
            print(request.category, " rgefwdas ")
            return """
            You are a compassionate \(request.parentCategory.addSpaceBeforeCapitalizedLetters) assistant. A user has completed a test. Their selected category is \(request.category.addSpaceBeforeCapitalizedLetters) in parent category \(request.parentCategory.addSpaceBeforeCapitalizedLetters). Their test score is \(request.gradePercent) out of 100, which indicates \(request.scoreDescription ?? ""). Generate result for completed squeeze in structure: \(ResultRequest.ResponseStructure.prompt) 
            """
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
        default:return ""
        }
    }
    
}

extension NetworkRequest {
    
    protocol ResponseKeys:CaseIterable {
        /// describes response for request
        var valueDescription:String { get }
        var identifier:String { get }
    }
}
