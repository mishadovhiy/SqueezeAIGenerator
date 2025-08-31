//
//  NetworkModel.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

struct NetworkModel {
    func appData(completion: @escaping(_ response: NetworkResponse.CategoriesResponse?)->()) {
        let request = NetworkRequestManager(.fetchAppData)
        request.perform { data in
            do {
                let response = try JSONDecoder().decode(NetworkResponse.CategoriesResponse.self, from: data ?? .init())
                Keys.openAIToken = response.appData.tokenAI

                DispatchQueue.main.async {
                    completion(response)
                }
            }
            catch {
                fatalError(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func advice(_ input: NetworkRequest.SqueezeRequest,
                completion: @escaping(NetworkResponse.AdviceResponse?)->()) {
        let request = NetworkRequestManager(.squeeze(input))
        request.perform(completionn: { response in
            completion(.init(response: .init(data: response ?? .init(), encoding: .utf8) ?? ""))
        })

    }

    func result(_ input: NetworkRequest.ResultRequest,
                completion: @escaping(NetworkResponse.ResultResponse?)->()) {
        let request = NetworkRequestManager(.result(input))
        request.perform(completionn: { response in
            DispatchQueue.main.async {
                completion(.init(response: .init(data: response ?? .init(), encoding: .utf8) ?? ""))
            }
        })

    }

    func support(_ input:NetworkRequest.SupportRequest, completion: @escaping(NetworkResponse.SupportResponse?)->()) {
        NetworkRequestManager.init(.support(input)).perform(data: "44fdcv8jf3") { data in
            DispatchQueue.main.async {
                completion(.init(data: data))
            }
        }
    }
    
    func fetchHTM(
        _ input:NetworkRequest.FetchHTMLRequest,
        extractKeyStart: String? = nil, extractKeyEnd: String? = nil,
        completion:@escaping(_ response:NetworkResponse.FetchHTMLResponse)->()
    ) {
        NetworkRequestManager(.fetchHTML(input)).perform { data in
            DispatchQueue.main.async {
                completion(.init(data: data, extractedKeyStart: extractKeyStart, extractedKeyEnd: extractKeyEnd))
            }
        }
    }
    
    
    func loadAppSettings(completion:@escaping()->()) {
        let sesson = URLSession.shared.dataTask(with: .init(string: Keys.apiContentURL)!) { data, response, error in
            let dict = try? JSONSerialization.jsonObject(with: data ?? .init(), options: []) as? [String: Any]
            if let token = dict?["openAIToken"] as? String {
                Keys.openAIToken = token
            } else {
            }
            completion()
        }
        sesson.resume()
    }
}
