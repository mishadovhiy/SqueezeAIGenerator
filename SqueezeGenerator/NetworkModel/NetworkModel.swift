//
//  NetworkModel.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

struct NetworkModel {
    func appData(completion: @escaping(_ response: NetworkResponse.CategoriesResponse?)->()) {
        let request = Request(.fetchAppData)
        request.perform { data in
            let response = try? JSONDecoder().decode(NetworkResponse.CategoriesResponse.self, from: data ?? .init())
            if let token = response?.appData.tokenAI {
                Keys.openAIToken = token
            }
            completion(response)
        }
    }
    
    func advice(_ input: NetworkRequest.SqueezeRequest,
                completion: @escaping(NetworkResponse.AdviceResponse?)->()) {
        let request = Request(.squeeze(input))
        request.perform(completionn: { response in
            completion(.init(response: .init(data: response ?? .init(), encoding: .utf8) ?? ""))
        })

    }
    
    func support(_ input:NetworkRequest.SupportRequest, completion:@escaping(NetworkResponse.SupportResponse?)->()) {
        Request.init(.support(input)).perform(data: "44fdcv8jf3") { data in
            completion(.init(data: data))
        }
    }
    
    func fetchHTM(_ input:NetworkRequest.FetchHTMLRequest, completion:@escaping(_ response:NetworkResponse.FetchHTMLResponse)->()) {
        Request(.fetchHTML(input)).perform { data in
            completion(.init(data: data))
        }
    }
    
    
    func loadAppSettings(completion:@escaping()->()) {
        let sesson = URLSession.shared.dataTask(with: .init(string: Keys.apiContentURL)!) { data, response, error in
            let dict = try? JSONSerialization.jsonObject(with: data ?? .init(), options: []) as? [String: Any]
            if let token = dict?["openAIToken"] as? String {
                Keys.openAIToken = token
            } else {
                print("errorloadingtoken")
            }
            completion()
        }
        sesson.resume()
    }
}
