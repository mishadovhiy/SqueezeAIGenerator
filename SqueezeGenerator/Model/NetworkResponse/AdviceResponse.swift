//
//  AdviceResponse.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 31.08.2025.
//

import Foundation

extension NetworkResponse {
    struct AdviceResponse: Codable, Equatable, Hashable {
        private var dict:[String:String] = [:]
        
        init(data: [String : String]) {
            self.dict = data
        }
        var id: UUID = .init()
        var questions: [QuestionResponse] = []

        var textHolder: String = ""
        typealias QuestionReq = NetworkRequest.SqueezeRequest.Question
        init(response: String) {

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
            divided.forEach { str in
                print(str)
            }
            self.textHolder = divided.joined(separator: "--\n\n\n")
            
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

extension [NetworkResponse.AdviceResponse.QuestionResponse] {
    var totalGrade: Int {
        reduce(0) { partialResult, new in
            let sorted = new.options.sorted(by: {
                $0.grade >= $1.grade
            })
            return partialResult + (sorted.first?.grade ?? 0)
        }
    }
}
