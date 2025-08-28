//
//  WebView.swift
//  SqueezeGenerator
//
//  Created by Mykhailo Dovhyi on 28.08.2025.
//

import SwiftUI
import WebKit

struct WebView: View {

    let type: ViewType
    @State var urlContent: String = ""

    var body: some View {
        WebViewRepresentable(html: urlContent)
            .task(priority: .background) {
                let input = type.input
                let startKey: String?
                let endKey: String?
                if let key = input.extractKey {
                    startKey = "!--\(key)--"
                    endKey = "!--/\(key)--"
                } else {
                    startKey = nil
                    endKey = nil
                }
                NetworkModel()
                    .fetchHTM(
                        .init(url: input.url),
                        extractKeyStart: startKey,
                        extractKeyEnd: endKey) { response in
                            urlContent = response.response ?? "no response from the server"
                        }
            }
    }
}

extension WebView {
    enum ViewType: Hashable, Equatable {
        static func == (lhs: WebView.ViewType, rhs: WebView.ViewType) -> Bool {
            lhs.input == rhs.input
        }

        case privacy
        case custom(_ input: Input)

        var input: Input {
            switch self {
            case .privacy: .init(url: Keys.privacyPolicy.rawValue, extractKey: "Privacy")
            case .custom(let input): input
            }
        }

        struct Input: Hashable, Equatable {
            let url: String
            let extractKey: String?

            init(url: String, extractKey: String? = nil) {
                self.url = url
                self.extractKey = extractKey
            }
        }

    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)

    }
}
