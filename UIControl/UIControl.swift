//
//  UIControl.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/1/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

public final class _JobsClosureWrapper: NSObject {
    private let closure: () -> Void
    init(_ closure: @escaping () -> Void) { self.closure = closure }
    @objc func invoke() { closure() }
}
