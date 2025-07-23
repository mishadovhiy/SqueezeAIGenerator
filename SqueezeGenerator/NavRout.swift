//
//  NavRout.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 22.07.2025.
//

import Foundation

enum NavRout: Hashable {
    case result
    case question(NetworkResponse.AdviceResponse.QuestionResponse)
    case requestToGenerateParameters(NetworkRequest.SqueezeRequest)
    case requestGenerated
}
