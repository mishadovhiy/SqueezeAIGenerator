//
//  ResponsePreviewModel.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 08.08.2025.
//

import Foundation

struct ResponsePreviewModel: Codable, Equatable, Hashable {
    let subcategoriesCount: Int
    let completedSubcategoriesCount: Int
    let avarageGrade: Int

    init(subcategoriesCount: Int,
         completedSubcategoriesCount: Int,
         avarageGrade: Int) {
        self.subcategoriesCount = subcategoriesCount
        self.completedSubcategoriesCount = completedSubcategoriesCount
        self.avarageGrade = avarageGrade
    }

    init(_ allCategoryList: [NetworkResponse.CategoriesResponse.Categories],
         parentDB: [AdviceQuestionModel]) {
        let sum = parentDB.reduce(0) { partialResult, category in
            return partialResult + category.resultPercent
        }
        let avarage = (sum / CGFloat(parentDB.count)) * 100
        self.init(
            subcategoriesCount: allCategoryList.count,
            completedSubcategoriesCount: parentDB.count,
            avarageGrade: avarage.isFinite ? Int(avarage) : 0
        )
    }
}
