//
//  NSTextAttachment.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/7/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// ================================== NSTextAttachment 链式封装 ==================================
public extension NSTextAttachment {
    // MARK: - 初始化（便捷）
    /// 便捷初始化：等价于 init(data:ofType:)
    @available(iOS 7.0, *)
    convenience init(byData data: Data?, ofType uti: String?) {
        self.init(data: data, ofType: uti)
    }
    // MARK: - Content（数据/类型）
    /// 设置二进制内容（与 fileType/uti 搭配）
    @available(iOS 7.0, *)
    @discardableResult
    func byContents(_ data: Data?) -> Self {
        self.contents = data
        return self
    }
    /// 设置 UTI / 文件类型（如 "public.png"）
    @available(iOS 7.0, *)
    @discardableResult
    func byFileType(_ uti: String?) -> Self {
        self.fileType = uti
        return self
    }
    // MARK: - 渲染 / 布局
    /// 设置图片（最常用）
    @available(iOS 7.0, *)
    @discardableResult
    func byImage(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    /// 设置绘制区域（控制大小/偏移）
    @available(iOS 7.0, *)
    @discardableResult
    func byBounds(_ rect: CGRect) -> Self {
        self.bounds = rect
        return self
    }
    // MARK: - 非图片内容（文件包装）
    /// 设置文件包装（可承载任意附件）
    @discardableResult
    func byFileWrapper(_ wrapper: FileWrapper?) -> Self {
        self.fileWrapper = wrapper
        return self
    }
    // MARK: - iOS 15+：行内布局与 View Provider
    /// 行内布局的额外左右留白（iOS 15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byLineLayoutPadding(_ padding: CGFloat) -> Self {
        self.lineLayoutPadding = padding
        return self
    }
    /// 允许使用 TextAttachmentView（iOS 15+）
    @available(iOS 15.0, *)
    @discardableResult
    func byAllowsTextAttachmentView(_ allowed: Bool) -> Self {
        self.allowsTextAttachmentView = allowed
        return self
    }
    // usesTextAttachmentView 为只读属性，无法链式设置；提供便捷只读透传
    @available(iOS 15.0, *)
    var byUsesTextAttachmentView: Bool { self.usesTextAttachmentView }
}
// ================================== NSTextAttachment 类级工具（iOS 15+） ==================================
public extension NSTextAttachment {
    /// 查询已注册的 Provider 类（按 fileType）
    @available(iOS 15.0, *)
    static func byTextAttachmentViewProviderClass(forFileType fileType: String) -> AnyClass? {
        return Self.textAttachmentViewProviderClass(forFileType: fileType)
    }
    /// 注册自定义 Provider 类（按 fileType）
    @available(iOS 15.0, *)
    static func byRegisterViewProviderClass(_ providerClass: AnyClass, forFileType fileType: String) {
        Self.registerViewProviderClass(providerClass, forFileType: fileType)
    }
}
