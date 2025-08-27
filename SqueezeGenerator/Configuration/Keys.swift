//
//  Keys.swift
//  SqueezeAI
//
//  Created by Mykhailo Dovhyi on 07.07.2025.
//

import Foundation

enum Keys:String {
    case openAIChatURL = "https://api.openai.com/v1/chat/completions"
    case appStoreID = "6744907347"
    case websiteURL = "https://mishadovhiy.com/#advicercv"
    case privacyPolicy = "https://mishadovhiy.com/apps/previews/advicercv.html"
    case apiBaseURL = "https:/mishadovhiy.com/apps/other-apps-db"
    static var shareAppURL:String = "https://apps.apple.com/app/id\(Keys.appStoreID.rawValue)"
    case adMob = "ca-app-pub-5463058852615321/1570079410"
    
    static var openAIToken:String = ""
    static var apiContentURL: String {
        Keys.apiBaseURL.rawValue + "/" + "moviesDB/randomMovie.json"
    }
}
