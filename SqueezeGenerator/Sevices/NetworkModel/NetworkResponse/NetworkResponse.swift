//
//  NetworkResponse.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

struct NetworkResponse {
    struct FetchHTMLResponse:Codable {
        private let data:Data?
        init(data: Data?) {
            self.data = data
        }
        var response:String {
            String(data: data ?? .init(), encoding: .utf8) ?? ""
        }
    }
    
    
    struct SupportResponse: Codable {
        private let data:Data?
        private var ok:String {
            NSString(data: data ?? .init(), encoding: String.Encoding.utf8.rawValue)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        init(data: Data?) {
            self.data = data
        }
        var success:Bool {
            return ok == "1"
        }
    }
}
