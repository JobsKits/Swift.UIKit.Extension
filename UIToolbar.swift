//
//  UIToolbar.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 10/2/25.
//

import UIKit

public extension UIToolbar {
    // MARK: - Items
    @discardableResult
    func byItemsAnimated(_ items: [UIBarButtonItem]?) -> Self {
        self.setItems(items, animated: true)
        return self
    }
    // MARK: - ❤️ 映射为OC版本的:UIToolbar().items
    @discardableResult
    func byItems(_ items: [UIBarButtonItem]?) -> Self {
        self.setItems(items, animated: false)
        return self
    }
    // MARK: - Style
    @discardableResult
    func byBarStyle(_ style: UIBarStyle) -> Self {
        self.barStyle = style
        return self
    }

    @discardableResult
    func byTranslucent(_ isTranslucent: Bool) -> Self {
        self.isTranslucent = isTranslucent
        return self
    }
    // MARK: - Colors
    @discardableResult
    func byTintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }

    @discardableResult
    func byBarTintColor(_ color: UIColor?) -> Self {
        self.barTintColor = color
        return self
    }
    // MARK: - Background / Shadow
    @discardableResult
    func byBackgroundImage(_ image: UIImage?,
                           forToolbarPosition position: UIBarPosition,
                           barMetrics: UIBarMetrics = .default) -> Self {
        self.setBackgroundImage(image, forToolbarPosition: position, barMetrics: barMetrics)
        return self
    }

    @discardableResult
    func byShadowImage(_ image: UIImage?,
                       forToolbarPosition position: UIBarPosition) -> Self {
        self.setShadowImage(image, forToolbarPosition: position)
        return self
    }
    // MARK: - Appearance (iOS 13+ / 15+)
    @available(iOS 13.0, *)
    @discardableResult
    func byStandardAppearance(_ appearance: UIToolbarAppearance) -> Self {
        self.standardAppearance = appearance
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    func byCompactAppearance(_ appearance: UIToolbarAppearance?) -> Self {
        self.compactAppearance = appearance
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byScrollEdgeAppearance(_ appearance: UIToolbarAppearance?) -> Self {
        self.scrollEdgeAppearance = appearance
        return self
    }

    @available(iOS 15.0, *)
    @discardableResult
    func byCompactScrollEdgeAppearance(_ appearance: UIToolbarAppearance?) -> Self {
        self.compactScrollEdgeAppearance = appearance
        return self
    }
    // MARK: - Delegate
    @discardableResult
    func byDelegate(_ delegate: UIToolbarDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}
