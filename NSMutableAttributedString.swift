//
//  NSMutableAttributedString.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/2/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

public extension NSMutableAttributedString {
    // MARK: - 添加单个属性
    @discardableResult
    func byAddAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange? = nil) -> Self {
        if let range = range {
            self.addAttribute(name, value: value, range: range)
        } else {
            self.addAttribute(name, value: value, range: NSRange(location: 0, length: self.length))
        };return self
    }
    // MARK: - 添加多个属性
    @discardableResult
    func byAddAttributes(_ attrs: [NSAttributedString.Key : Any], range: NSRange? = nil) -> Self {
        let targetRange = range ?? NSRange(location: 0, length: self.length)
        self.addAttributes(attrs, range: targetRange)
        return self
    }
    // MARK: - 移除属性
    @discardableResult
    func byRemoveAttribute(_ name: NSAttributedString.Key, range: NSRange? = nil) -> Self {
        let targetRange = range ?? NSRange(location: 0, length: self.length)
        self.removeAttribute(name, range: targetRange)
        return self
    }
    // MARK: - 替换内容
    @discardableResult
    func byReplace(in range: NSRange, with attrString: NSAttributedString) -> Self {
        self.replaceCharacters(in: range, with: attrString)
        return self
    }
    // MARK: - 插入
    @discardableResult
    func byInsert(_ attrString: NSAttributedString, at index: Int) -> Self {
        self.insert(attrString, at: index)
        return self
    }
    // MARK: - 追加
    @discardableResult
    func add(_ attrString: NSAttributedString) -> Self {
        self.append(attrString)
        return self
    }
    // MARK: - 删除
    @discardableResult
    func byDelete(in range: NSRange) -> Self {
        self.deleteCharacters(in: range)
        return self
    }
    // MARK: - 重置为新的富文本
    @discardableResult
    func bySet(_ attrString: NSAttributedString) -> Self {
        self.setAttributedString(attrString)
        return self
    }
    // MARK: - 编辑批处理
    @discardableResult
    func byBeginEditing() -> Self {
        self.beginEditing()
        return self
    }

    @discardableResult
    func byEndEditing() -> Self {
        self.endEditing()
        return self
    }
}
