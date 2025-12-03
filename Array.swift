//
//  Array.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 11/19/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC

extension Array {
    /// 安全读：越界返回 nil，不 crash
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
