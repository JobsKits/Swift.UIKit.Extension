//
//  UIPopoverPresentationController.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIPopoverPresentationController {
    @discardableResult
    func bySourceView(_ view: UIView?) -> Self {
        self.sourceView = view
        return self
    }

    @discardableResult
    func bySourceRect(_ rect: CGRect) -> Self {
        self.sourceRect = rect
        return self
    }

    @discardableResult
    func byPermittedArrowDirections(_ directions: UIPopoverArrowDirection) -> Self {
        self.permittedArrowDirections = directions
        return self
    }

    @discardableResult
    func byDelegate(_ delegate: UIPopoverPresentationControllerDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}
