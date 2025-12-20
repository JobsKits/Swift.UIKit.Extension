//
//  UIProgressView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIProgressView {
    // MARK: Style
    /// 设置样式
    @discardableResult
    func byProgressViewStyle(_ style: UIProgressView.Style) -> Self {
        self.progressViewStyle = style
        return self
    }
    // MARK: Value
    /// 直接设置 progress（不动画）
    @discardableResult
    func byProgress(_ progress: Float) -> Self {
        self.progress = progress
        return self
    }
    /// 设置 progress 是否动画
    @discardableResult
    func byProgress(_ progress: Float, animated: Bool) -> Self {
        self.setProgress(progress, animated: animated)
        return self
    }
    /// 仅提供“动画设置 progress”的链式语法（兼容你之前的命名）
    @discardableResult
    func byProgressByAnimated(_ progress: Float) -> Self {
        self.setProgress(progress, animated: true)
        return self
    }
    // MARK: Tint Color
    /// 设置进度条前景色
    @discardableResult
    func byProgressTintColor(_ color: UIColor) -> Self {
        self.progressTintColor = color
        return self
    }
    /// 设置进度条背景色（链式 DSL 版本）
    @discardableResult
    func byTrackTintColor(_ color: UIColor) -> Self {
        self.trackTintColor = color
        return self
    }
    /// 兼容原有命名（如果外部已经在用就不用改调用）
    @discardableResult
    func setTrackTintColor(_ color: UIColor) -> Self {
        self.trackTintColor = color
        return self
    }
    // MARK: Image
    /// 设置前景图片
    @discardableResult
    func byProgressImage(_ image: UIImage?) -> Self {
        self.progressImage = image
        return self
    }
    /// 设置背景图片
    @discardableResult
    func byTrackImage(_ image: UIImage?) -> Self {
        self.trackImage = image
        return self
    }
    // MARK: Observed Progress (iOS 9+)
    /// 绑定 NSProgress / Progress
    @available(iOS 9.0, tvOS 9.0, *)
    @discardableResult
    func byObservedProgress(_ progress: Progress?) -> Self {
        self.observedProgress = progress
        return self
    }
}
