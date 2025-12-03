//
//  UIButton+按钮（背景）图.swift
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
// MARK: 按钮背景图加载（UIImage / Base64 / URL）
public enum JobsImageSource: Equatable {
    case image(UIImage)
    case base64(String)      // 纯 Base64（不含 "data:" 前缀）
    case url(URL)            // 远端 URL
}

private final class _JobsImageCache {
    static let shared = _JobsImageCache()
    let cache = NSCache<NSString, UIImage>()
    private init() {}
}

public extension UIButton {
    @discardableResult
    func byBackgroundImage(_ source: JobsImageSource?, for state: UIControl.State = .normal) -> Self {
        guard let source else {
            self.setBackgroundImage(nil, for: state)
            return self
        }
        switch source {
        case .image(let img):
            self.setBackgroundImage(img, for: state)

        case .base64(let b64):
            if let data = Data(base64Encoded: b64, options: .ignoreUnknownCharacters),
               let img = UIImage(data: data) {
                self.setBackgroundImage(img, for: state)
            } else {
                self.setBackgroundImage(nil, for: state)
            }

        case .url(let url):
            let key = url.absoluteString as NSString
            if let cached = _JobsImageCache.shared.cache.object(forKey: key) {
                self.setBackgroundImage(cached, for: state)
            } else {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let self, let data, let img = UIImage(data: data) else { return }
                    _JobsImageCache.shared.cache.setObject(img, forKey: key)
                    DispatchQueue.main.async {
                        self.setBackgroundImage(img, for: state)
                    }
                }.resume()
            }
        };return self
    }
}
// MARK: 统一写回图片
public extension UIButton {
    @MainActor
    func jobsResetBtnImage(_ image: UIImage?, for state: UIControl.State) {
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()  // ✅ 没有也创建；前景建议用 .plain()
            cfg.image = image                          // ✅ 前景图写到 configuration.image
            self.configuration = cfg
            byUpdateConfig()
        } else {
            self.setImage(image, for: state)          // ✅ 旧系统走 legacy API
        }
        if #available(iOS 15.0, *) {
            self.setNeedsUpdateConfiguration()
        }
    }
    @MainActor
    func jobsResetBtnBgImage(_ image: UIImage?, for state: UIControl.State) {
        // 先把最终图粘住，供后续任何 config 重建时回填
        self.jobs_cfgBgImage = image
        // ① legacy 背景图：立刻可见，最稳
        self.setBackgroundImage(image, for: state)
        // ② iOS 15+：把同一张图同步到 configuration.background，避免被下一次重建抹掉
        if #available(iOS 15.0, *) {
            var cfg = self.configuration ?? .plain()
            var bg  = cfg.background
            bg.image = image
            if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
            bg.backgroundColor = .clear
            cfg.background = bg
            self.configuration = cfg

            // 让生命周期继续，但这里不要马上“强制”刷新，避免刚设的图被别的 handler 抢写
            self.automaticallyUpdatesConfiguration = true
            // self.setNeedsUpdateConfiguration()  // ← 刻意不在这里触发
        }
        // 保险刷新
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.setNeedsDisplay()
    }

    @available(iOS 15.0, *)
    func _applySubtitleToConfigurationNow(targetState: UIControl.State = .normal) {
        // 1) 基于现有 configuration 开始，避免默认值把东西清空
        var cfg = self.configuration ?? .plain()
        // 2) 先把当前“有效背景图”抓出来，稍后再回填，防止被覆盖
        let currentBgImage: UIImage? = (
            cfg.background.image                               // 配置里已有背景
            ?? self.jobs_cfgBgImage                            // 我们粘住的背景
            ?? self.backgroundImage(for: targetState)          // legacy 背景（按 state）
            ?? self.backgroundImage(for: .normal)              // legacy 背景（normal）
        )
        // 3) 同步主标题（防 title 丢）
        if cfg.title == nil, let t = self.title(for: .normal), !t.isEmpty {
            cfg.title = t
        }
        cfg.titleAlignment = .center
        // 4) 应用副标题 + 字体/颜色
        let pack = self._subDict_noAttr[targetState.rawValue]
                ?? self._subDict_noAttr[UIControl.State.normal.rawValue]
        let text = pack?.text ?? ""
        cfg.subtitle = text.isEmpty ? nil : text

        let f = pack?.font
        let c = pack?.color
        cfg.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var a = incoming
            if let f { a.font = f }
            if let c { a.foregroundColor = c }
            return a
        }
        // 5) 关键：把背景图回填回去，并粘到 AO，防止后续 update 时丢失
        if let bgImg = currentBgImage {
            var bg = cfg.background
            bg.image = bgImg
            if bg.imageContentMode == .scaleToFill { bg.imageContentMode = .scaleAspectFill }
            bg.backgroundColor = .clear
            cfg.background = bg
            self.jobs_cfgBgImage = bgImg
        }
        // 6) 提交配置并触发更新（保持自动更新为开启）
        self.configuration = cfg
        self.automaticallyUpdatesConfiguration = true
        self.setNeedsUpdateConfiguration()
    }
}
