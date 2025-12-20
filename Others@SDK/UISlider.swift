//
//  UISlider.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UISlider {
    @discardableResult
    func byValueByAnimated(_ value: Float) -> Self {
        self.setValue(value, animated: true)
        return self
    }
    
    @discardableResult
    func byValue(_ value: Float) -> Self {
        self.setValue(value, animated: false)
        return self
    }

    @discardableResult
    func byMinimumValue(_ value: Float) -> Self {
        self.minimumValue = value
        return self
    }

    @discardableResult
    func byMaximumValue(_ value: Float) -> Self {
        self.maximumValue = value
        return self
    }

    @discardableResult
    func byMinimumTrackTintColor(_ color: UIColor) -> Self {
        self.minimumTrackTintColor = color
        return self
    }

    @discardableResult
    func byMaximumTrackTintColor(_ color: UIColor) -> Self {
        self.maximumTrackTintColor = color
        return self
    }

    @discardableResult
    func byThumbTintColor(_ color: UIColor) -> Self {
        self.thumbTintColor = color
        return self
    }
}
