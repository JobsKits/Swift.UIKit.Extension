//
//  String.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
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
