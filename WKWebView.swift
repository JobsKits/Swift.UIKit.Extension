//
//  WKWebView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

import WebKit

extension WKWebView {
    @discardableResult
    func loadURL(_ urlString: String) -> Self {
        guard let url = URL(string: urlString) else { return self }
        let request = URLRequest(url: url)
        self.load(request)
        return self
    }

    @discardableResult
    func loadRequest(_ request: URLRequest) -> Self {
        self.load(request)
        return self
    }

    @discardableResult
    func byNavigationDelegate(_ delegate: WKNavigationDelegate?) -> Self {
        self.navigationDelegate = delegate
        return self
    }

    @discardableResult
    func byUIDelegate(_ delegate: WKUIDelegate?) -> Self {
        self.uiDelegate = delegate
        return self
    }

    @discardableResult
    func byAllowsBackForwardNavigationGestures(_ enabled: Bool) -> Self {
        self.allowsBackForwardNavigationGestures = enabled
        return self
    }
    /// 统一开关：iOS14+ 走 allowsContentJavaScript；更低版本回落到 preferences.javaScriptEnabled
    @discardableResult
    func byAllowsJavaScript(_ enabled: Bool) -> Self {
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = enabled
        } else {
            configuration.preferences.javaScriptEnabled = enabled
        };return self
    }
}

@MainActor
public extension WKWebView {
    /// fire-and-forget：不关心回调
    func jobsEval(_ js: String) {
        if #available(iOS 15.0, *) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                _ = try? await self.evaluateJavaScript(js)
            }
        } else {
            self.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    /// 带回调（@Sendable 友好）
    func jobsEval(_ js: String,
                  completion: (@MainActor @Sendable (Any?, Error?) -> Void)?) {
        if #available(iOS 15.0, *) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let result = try await self.evaluateJavaScript(js)
                    completion?(result, nil)
                } catch {
                    completion?(nil, error)
                }
            }
        } else {
            self.evaluateJavaScript(js, completionHandler: completion)
        }
    }
}
