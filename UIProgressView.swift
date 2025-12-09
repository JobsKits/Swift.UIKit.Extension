//
//  UIProgressView.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIProgressView {
    @discardableResult
    func byProgressByAnimated(_ progress: Float) -> Self {
        self.setProgress(progress, animated: true)
        return self
    }

    @discardableResult
    func byProgressTintColor(_ color: UIColor) -> Self {
        self.progressTintColor = color
        return self
    }

    @discardableResult
    func setTrackTintColor(_ color: UIColor) -> Self {
        self.trackTintColor = color
        return self
    }

    @discardableResult
    func byProgressImage(_ image: UIImage?) -> Self {
        self.progressImage = image
        return self
    }

    @discardableResult
    func byTrackImage(_ image: UIImage?) -> Self {
        self.trackImage = image
        return self
    }
}
