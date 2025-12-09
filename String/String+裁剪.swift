//
//  String+裁剪.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
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
