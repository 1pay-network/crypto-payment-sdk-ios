# 1PAY.network - Crypto Payment SDK

Website: [1pay.network](https://1pay.network)

Documents: [1pay.network/documents](https://1pay.network/documents)

Full example of 1PAY.network integration for iOS, MacOS app using Swift

> Focus on file /Demo1Pay/PaymentWebView.swift

```swift
import Foundation
import SwiftUI
import WebKit

class WVDelegate: NSObject, WKUIDelegate, WKNavigationDelegate {

    // Handle deeplink for open wallet client app
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let scheme = url.scheme {
            if !scheme.starts(with: "http") {
                if UIApplication.shared.canOpenURL(url){
                    // use the available apps in user's phone
                    UIApplication.shared.open(url)
                }
            }
        }
        decisionHandler(.allow)
    }

    // Handle link open new tab (<a> tag with target="_blank")
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
}

struct PaymentResponse {
    let hash: String?
    let success: Bool
    let amount: Float
    let token: String
    let network: String
    let note: String
}

extension URLComponents {
    func getQueryParameter(_ key: String) -> String? {
        return self.queryItems?.first(where: { $0.name == key })?.value
    }
}

struct PaymentWebView: UIViewRepresentable {
    // 1
    let url: URL

    private let webview = WKWebView()
    private let delegate = WVDelegate()
    private var urlChangedObsever: NSKeyValueObservation? = nil
    private var onSuccess: ((PaymentResponse) -> Void)? = nil
    private var onFail: ((PaymentResponse) -> Void)? = nil

    init(url: URL) {
        self.url = url
        self.urlChangedObsever = webview.observe(\.url, options: .new) { [self] wv, url in
            if let _url = url.newValue, let urlString = _url?.absoluteString {
                if (urlString.contains("1pay.network")) {
                    // Handle response, for more information, please read doc
                    if (urlString.contains("success")) {
                        // Handle success, you can parse query parameters from urlString to get response
                        // You can implement callback to handle it by yourself
                        print("PaymentWebview Success")
//                        onSuccess?.(PaymentResponse())
                    } else if (urlString.contains("fail")) {
                        // Handle fail
                        let response = self.parseResult(urlString)
                        print("PaymentWebview Failed with Response=\(response)")
//                        onFail?.(PaymentResponse())
                    }
                }
            }
        }
    }

    private func parseResult(_ url: String) -> PaymentResponse? {
        guard let _urlComps = URLComponents(string: url) else { return nil }
        let hash = _urlComps.getQueryParameter("hash")
        let success = Bool(_urlComps.getQueryParameter("success") ?? "false") ?? false
        var amount = NumberFormatter().number(from: _urlComps.getQueryParameter("amount") ?? "0")?.floatValue ?? 0.0
        let token = _urlComps.getQueryParameter("token") ?? ""
        let network = _urlComps.getQueryParameter("network") ?? ""
        let note = _urlComps.getQueryParameter("note") ?? ""
        return PaymentResponse(
            hash: hash,
            success: success,
            amount: amount,
            token: token,
            network: network,
            note: note
        )
    }

    // 2
    func makeUIView(context: UIViewRepresentableContext<PaymentWebView>) -> WKWebView {
        webview.navigationDelegate = delegate
        webview.uiDelegate = delegate
        return webview
    }

    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func onepaySuccess(_ action: @escaping (PaymentResponse) -> Void) -> Self {
        var copy = self
        copy.onSuccess = action
        return copy
    }

    func onepayFail(_ action: @escaping (PaymentResponse) -> Void) -> Self {
        var copy = self
        copy.onFail = action
        return copy
    }
}
```
