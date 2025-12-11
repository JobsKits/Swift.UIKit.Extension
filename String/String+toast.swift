//
//  String+toast.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/11/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

public extension String {
    var toast: Void {
        toastBy(self)
    }
}
