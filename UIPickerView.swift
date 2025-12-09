//
//  Untitled.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIPickerView {
    @discardableResult
    func byDelegate(_ delegate: UIPickerViewDelegate) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byDataSource(_ dataSource: UIPickerViewDataSource) -> Self {
        self.dataSource = dataSource
        return self
    }

    @discardableResult
    func selectRowByAnimated(_ row: Int, inComponent component: Int) -> Self {
        self.selectRow(row, inComponent: component, animated: true)
        return self
    }

    @discardableResult
    func reloadAllComponentsBy() -> Self {
        self.reloadAllComponents()
        return self
    }

    @discardableResult
    func reloadComponentBy(_ component: Int) -> Self {
        self.reloadComponent(component)
        return self
    }
}
