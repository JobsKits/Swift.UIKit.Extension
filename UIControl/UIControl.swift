//
//  UIControl.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public final class _JobsClosureWrapper: NSObject {
    private let closure: jobsByVoidBlock

    init(_ closure: @escaping jobsByVoidBlock) {
        self.closure = closure
    }

    @objc func invoke() {
        closure()
    }
}
