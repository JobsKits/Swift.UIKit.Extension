//
//  WKUserContentController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/20/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import WebKit

@MainActor
public extension WKUserContentController {
    // MARK: - UserScripts
    @discardableResult
    func byAddUserScript(_ script: WKUserScript) -> Self {
        addUserScript(script)
        return self
    }

    @discardableResult
    func byAddUserScripts(_ scripts: [WKUserScript]) -> Self {
        scripts.forEach(addUserScript(_:))
        return self
    }
    /// 基础版：所有系统可用
    @discardableResult
    func byAddUserScript(
        source: String,
        injectionTime: WKUserScriptInjectionTime = .atDocumentEnd,
        forMainFrameOnly: Bool = false
    ) -> Self {
        let s = WKUserScript(
            source: source,
            injectionTime: injectionTime,
            forMainFrameOnly: forMainFrameOnly
        )
        addUserScript(s)
        return self
    }
    /// iOS 14+：支持 contentWorld
    @available(iOS 14.0, *)
    @discardableResult
    func byAddUserScript(
        source: String,
        injectionTime: WKUserScriptInjectionTime = .atDocumentEnd,
        forMainFrameOnly: Bool = false,
        in world: WKContentWorld
    ) -> Self {
        let s = WKUserScript(
            source: source,
            injectionTime: injectionTime,
            forMainFrameOnly: forMainFrameOnly,
            in: world
        )
        addUserScript(s)
        return self
    }

    @discardableResult
    func byRemoveAllUserScripts() -> Self {
        removeAllUserScripts()
        return self
    }
    // MARK: - Message Handlers (no-reply)
    /// 基础版（所有系统）：先移除同名再添加
    @discardableResult
    func bySetHandler(
        _ handler: (any WKScriptMessageHandler)?,
        name: String
    ) -> Self {
        removeScriptMessageHandler(forName: name)
        if let handler { add(handler, name: name) }
        return self
    }
    /// iOS 14+ 重载：带 contentWorld
    @available(iOS 14.0, *)
    @discardableResult
    func bySetHandler(
        _ handler: (any WKScriptMessageHandler)?,
        name: String,
        in world: WKContentWorld
    ) -> Self {
        removeScriptMessageHandler(forName: name, contentWorld: world)
        if let handler { add(handler, contentWorld: world, name: name) }
        return self
    }
    /// 基础版：直接添加（不先移除）
    @discardableResult
    func byAddHandler(
        _ handler: any WKScriptMessageHandler,
        name: String
    ) -> Self {
        add(handler, name: name)
        return self
    }
    /// iOS 14+ 重载：直接添加到指定 world
    @available(iOS 14.0, *)
    @discardableResult
    func byAddHandler(
        _ handler: any WKScriptMessageHandler,
        name: String,
        in world: WKContentWorld
    ) -> Self {
        add(handler, contentWorld: world, name: name)
        return self
    }
    /// 基础版：移除指定名称
    @discardableResult
    func byRemoveHandler(
        named name: String
    ) -> Self {
        removeScriptMessageHandler(forName: name)
        return self
    }
    /// iOS 14+ 重载：从指定 world 移除
    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveHandler(
        named name: String,
        in world: WKContentWorld
    ) -> Self {
        removeScriptMessageHandler(forName: name, contentWorld: world)
        return self
    }
    // MARK: - Message Handlers (with-reply)  —— 这两组本就 14+，签名里可以安全使用 WKContentWorld
    @available(iOS 14.0, *)
    @discardableResult
    func bySetHandlerWithReply(
        _ handler: (any WKScriptMessageHandlerWithReply)?,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        let w = world ?? .page
        removeScriptMessageHandler(forName: name, contentWorld: w)
        if let h = handler { addScriptMessageHandler(h, contentWorld: w, name: name) }
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byAddHandlerWithReply(
        _ handler: any WKScriptMessageHandlerWithReply,
        name: String,
        in world: WKContentWorld? = nil
    ) -> Self {
        addScriptMessageHandler(handler, contentWorld: (world ?? .page), name: name)
        return self
    }
    // MARK: - Bulk remove
    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAllHandlers(from world: WKContentWorld) -> Self {
        removeAllScriptMessageHandlers(from: world)
        return self
    }

    @available(iOS 14.0, *)
    @discardableResult
    func byRemoveAllHandlers() -> Self {
        removeAllScriptMessageHandlers()
        return self
    }
    // MARK: - Content Rule Lists
    @available(iOS 11.0, *)
    @discardableResult
    func byAddContentRuleList(_ list: WKContentRuleList) -> Self {
        add(list)
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byRemoveContentRuleList(_ list: WKContentRuleList) -> Self {
        remove(list)
        return self
    }

    @available(iOS 11.0, *)
    @discardableResult
    func byRemoveAllContentRuleLists() -> Self {
        removeAllContentRuleLists()
        return self
    }
}
