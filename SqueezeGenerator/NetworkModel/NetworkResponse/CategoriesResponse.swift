//
//  CategoriesResponse.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 20.07.2025.
//

import Foundation

extension NetworkResponse {
    struct CategoriesResponse: Codable {
        let appData: AppData
        let categories: [Categories]
        
        struct Categories: Codable {
            let name: String
            let description: String
            let list: [Categories]?
            let resultType: String?
            var id: String
            
//            var resultValueType: ResultType? {
//                .init(rawValue: resultType ?? "")
//            }
            enum ResultType: String {
                case grade
            }
        }
        
        struct AppData: Codable {
            let tokenAI: String
        }
    }
}
