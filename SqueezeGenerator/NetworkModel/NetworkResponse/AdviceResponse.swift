//
//  AdviceResponse.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 13.07.2025.
//

import Foundation

struct AdviceQuestionModel: Codable, Equatable, Hashable {

    let response: NetworkResponse.AdviceResponse//no need
    var save: SaveModel
    var id: UUID = .init()
    
    var resultPercent: CGFloat {
        let value = CGFloat(save.grade) / CGFloat(response.questions.totalGrade)
        if value.isFinite {
            return value
        } else {
            return 0
        }
    }

    var resultPercentInt: Int {
        Int(resultPercent * 100)
    }

    struct SaveModel: Codable, Equatable, Hashable {
        let date: Date
        var grade: Int {
            var grade: Int = 0
            questionResults.forEach { (key: NetworkResponse.AdviceResponse.QuestionResponse, value: NetworkResponse.AdviceResponse.QuestionResponse.Option) in
                grade += value.grade
            }
            return grade
        }
        /// change cat, after implementing cat from API json model
        var category: String = ""//no need
        
        var request: NetworkRequest.SqueezeRequest?
        var questionResults: [NetworkResponse.AdviceResponse.QuestionResponse: NetworkResponse.AdviceResponse.QuestionResponse.Option] = [:]
        var aiResult: NetworkResponse.ResultResponse?
    }
}

extension NetworkResponse {
    struct ResultResponse: Codable, Hashable, Equatable {
        typealias Key = NetworkRequest.ResultRequest.ResponseStructure
        var data: [NetworkRequest.ResultRequest.ResponseStructure: String]

        init(response: String) {
            data = [:]
            NetworkRequest.ResultRequest.ResponseStructure.allCases.forEach { key in
                let value = response.extractSubstring(key: key.key)
                data.updateValue(value ?? "", forKey: key)
            }
        }
    }
#warning("todo: ai about response")
    //send results
    //decalre: structure for reaponse
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

extension Date {
    var stringDate: String {
        self.formatted(date: .abbreviated, time: .shortened)
    }
}
