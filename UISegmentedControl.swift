//
//  UISegmentedControl.swift
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

extension UISegmentedControl {
    @discardableResult
    func bySelectedSegmentIndex(_ index: Int) -> Self {
        self.selectedSegmentIndex = index
        return self
    }

    @discardableResult
    func byTitle(_ title: String, forSegmentAt index: Int) -> Self {
        self.setTitle(title, forSegmentAt: index)
        return self
    }

    @discardableResult
    func byTitleTextAttributes(_ attributes: [NSAttributedString.Key: Any], for state: UIControl.State) -> Self {
        self.setTitleTextAttributes(attributes, for: state)
        return self
    }

    @discardableResult
    func insertSegmentByAnimated(withTitle title: String, at index: Int) -> Self {
        self.insertSegment(withTitle: title, at: index, animated: true)
        return self
    }
    
    @discardableResult
    func insertSegment(withTitle title: String, at index: Int) -> Self {
        self.insertSegment(withTitle: title, at: index, animated: false)
        return self
    }

    @discardableResult
    func removeSegmentByAnimated(at index: Int) -> Self {
        self.removeSegment(at: index, animated: true)
        return self
    }
    
    @discardableResult
    func removeSegment(at index: Int) -> Self {
        self.removeSegment(at: index, animated: false)
        return self
    }
}
