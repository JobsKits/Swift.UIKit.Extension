//
//  UIActivityIndicatorView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIActivityIndicatorView {
    @discardableResult
    func byStyle(_ style: UIActivityIndicatorView.Style) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    func byColor(_ color: UIColor) -> Self {
        self.color = color
        return self
    }

    @discardableResult
    func start() -> Self {
        self.startAnimating()
        return self
    }

    @discardableResult
    func stop() -> Self {
        self.stopAnimating()
        return self
    }

    @discardableResult
    func byHidesWhenStopped(_ hides: Bool) -> Self {
        self.hidesWhenStopped = hides
        return self
    }
}
