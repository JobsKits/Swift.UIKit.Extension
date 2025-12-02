//
//  WKWebViewConfiguration.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/20/25.
//

import WebKit
// 统一在主线程（WKWebViewConfiguration 本身就是 @MainActor）
@MainActor
public extension WKWebViewConfiguration {
    // MARK: - 工厂
    static func make(_ configure: (inout WKWebViewConfiguration) -> Void) -> WKWebViewConfiguration {
        var ct = WKWebViewConfiguration()
        configure(&ct)
        return ct
    }
    // MARK: - 基础
    #if compiler(>=5.10)
    @available(iOS, introduced: 8.0, deprecated: 15.0, message: "Multiple WKProcessPool instances no longer matter.")
    #endif
    @discardableResult
    func byProcessPool(_ pool: WKProcessPool) -> Self {
        self.processPool = pool; return self
    }
    /// 直接拿到 `preferences` 引用修改（WKPreferences 是引用类型）
    @discardableResult
    func byPreferences(_ edit: (WKPreferences) -> Void) -> Self {
        edit(self.preferences); return self
    }

    @discardableResult
    func byUserContentController(_ ucc: WKUserContentController) -> Self {
        self.userContentController = ucc; return self
    }

    @available(iOS 18.4, *)
    @discardableResult
    func byWebExtensionController(_ controller: WKWebExtensionController?) -> Self {
        self.webExtensionController = controller; return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    func byWebsiteDataStore(_ store: WKWebsiteDataStore) -> Self {
        self.websiteDataStore = store; return self
    }

    @discardableResult
    func bySuppressesIncrementalRendering(_ on: Bool = true) -> Self {
        self.suppressesIncrementalRendering = on; return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    func byApplicationNameForUserAgent(_ suffix: String?) -> Self {
        self.applicationNameForUserAgent = suffix; return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    func byAllowsAirPlayForMediaPlayback(_ on: Bool = true) -> Self {
        self.allowsAirPlayForMediaPlayback = on; return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byShowsSystemScreenTimeBlockingView(_ on: Bool = true) -> Self {
        self.showsSystemScreenTimeBlockingView = on; return self
    }

    @available(iOS 14.5, *)
    @discardableResult
    func byUpgradeKnownHostsToHTTPS(_ on: Bool = true) -> Self {
        self.upgradeKnownHostsToHTTPS = on; return self
    }

    @available(iOS 10.0, *)
    @discardableResult
    func byMediaTypesRequiringUserActionForPlayback(_ types: WKAudiovisualMediaTypes) -> Self {
        self.mediaTypesRequiringUserActionForPlayback = types; return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byDefaultWebpagePreferences(_ edit: (WKWebpagePreferences) -> Void) -> Self {
        // 注意：属性是 @NSCopying；读出来（若为 nil 就新建），编辑后再回设
        let p = self.defaultWebpagePreferences ?? WKWebpagePreferences()
        edit(p)
        self.defaultWebpagePreferences = p
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byLimitsNavigationsToAppBoundDomains(_ on: Bool = true) -> Self {
        self.limitsNavigationsToAppBoundDomains = on; return self
    }

    @available(iOS 17.0, *)
    @discardableResult
    func byAllowsInlinePredictions(_ on: Bool = true) -> Self {
        self.allowsInlinePredictions = on; return self
    }

    @discardableResult
    func byAllowsInlineMediaPlayback(_ on: Bool = true) -> Self {
        self.allowsInlineMediaPlayback = on; return self
    }

    @available(iOS, introduced: 8.0, deprecated: 11.0, message: "Ignored since iOS 11; selection is always character.")
    @discardableResult
    func bySelectionGranularity(_ g: WKSelectionGranularity) -> Self {
        self.selectionGranularity = g; return self
    }

    @available(iOS 9.0, *)
    @discardableResult
    func byAllowsPictureInPictureMediaPlayback(_ on: Bool = true) -> Self {
        self.allowsPictureInPictureMediaPlayback = on; return self
    }

    @available(iOS 10.0, *)
    @discardableResult
    func byDataDetectorTypes(_ types: WKDataDetectorTypes) -> Self {
        self.dataDetectorTypes = types; return self
    }

    @available(iOS 10.0, *)
    @discardableResult
    func byIgnoresViewportScaleLimits(_ on: Bool = true) -> Self {
        self.ignoresViewportScaleLimits = on; return self
    }
    // MARK: - URL Scheme Handler
    @available(iOS 11.0, *)
    @discardableResult
    func byURLSchemeHandler(_ handler: (any WKURLSchemeHandler)?, for scheme: String) -> Self {
        self.setURLSchemeHandler(handler, forURLScheme: scheme); return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byRemoveURLSchemeHandler(for scheme: String) -> Self {
        self.setURLSchemeHandler(nil, forURLScheme: scheme); return self
    }
    // MARK: - iOS 18+
    @available(iOS 18.0, *)
    @discardableResult
    func bySupportsAdaptiveImageGlyph(_ on: Bool = true) -> Self {
        self.supportsAdaptiveImageGlyph = on; return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byWritingToolsBehavior(_ behavior: UIWritingToolsBehavior) -> Self {
        self.writingToolsBehavior = behavior; return self
    }
}
