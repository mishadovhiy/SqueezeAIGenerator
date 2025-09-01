//
//  SqueezeRequest.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 13.07.2025.
//

import Foundation

extension NetworkRequest {
    static let reqStart = "requstStart"

    struct ResultRequest: Codable, Equatable, Hashable {
        let parentCategory: String
        let category: String
        let gradePercent: String
        let scoreDescription: String?


        init(parentCategory: String, category: String, gradePercent: String, scoreDescription: String?) {
            self.parentCategory = parentCategory
            self.category = category
            self.gradePercent = gradePercent
            self.scoreDescription = scoreDescription ?? "the level of knowledge"
        }
        enum ResponseStructure: String, Codable, CaseIterable, OpenAIPrompt {
            var keyDescription: String {
                switch self {
                case .description:
                    "5-8 sentences (or longer) description"
                case .gradeInNormalRange:
                    "yes, medium or no"
                case .advice:
                    "list"
                }
            }

            static var divider: String { .init(describing: Self.self) }

            var subOptionType: [any NetworkRequest.OpenAIPrompt.Type]? {
                return nil
            }

            case gradeInNormalRange, description, advice
#warning("rawValue causes compiler error for some reasons")
            var key: String {
                rawValue
            }
        }
    }
}
