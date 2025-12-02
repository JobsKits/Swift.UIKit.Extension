//
//  UIDatePicker.swift
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

extension UIDatePicker {
    @discardableResult
    func byDateByAnimated(_ date: Date) -> Self {
        self.setDate(date, animated: true)
        return self
    }
    
    @discardableResult
    func byDateBy(_ date: Date) -> Self {
        self.setDate(date, animated: false)
        return self
    }

    @discardableResult
    func byDatePickerMode(_ mode: UIDatePicker.Mode) -> Self {
        self.datePickerMode = mode
        return self
    }

    @discardableResult
    func byMinimumDate(_ date: Date?) -> Self {
        self.minimumDate = date
        return self
    }

    @discardableResult
    func byMaximumDate(_ date: Date?) -> Self {
        self.maximumDate = date
        return self
    }

    @discardableResult
    @available(iOS 13.4, *)
    func byPreferredDatePickerStyle(_ style: UIDatePickerStyle) -> Self {
        self.preferredDatePickerStyle = style
        return self
    }
}
