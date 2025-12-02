//
//  UIToolbarAppearance.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

@available(iOS 13.0, *)
public extension UIToolbarAppearance {
    // MARK: - Configure presets
    @discardableResult
    func byConfigureWithDefaultBackground() -> Self {
        self.configureWithDefaultBackground()
        return self
    }

    @discardableResult
    func byConfigureWithOpaqueBackground() -> Self {
        self.configureWithOpaqueBackground()
        return self
    }

    @discardableResult
    func byConfigureWithTransparentBackground() -> Self {
        self.configureWithTransparentBackground()
        return self
    }
    // MARK: - Button appearances
    @discardableResult
    func byButtonAppearance(_ config: (UIBarButtonItemAppearance) -> Void) -> Self {
        config(self.buttonAppearance)
        return self
    }

    @discardableResult
    func byDoneButtonAppearance(_ config: (UIBarButtonItemAppearance) -> Void) -> Self {
        config(self.doneButtonAppearance)
        return self
    }
}
