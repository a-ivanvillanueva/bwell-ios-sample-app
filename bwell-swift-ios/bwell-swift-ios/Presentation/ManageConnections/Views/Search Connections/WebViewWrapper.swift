//
//  WebViewWrapper.swift
//  bwell-swift-ios
//
//  Created by Ivan Villanueva on 07/11/25.
//
import Foundation
import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    var onSuccess: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()

        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.onSuccess = onSuccess
        // let request = URLRequest(url: url)
        // uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess)
    }


    final class Coordinator: NSObject, WKNavigationDelegate {
        var onSuccess: () -> Void

        init(onSuccess: @escaping () -> Void) {
            self.onSuccess = onSuccess
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, url.absoluteString.contains("status_code=success") {
                onSuccess()
                decisionHandler(.cancel)

                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Log.connections.error("Web view not load the page: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Log.connections.error("Web view failed whiel loading: \(error.localizedDescription)")
        }
    }
}
