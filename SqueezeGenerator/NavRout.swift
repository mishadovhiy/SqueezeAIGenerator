//
//  NavRout.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import Foundation
import SwiftUI

enum NavRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
    case requestToGenerateParameters(NetworkRequest.SqueezeRequest)
    case requestGenerated
    case empty
    case cardView(CardsViewModel.ViewProperties)
    
    var needDoneButton: Bool {
        switch self {
        case .requestToGenerateParameters,
                .requestGenerated, .requestToGenerateParameters
            :
            true
        default:
            false
        }
    }
}
