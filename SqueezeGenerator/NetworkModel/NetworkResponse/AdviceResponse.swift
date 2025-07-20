//
//  AdviceResponse.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 13.07.2025.
//

import Foundation

struct AdviceQuestionModel: Codable {
    let response: NetworkResponse.AdviceResponse
    var save: SaveModel
    var id: UUID = .init()
    struct SaveModel:Codable {
        //getter
        var grade: Int = 0
        /// change cat, after implementing cat from API json model
        var category: String = ""
        
        var request: NetworkRequest.SqueezeRequest?
        var questionResults: [NetworkRequest.SqueezeRequest.Question: NetworkRequest.SqueezeRequest.Question.Option] = [:]
    }
}

extension NetworkResponse {
    struct AdviceResponse: Codable {
        private var dict:[String:String] = [:]
        
        init(data: [String : String]) {
            self.dict = data
        }
        var id: UUID = .init()
        var questions: [QuestionResponse] = []

        var textHolder: String = ""
        typealias QuestionReq = NetworkRequest.SqueezeRequest.Question
        init(response: String) {
            print(response, "\n\n\n")
            
            var response = response.extractSubstring(key: NetworkRequest.reqStart) ?? ""
            let divided = response.components(separatedBy: "</\(String.init(describing: QuestionReq.self))>")
        
            let optionName = QuestionReq.Option.optionName.key
            let gradeName = QuestionReq.Option.grade.key
            questions = divided.compactMap({
                if let name = $0.extractSubstring(key: QuestionReq.questionName.key) {
                    let options = $0.components(separatedBy: NetworkRequest.SqueezeRequest.Question.Option.divider)
                    let description = $0.extractSubstring(key: QuestionReq.questionDescription.key)

                    return .init(questionName: name, description: description ?? "", options: options.compactMap({ optionStr in
                        let name = optionStr.extractSubstring(key: optionName)
                        let grade = optionStr.extractSubstring(key: gradeName)
                        if (name?.isEmpty ?? true) && grade == nil {
                            return nil
                        } else {
                            return .init(optionName: name ?? "", grade: Int(grade ?? "") ?? 0)
                        }
                    }).shuffled())
                } else {
                    return nil
                }
                //                .init(questionName: $0.extractSubstring(key: NetworkRequest.SqueezeRequest.Question.questionName.rawValue), options: [])
            })
            //                .compactMap({
            //                $0 + "</\(String.init(describing: NetworkRequest.SqueezeRequest.Question.self))>"
            //            })
            print(questions.count, " htrgerfd", divided.count)
            divided.forEach { str in
                print(str)
                print("--\n\n\n")
            }
            self.textHolder = divided.joined(separator: "--\n\n\n")
            print("_______\n\n", questions)
            
            
        }
    }
    
}

extension NetworkResponse.AdviceResponse {
    struct QuestionResponse:Codable, Hashable {
        let questionName: String
        let description: String
        let options: [Option]
        var id: UUID = .init()

        struct Option: Codable, Hashable {
            let optionName: String
            let grade: Int
            var id: UUID = .init()
        }
    }
}
