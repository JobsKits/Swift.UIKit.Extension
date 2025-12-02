//
//  String.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import MessageUI
import CoreImage
import Foundation

#if canImport(Kingfisher)
import Kingfisher
#endif

#if canImport(SDWebImage)
import SDWebImage
#endif

#if canImport(JobsSwiftBaseDefines)
import JobsSwiftBaseDefines
#endif

#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif

// MARK: String? 扩展：nil 安全
public extension Optional where Wrapped == String {
    @inlinable var byTrimmedOrNil: String? {
        self?.byTrimmedOrNil
    }
    @inlinable var isNonEmptyHttpURL: Bool {
        self?.isNonEmptyHttpURL ?? false
    }
    @inlinable var asHttpURLOrNil: String? {
        self?.asHttpURLOrNil
    }
}
// MARK: 字符串相关格式的（通用）转换
extension String {
    /// String 转 Int
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    /// String 转 Int64
    public func toInt64() -> Int64? {
        if let num = NumberFormatter().number(from: self) {
            return num.int64Value
        } else {
            return nil
        }
    }
    /// String 转 Double
    public func toDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")  // 固定使用 . 作为小数点
        formatter.numberStyle = .decimal

        // 设置逗号为千位分隔符，点号为小数点
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        return formatter.number(from: self.trimmingCharacters(in: .whitespacesAndNewlines))?.doubleValue
    }
    /// String 转 Double
    public func toDouble(_ max:Int,_ min:Int) -> Double? {
        let format = NumberFormatter.init()
        format.maximumFractionDigits = max
        format.minimumFractionDigits = min
        if let num = format.number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    /// String 转 Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    /// String 转 Bool
    public func toBool() -> Bool? {
        let trimmedString = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch trimmedString {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    /// String 转 NSString
    public var toNSString: NSString {
        return self as NSString
    }
    /// String 转 NSAttributedString
    /// 转富文本（默认空属性）
    var rich: NSAttributedString {
        NSAttributedString(string: self)
    }
    /// 转富文本并附加属性
    func rich(_ attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        NSAttributedString(string: self, attributes: attrs)
    }
    /// 将字符串竖排化：每字符一行（Emoji/空格也原样拆分）
    var verticalized: String {
        guard !isEmpty else { return self }
        return self.map { String($0) }.joined(separator: "\n")
    }
}
// MARK: String 扩展：点语法裁剪 / 校验
public extension String {
    /// 去掉首尾空白+换行
    @inlinable var byTrimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    /// 裁剪后非空则返回自身，否则 nil
    @inlinable var byTrimmedOrNil: String? {
        let s = byTrimmed
        return s.isEmpty ? nil : s
    }
    /// 裁剪后为非空且 scheme 是 http/https
    @inlinable var isNonEmptyHttpURL: Bool {
        let p = byTrimmed.lowercased()
        return !p.isEmpty && (p.hasPrefix("http://") || p.hasPrefix("https://"))
    }
    /// 裁剪后若是 http(s) 则返回字符串，否则 nil
    @inlinable var asHttpURLOrNil: String? {
        isNonEmptyHttpURL ? byTrimmed : nil
    }
}
// MARK: 字符串转换成资源
public extension String {
    // MARK: - 字符串@Bundle
    /// 在指定 Bundle 查找媒体资源 URL（支持 "name.ext" 或 "name"）。
    /// - Parameter bundle: 默认 .main
    /// - Returns: URL?（找不到返回 nil）
    var bundleMediaURL: URL? {
        return bundleMediaURL(in: .main)
    }

    func bundleMediaURL(in bundle: Bundle) -> URL? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // 既支持 "name.ext" 也支持 "name"
        let name = (trimmed as NSString).deletingPathExtension
        let ext  = (trimmed as NSString).pathExtension.isEmpty ? nil : (trimmed as NSString).pathExtension

        return bundle.url(forResource: name, withExtension: ext)
    }
    /// 必得版（开发期断言失败直接崩，等价你以前的 `!`）
    var bundleMediaURLRequire: URL {
        if let u = self.bundleMediaURL { return u }
        assertionFailure("❌ Bundle media not found: \(self) (check Target Membership)")
        fatalError("Bundle media not found: \(self)")
    }
    // MARK: - 字符串@URL
    /// "https://..." → URL?  （仅放行 http/https；自动做轻度编码）
    var url: URL? {
        let raw = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        let s = raw.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? raw
        guard let u = URL(string: s) else { return nil }
        if let scheme = u.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return u
        };return nil
    }
    /// "https://..." → URL  （开发期断言必得；等价你原来的 `!` 用法）
    var urlRequire: URL {
        if let u = self.url { return u }
        assertionFailure("❌ Invalid URL string: \(self)")
        fatalError("Invalid URL: \(self)")
    }
    // MARK: - 字符串@图片
    /// 统一解析：字符串 → 图片来源
    var imageSource: ImageSource? {
        // 优先判断 http/https
        if let url = URL(string: self),
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            return .remote(url)
        };return .local(self)// 其余视为本地资源名（包括空 scheme、非 http(s)）
    }
    /// 本地同步图（仅当来源是 .local 时有意义）
    var img: UIImage {
        guard let source = imageSource else { return UIImage() }
        switch source {
        case .remote:
            // 同步返回不支持网络加载，避免阻塞
            print("🚫 检测到网络 URL：\(self)，无法同步返回图片")
            return UIImage()
        case .local(let name):
            return UIImage(named: name) ?? UIImage()
        }
    }

    var sysImg: UIImage {
        UIImage(systemName: self) ?? jobsSolidBlue()
    }

    func sysImg(_ config: UIImage.SymbolConfiguration) -> UIImage {
        UIImage(systemName: self, withConfiguration: config) ?? jobsSolidBlue()
    }
