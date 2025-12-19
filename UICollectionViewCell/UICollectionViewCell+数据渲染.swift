//
//  UICollectionViewCell+数据渲染.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/18/25.
//

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

@MainActor
public extension ViewDataProtocol where Self: UICollectionViewCell {
    @discardableResult
    func byData(_ any: Any?) -> Self { self }
}
