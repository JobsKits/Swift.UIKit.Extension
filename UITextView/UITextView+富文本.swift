//
//  UITextView+富文本.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
// MARK: 设置富文本
public extension UITextView {
    func richTextBy(_ runs: [JobsRichRun], paragraphStyle: NSMutableParagraphStyle? = nil) {
        attributedText = JobsRichText.make(runs, paragraphStyle: paragraphStyle)
        isEditable = false
        isScrollEnabled = false
        dataDetectorTypes = [] // 仅走自定义 link
    }
}