#if canImport(Kingfisher)
    /// 远程：通过 KF 异步下载后返回；本地：直接返回
    func kfLoadImage() async throws -> UIImage {
        guard let source = imageSource else { throw KFError.badURL }
        switch source {
        case .remote(let url):
            let result = try await KingfisherManager.shared.retrieveImage(with: url)
            return result.image
        case .local(let name):
            if let img = UIImage(named: name) { return img }
            throw KFError.notFound
        }
    }
    /// A) 允许传 nil：nil -> 蓝色兜底
    func kfLoadImage(fallbackImage: @autoclosure () -> UIImage?) async -> UIImage {
        do { return try await self.kfLoadImage() }         // 你已有的 throws 版本
        catch { return fallbackImage() ?? jobsSolidBlue() }
    }
    /// B) 非可选便捷版
    func kfLoadImage(fallback: UIImage) async -> UIImage {
        await kfLoadImage(fallbackImage: fallback)
    }
#endif

#if canImport(SDWebImage)
    /// 远程：通过 SDWebImage 异步下载后返回；本地：直接返回
    func sdLoadImage() async throws -> UIImage {
        guard let source = imageSource else {
            throw NSError(domain: "SDWebImage", code: -1000,
                          userInfo: [NSLocalizedDescriptionKey: "Bad URL string"])
        }
        switch source {
        case .remote(let url):
            return try await withCheckedThrowingContinuation { cont in
                SDWebImageManager.shared.loadImage(
                    with: url,
                    options: [],
                    progress: nil
                ) { image, _, error, _, _, _ in
                    if let error = error {
                        cont.resume(throwing: error)
                    } else if let image = image {
                        cont.resume(returning: image)
                    } else {
                        cont.resume(throwing: NSError(
                            domain: "SDWebImage",
                            code: -1001,
                            userInfo: [NSLocalizedDescriptionKey: "Image not found"]
                        ))
                    }
                }
            }

        case .local(let name):
            if let img = UIImage(named: name) {
                return img
            }
            throw NSError(domain: "SDWebImage", code: -1002,
                          userInfo: [NSLocalizedDescriptionKey: "Local image not found: \(name)"])
        }
    }
    /// 不抛错：加载失败则返回 fallbackImage()；若其为 nil，则返回蓝色占位图
    func sdLoadImage(fallbackImage: @autoclosure () -> UIImage?) async -> UIImage {
        do {
            return try await self.sdLoadImage()   // 你已有的 throws 版本
        } catch {
            return fallbackImage() ?? jobsSolidBlue()
        }
    }
