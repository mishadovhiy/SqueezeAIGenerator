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
            var list: [Categories]?
            let resultType: String?
            var id: String
            let color: Color?
            var imageURL: String?
            
            struct Color: Codable, Equatable, Hashable {
                let tint: String?
                let topLeft: String?
                let top: String?
                let left: String?
                let right: String?
                let bottom: String
                let bottomRight: String?
            }

//            var resultValueType: ResultType? {
//                .init(rawValue: resultType ?? "")
//            }
            enum ResultType: String {
                case grade
            }
        }
        
        struct AppData: Codable {
            let tokenAI: String
            let settings: Settings
            
            struct Settings: Codable {
                let canShowAdds: Bool
            }
        }
    }
}
