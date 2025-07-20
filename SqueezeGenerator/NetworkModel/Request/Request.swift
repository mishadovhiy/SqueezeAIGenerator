//
//  Request.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

extension NetworkModel {
    struct Request {
        var request:URLRequest?
        
        init(_ input: NetworkRequest, cashed: Bool = false) {
            switch input {
            case .fetchHTML(let url):
                if let url:URL = .init(string: url.url) {
                    request = .init(url: url)
                    request?.httpMethod = "GET"
                }
                
            case .squeeze:
                request = URLRequest(url: .init(string: Keys.openAIChatURL.rawValue)!)
                
                let prompt = input.promt
                print(prompt, " openaiprompt")
                let jsonBody: [String: Any] = [
                    "model": "gpt-3.5-turbo",
                    "messages": [
                        ["role": "system", "content": "You are a helpful assistant."],
                        ["role": "user", "content": prompt]
                    ],
                    "max_tokens": 4096
                ]
                guard let httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
                    print("Error serializing JSON")
                    request = nil
                    return
                }
                let token = Keys.openAIToken
                
                request?.httpMethod = "POST"
                request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request?.httpBody = httpBody
                
            case .support(let supportInput):
                let toDataString = "emailTitle=\(supportInput.title)&emailHead=\(supportInput.header)&emailBody=\(supportInput.text)"
                guard let url:URL = .init(string: "https://www.mishadovhiy.com/apps/" + "budget-tracker-db/sendEmail.php?\(toDataString)") else {
                    request = nil
                    return
                }
                request = URLRequest(url: url)
                request?.httpMethod = "POST"
            case .fetchAppData:
                guard let url:URL = .init(string: "https://www.mishadovhiy.com/apps/" + "other-apps-db/generalSqueeze/general.json") else {
                    request = nil
                    return
                }
                request = URLRequest(url: url)
                request?.httpMethod = "GET"
            }
            
        }
        
        func perform(data:String = "",
                     completionn: @escaping(_ data: Data?)->()) {
            if request?.httpMethod != "POST" {
                self.uploadRequest(data: data, completion: {
                    completionn($0)
                })
            } else {
                self.performRequest(completion: { response in
                    print("okkk")
                    completionn(response)
                })
            }
        }
        
        fileprivate func performRequest(data:String = "", completion:@escaping(_ data: Data?)->()) {
            guard let request else {
                completion(nil)
                return
            }
            let session = URLSession.shared.dataTask(with: request) { data, response, error in
                completion(data)
            }
            session.resume()
        }
        
        fileprivate func uploadRequest(data:String = "", completion:@escaping(_ data: Data?)->()) {
            guard let request else {
                completion(nil)
                return
            }
            let data = data.data(using: .utf8)
            
            let uploadJob = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
                let returnedData = NSString(data: data ?? .init(), encoding: String.Encoding.utf8.rawValue)
                print(returnedData, " egrfweds ")
                if error != nil {
                    completion(nil)
                    return
                }
                completion(data)
            }
            uploadJob.resume()
        }
        
    }
}