#endif
}
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
            }
            self.completion = nil
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
// MARK: 二维码
public extension String {
    /// 由当前字符串生成二维码 UIImage（无插值放大，清晰）
    /// - Parameters:
    ///   - widthSize: 目标边长（正方形）
    ///   - correction: 纠错等级 L/M/Q/H（默认 M）
    /// - Returns: 生成的二维码图片；失败返回空 UIImage()
    @MainActor
    func qrcodeImage(_ widthSize: CGFloat, correction: String = "M") -> UIImage {
        guard !self.isEmpty,
              let data = self.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return UIImage() }

        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correction, forKey: "inputCorrectionLevel") // "L" "M" "Q" "H"

        guard let output = filter.outputImage, widthSize > 0 else { return UIImage() }

        // 无插值等比放大
        let scale = max(widthSize / output.extent.width, widthSize / output.extent.height)
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
    /// 可选：着色版（前景/背景色）
    @MainActor
    func qrcodeImage(_ widthSize: CGFloat,
                     foreground: UIColor,
                     background: UIColor = .white,
                     correction: String = "M") -> UIImage {
        guard !self.isEmpty,
              let data = self.data(using: .utf8),
              let gen = CIFilter(name: "CIQRCodeGenerator"),
              let falseColor = CIFilter(name: "CIFalseColor")
        else { return UIImage() }

        gen.setDefaults()
        gen.setValue(data, forKey: "inputMessage")
        gen.setValue(correction, forKey: "inputCorrectionLevel")

        guard let qr = gen.outputImage else { return UIImage() }
        // 颜色映射
        falseColor.setValue(qr, forKey: kCIInputImageKey)
        falseColor.setValue(CIColor(color: foreground), forKey: "inputColor0")
        falseColor.setValue(CIColor(color: background), forKey: "inputColor1")

        guard let colored = falseColor.outputImage else { return UIImage() }
        // 无插值放大
        let scale = max(widthSize / colored.extent.width, widthSize / colored.extent.height)
        let scaled = colored.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
    /// 生成带中心 Logo 的二维码
    /// - Parameters:
    ///   - widthSize: 二维码目标边长
    ///   - correction: 纠错等级（默认 H，便于盖 Logo）
    ///   - logo: 中心 Logo（可为 nil）
    ///   - logoRatio: Logo 相对二维码边长比例（0.18~0.25 比较稳）
    ///   - logoCornerRadius: Logo 圆角
    ///   - borderWidth: Logo 外围白边宽度
    ///   - borderColor: Logo 外围白边颜色
    /// - Returns: UIImage
    @MainActor
    func qrcodeImage(
        _ widthSize: CGFloat,
        correction: String = "H",
        centerLogo logo: UIImage?,
        logoRatio: CGFloat = 0.22,
        logoCornerRadius: CGFloat = 8,
        borderWidth: CGFloat = 4,
        borderColor: UIColor = .white
    ) -> UIImage {
        // 1) 先生成基础二维码（无插值放大）
        guard !isEmpty,
              let data = data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator"),
              widthSize > 0
        else { return UIImage() }

        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correction, forKey: "inputCorrectionLevel") // L/M/Q/H

        guard let output = filter.outputImage else { return UIImage() }

        let scale = max(widthSize / output.extent.width, widthSize / output.extent.height)
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let ciCtx = CIContext()
        guard let qrCG = ciCtx.createCGImage(scaled, from: scaled.extent) else { return UIImage() }
        let qrImage = UIImage(cgImage: qrCG)
        // 2) 若没有 Logo，直接返回
        guard let logo = logo else { return qrImage }
        // 3) 计算 Logo 尺寸与绘制区域
        let canvasSize = CGSize(width: widthSize, height: widthSize)
        let logoSide = max(8, min(widthSize * logoRatio, widthSize * 0.3)) // 兜底限制
        let logoRect = CGRect(
            x: (canvasSize.width  - logoSide) * 0.5,
            y: (canvasSize.height - logoSide) * 0.5,
            width: logoSide,
            height: logoSide
        )
        // 4) 合成：先画二维码，再画带白边+圆角裁剪的 Logo
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { ctx in
            // 画 QR（已经是整像素放大，不会糊）
            qrImage.draw(in: CGRect(origin: .zero, size: canvasSize))
            // 画 Logo 外围白色边框（圆角矩形）
            if borderWidth > 0 {
                let borderRect = logoRect.insetBy(dx: -borderWidth, dy: -borderWidth)
                let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: logoCornerRadius + borderWidth)
                borderColor.setFill()
                borderPath.fill()
            }
            // 裁剪圆角并画 Logo
            let clipPath = UIBezierPath(roundedRect: logoRect, cornerRadius: logoCornerRadius)
            clipPath.addClip()
            logo.draw(in: logoRect)
        }
    }
}
// MARK: 条形码
public extension String {
    /// Code128 条形码（可指定目标尺寸；自动无插值放大）
    /// - Parameters:
    ///   - size: 目标尺寸（建议宽>>高，如 260x100）
    ///   - quietSpace: 左右留白（点数，默认 7）
    @MainActor
    func code128BarcodeImage(size: CGSize, quietSpace: CGFloat = 7) -> UIImage {
        guard !isEmpty,
              // Code128 推荐 ASCII；退化到 UTF8 也给过
              let msg = (self.data(using: .ascii) ?? self.data(using: .utf8)),
              let f = CIFilter(name: "CICode128BarcodeGenerator") else { return UIImage() }
        f.setDefaults()
        f.setValue(msg, forKey: "inputMessage")
        f.setValue(quietSpace, forKey: "inputQuietSpace") // 左右静区

        guard let out = f.outputImage, size.width > 0, size.height > 0 else { return UIImage() }

        // 非等比缩放到目标尺寸（条形码需要明确宽高）
        let scaleX: CGFloat = size.width  / out.extent.width
        let scaleY: CGFloat = size.height / out.extent.height
        let scaled = out.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let ctx = CIContext()
        guard let cg = ctx.createCGImage(scaled, from: scaled.extent) else { return UIImage() }
        return UIImage(cgImage: cg)
    }
    /// 生成带底部文字的人类可读 Code128 条形码
    /// - Parameters:
    ///   - width: 整体宽度（条码与文字共用）
    ///   - barHeight: 条码区高度
    ///   - quietSpace: 左右静区（点数）
    ///   - spacing: 条码与文字的间距
    ///   - font: 文字字体；会自动按宽度收缩
    ///   - textColor: 文字颜色（默认黑）
    ///   - background: 背景色（默认白）
    /// - Returns: UIImage
    @MainActor
    func code128ByText(width: CGFloat,
                       barHeight: CGFloat = 100,
                       quietSpace: CGFloat = 7,
                       spacing: CGFloat = 6,
                       font: UIFont = .monospacedDigitSystemFont(ofSize: 16, weight: .regular),
                       textColor: UIColor = .black,
                       background: UIColor = .white) -> UIImage {
        guard !isEmpty,
              let msg = (self.data(using: .ascii) ?? self.data(using: .utf8)),
              let f = CIFilter(name: "CICode128BarcodeGenerator"),
              width > 0, barHeight > 0
        else { return UIImage() }
        // 1) 生成条形码 CIImage
        f.setDefaults()
        f.setValue(msg, forKey: "inputMessage")
        f.setValue(quietSpace, forKey: "inputQuietSpace")
        guard let out = f.outputImage else { return UIImage() }
        // 2) 放大到目标条码尺寸（非等比按宽/高分别缩放）
        let scaleX = width  / out.extent.width
        let scaleY = barHeight / out.extent.height
        let scaled = out.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let ctx = CIContext()
        guard let cgBar = ctx.createCGImage(scaled, from: scaled.extent) else { return UIImage() }
        // 3) 计算文字区域高度（先用行高；若太宽会缩放字体）
        _ = font.lineHeight
        var drawFont = font
        let attr: [NSAttributedString.Key: Any] = [.font: drawFont]
        var textSize = (self as NSString).size(withAttributes: attr)

        if textSize.width > width { // 太宽就按比例缩小字体
            let factor = width / textSize.width
            drawFont = .monospacedDigitSystemFont(ofSize: max(8, font.pointSize * factor),
                                                  weight: (font.fontDescriptor.symbolicTraits.contains(.traitBold) ? .bold : .regular))
            textSize = (self as NSString).size(withAttributes: [.font: drawFont])
        }

        let totalHeight = barHeight + spacing + ceil(textSize.height)
        // 4) 合成：上条码、下文字
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: totalHeight))
        return renderer.image { ctx in
            // 背景
            background.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: totalHeight))
            // 条码
            let barRect = CGRect(x: 0, y: 0, width: width, height: barHeight)
            UIImage(cgImage: cgBar).draw(in: barRect, blendMode: .normal, alpha: 1)
            // 文字（居中）
            let textY = barHeight + spacing
            let textX = (width - textSize.width) * 0.5
            (self as NSString).draw(at: CGPoint(x: textX, y: textY),
                                    withAttributes: [.font: drawFont, .foregroundColor: textColor])
        }
    }
}
// MARK: - 公有工具
public extension String {
    /// 复制当前字符串到系统剪切板
    func paste(){
        UIPasteboard.general.string = self
    }
    /// 安全取字符
    subscript(_ index: Int) -> Character? {
        guard index >= 0 && index < count else { return nil }
        let i = self.index(startIndex, offsetBy: index)
        return self[i]
    }
    /// 处理换行："一等奖"->"一\n等\n奖\n"
    var verticalByNewline: String {
        guard !isEmpty else { return "" }
        var result = ""
        for ch in self {
            result.append(ch)
            result.append("\n")
        };return result
    }
    /// 处理换行："一等奖" -> "一\n等\n奖"（如果你有时候不想要最后那个 `\n` 可以用这个）
    func verticalByNewline(_ trimLastNewline: Bool) -> String {
        // ✅ 共用上面的计算属性
        var result = verticalByNewline
        if trimLastNewline, result.hasSuffix("\n") {
            result.removeLast()
        };return result
    }
    /// 处理换行：去掉字符串中的所有换行符（\n / \r / \r\n）
    var rnl: String {
        components(separatedBy: .newlines).joined()
    }
    // 多语言@仅此一个API：
    var tr: String {
        let b = TRLang.bundle()
        print("📍 strings path =", b.path(forResource: "Localizable", ofType: "strings") ?? "nil")
        // value: self → 当 key 未翻到时，回退 key 本身，便于你肉眼排查漏翻
        return NSLocalizedString(self, tableName: nil, bundle: b, value: self, comment: "")
    }
    // 多语言@带参数版本
    func tr(_ args: CVarArg...) -> String {
        String(format: self.tr, arguments: args)
    }
}
// MARK: - 私有工具
private extension String {
    /// 尝试将任意字符串转为“可打开”的 URL：
    /// - 无 scheme 且像域名 → 自动补 `https://`
    /// - 做百分号编码，保证中文/空格安全
    static func makeURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // 已包含 scheme：直接编码重建
        if trimmed.contains("://") {
            return percentEncodedURL(trimmed)
        }
        // 没有 scheme：如果像域名/路径，自动补 https://
        // 简单启发式：包含点号或以 "www." 开头，就按网址处理
        if trimmed.hasPrefix("www.") || trimmed.contains(".") {
            return percentEncodedURL("https://" + trimmed)
        };return nil// 既没 scheme 又不像网址：当成无效
    }
    /// 百分号编码（保留合法字符，编码空格、中文、emoji 等）
    static func percentEncodedURL(_ s: String) -> URL? {
        // 尽量宽松地保留 URL 合法字符，其余编码
        var allowed = CharacterSet.urlQueryAllowed
        allowed.insert(charactersIn: "/:#?&=@!$'()*+,;[]%._~-") // 常见保留
        let encoded = s.addingPercentEncoding(withAllowedCharacters: allowed) ?? s
        return URL(string: encoded)
    }
    /// 只保留 0-9 与最前面的 '+'
    static func sanitizePhone(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return "" }

        var result = ""
        var seenPlus = false
        for ch in t {
            if ch == "+" && !seenPlus && result.isEmpty {
                result.append(ch)
                seenPlus = true
            } else if ch.isNumber {
                result.append(ch)
            }
        }
        return result
    }
    /// 解析多个邮箱：支持逗号/分号/空格
    static func _parseEmails(_ raw: String) -> [String] {
        raw.split { ",; ".contains($0) }
           .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
           .filter { !$0.isEmpty && $0.contains("@") }
    }

    static func _makeMailtoURL(to: [String],
                               subject: String?,
                               body: String?,
                               cc: [String],
                               bcc: [String]) -> URL? {
        var comps = URLComponents()
        comps.scheme = "mailto"
        comps.path = to.joined(separator: ",")
        var items: [URLQueryItem] = []
        if let subject, !subject.isEmpty { items.append(.init(name: "subject", value: subject)) }
        if let body, !body.isEmpty       { items.append(.init(name: "body", value: body)) }
        if !cc.isEmpty { items.append(.init(name: "cc", value: cc.joined(separator: ","))) }
        if !bcc.isEmpty { items.append(.init(name: "bcc", value: bcc.joined(separator: ","))) }
        comps.queryItems = items.isEmpty ? nil : items
        return comps.url
    }
}
// MARK: - 字符串校验规定格式@取色
fileprivate func jobsParseHexColor(_ raw: String,
                                   defaultAlpha: CGFloat = 1.0) -> (rgbHex: String, alpha: CGFloat)? {
    var hex = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                 .lowercased()
    // 前缀处理
    if hex.hasPrefix("#") {
        hex.removeFirst()
    } else if hex.hasPrefix("0x") {
        hex.removeFirst(2)
    }
    // 3 位压缩格式：RGB -> RRGGBB
    if hex.count == 3 {
        let r = hex[hex.startIndex]
        let g = hex[hex.index(hex.startIndex, offsetBy: 1)]
        let b = hex[hex.index(hex.startIndex, offsetBy: 2)]
        hex = "\(r)\(r)\(g)\(g)\(b)\(b)"
    }
    // 只接受 6 / 8 位
    guard hex.count == 6 || hex.count == 8 else { return nil }
    // 只允许 0-9a-f
    let validChars = CharacterSet(charactersIn: "0123456789abcdef")
    guard hex.unicodeScalars.allSatisfy({ validChars.contains($0) }) else {
        return nil
    }

    if hex.count == 6 {
        // 纯 RRGGBB，用外面给的 defaultAlpha
        return (rgbHex: hex, alpha: defaultAlpha)
    } else {
        // AARRGGBB：前 2 位是 alpha，后 6 位是 RRGGBB
        let aStr = String(hex.prefix(2))
        let rgb  = String(hex.suffix(6))
        guard let aInt = UInt8(aStr, radix: 16) else { return nil }
        let alpha = CGFloat(aInt) / 255.0
        return (rgbHex: rgb, alpha: alpha)
    }
}
// MARK: - 字符串取颜色@校验成功后取色
/**
 "#353a3e".cor          // OK → 正常色
 "353a3e".cor           // OK
 "0x353a3e".cor         // OK
 "#FFF".cor             // OK → 展开成 #FFFFFF
 "80FF0000".cor         // OK → alpha=0x80, red
 "乱七八糟".cor         // ❌ → 直接红色

 "80FF0000".cor(alpha: 1) // alpha 走字符串里的 0x80，而不是你传的 1
 "垃圾".cor(.black)        // 非法 → black
 */
