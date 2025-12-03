//
//  String+系统功能调用.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

import MessageUI
import CoreImage
// MARK: 一行打开：网址(任何支持的 URL scheme) 、一行拨号、发邮件
@MainActor
public extension String {
    // 内部委托：托管 MFMailComposeViewController 的回调与收尾
    fileprivate final class _JobsMailProxy: NSObject, @MainActor MFMailComposeViewControllerDelegate {
        static let shared = _JobsMailProxy()
        var completion: ((JobsOpenResult) -> Void)?

        @MainActor func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) { [completion] in
                // 这层 API 只关心“是否成功调起”，这里统一回调 .opened
                completion?(.opened)
            };self.completion = nil
        }
    }
    /// 一行打开：网址 / 任何支持的 URL scheme
    /// 例子：
    /// "www.baidu.com".open()
    /// "https://example.com?q=中文".open()
    /// "weixin://".open()
    /// 返回结果仅表示“是否成功调起系统打开”，并不保证目标 App 内部行为成功
    @discardableResult
    func open(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {
        // 1) 预处理：去空白 + 尝试补 scheme + 百分号编码
        guard let url = Self.makeURL(from: self) else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 2) canOpenURL（系统判断是否能调起）
        guard UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        // 3) iOS 10+ 统一走 open(_:options:completionHandler:)
        UIApplication.shared.open(url, options: options) { ok in
            completion?(ok ? .opened : .cannotOpen)
        };return .opened
    }
    /// 一行拨号
    /// 例子：
    /// "13434343434".call()                 // 直接走 tel://（停留在电话 App）
    /// "13434343434".call(usePrompt: true)  // 用 telprompt://（回到 App；有被拒历史，谨慎）
    ///
    /// 审核前瞻（实话实说）：
    /// - `telprompt://` 曾有被拒案例，**能不用就不用**。默认关。
    /// - 模拟器不支持拨号；真机的家长控制/MDM 也可能拦截。
    @discardableResult
    func call(usePrompt: Bool = false,
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {

        #if targetEnvironment(simulator)
        // ================== 模拟器环境直接拦截 ==================
        print("📵 模拟器不支持拨号功能")
        Task { @MainActor in
            print("📵 模拟器不支持拨号功能")
        }
        completion?(.cannotOpen)
        return .cannotOpen
        #else
        // ================== 真机执行逻辑 ==================
        // 1) 规整号码：仅保留数字与前导 '+'（其余全剔除）
        let sanitized = Self.sanitizePhone(self)
        guard !sanitized.isEmpty else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 2) 生成 tel / telprompt URL
        let scheme = usePrompt ? "telprompt://" : "tel://"
        guard let url = URL(string: scheme + sanitized) else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 3) canOpenURL
        guard UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        UIApplication.shared.open(url, options: [:]) { ok in
            completion?(ok ? .opened : .cannotOpen)
        }
        return .opened
        #endif
    }
    /// 一行发邮件（优先原生 Mail VC；不可用时回退 mailto://）
    ///
    /// - Parameters:
    ///   - subject: 邮件主题
    ///   - body: 正文
    ///   - isHTML: 正文是否为 HTML
    ///   - cc / bcc: 抄送/密送（可多收件人）
    ///   - presentFrom: 指定展示 VC（不传则自动找顶层 VC）
    /// - Note:
    ///   - 支持 "a@b.com" 或 "a@b.com,b@c.com; d@e.com" 这样的分隔（逗号/分号/空格）
    ///   - 模拟器一般 `canSendMail == false`，会自动走 `mailto:` 回退
    @discardableResult
    func mail(subject: String? = nil,
              body: String? = nil,
              isHTML: Bool = false,
              cc: [String] = [],
              bcc: [String] = [],
              presentFrom: UIViewController? = nil,
              completion: ((JobsOpenResult) -> Void)? = nil) -> JobsOpenResult {

        let tos = Self._parseEmails(self)
        guard !tos.isEmpty else {
            completion?(.invalidInput)
            return .invalidInput
        }
        // 1) 优先走系统邮件编辑器
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.setToRecipients(tos)
            if let subject { vc.setSubject(subject) }
            if let body    { vc.setMessageBody(body, isHTML: isHTML) }
            if !cc.isEmpty { vc.setCcRecipients(Self._parseEmails(cc.joined(separator: ","))) }
            if !bcc.isEmpty { vc.setBccRecipients(Self._parseEmails(bcc.joined(separator: ","))) }
            vc.mailComposeDelegate = _JobsMailProxy.shared
            // 顶层展示 VC
            let host = presentFrom
                ?? UIApplication.jobsKeyWindow()?.rootViewController
                ?? UIViewController()

            _JobsMailProxy.shared.completion = completion
            host.present(vc, animated: true, completion: nil)
            return .opened
        }
        // 2) 回退：mailto://
        guard let url = Self._makeMailtoURL(to: tos, subject: subject, body: body, cc: cc, bcc: bcc),
              UIApplication.shared.canOpenURL(url) else {
            completion?(.cannotOpen)
            return .cannotOpen
        }
        UIApplication.shared.open(url, options: [:]) { ok in
            completion?(ok ? .opened : .cannotOpen)
        };return .opened
    }
}
