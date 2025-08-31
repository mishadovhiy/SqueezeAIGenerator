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

#warning("todo: refactor")
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
        var apiCategory: NetworkResponse.CategoriesResponse.Categories?
        var request: NetworkRequest.SqueezeRequest?
        var questionResults: [NetworkResponse.AdviceResponse.QuestionResponse: NetworkResponse.AdviceResponse.QuestionResponse.Option] = [:]
        var aiResult: NetworkResponse.ResultResponse?
    }
}