public extension String {
    /// 支持格式：
    /// "#RRGGBB" / "RRGGBB" / "0xRRGGBB"
    /// "#RGB"   / "RGB"
    /// "#AARRGGBB" / "AARRGGBB"
    /// 是否是合法的 hex 颜色字符串（只判断上面支持的几种格式）
    var isValidHexColor: Bool {
        jobsParseHexColor(self) != nil
    }
    /// 直接从字符串拿 UIColor
    /// - 若格式非法，直接返回红色（作为错误兜底）
    var cor: UIColor {
        guard let (rgb, alpha) = jobsParseHexColor(self),
              let color = UIColor(hexString: rgb, alpha: alpha) else {
            return .red
        };return color
    }
    /// 带 alpha 的版本
    /// - 若格式非法，返回对应 alpha 的红色
    /// - 若字符串本身带 AARRGGBB，则优先用字符串里的 alpha
    func cor(alpha explicitAlpha: CGFloat) -> UIColor {
        let defaultAlpha = explicitAlpha
        guard let (rgb, parsedAlpha) = jobsParseHexColor(self, defaultAlpha: defaultAlpha),
              let color = UIColor(hexString: rgb, alpha: parsedAlpha) else {
            return UIColor.red.withAlphaComponent(explicitAlpha)
        };return color
    }
    /// 指定兜底颜色版本（你要自定义 fallback 就用这个）
    func cor(_ fallback: UIColor) -> UIColor {
        guard let (rgb, alpha) = jobsParseHexColor(self),
              let color = UIColor(hexString: rgb, alpha: alpha) else {
            return fallback
        };return color
    }
}
