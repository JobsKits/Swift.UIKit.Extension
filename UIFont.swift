//
//  UIFont.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 9/25/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
// MARK: -设置通用字体（400 表示 Regular（普通），500 表示 Medium（中等））
extension UIFont {
    public convenience init?(medium: CGFloat) {
        self.init(name: "PingFangSC-Medium", size: medium)
    }

    public convenience init?(regular: CGFloat) {
        self.init(name: "PingFangSC-Regular", size: regular)
    }

    public convenience init?(semibold: CGFloat) {
        self.init(name: "PingFangSC-Semibold", size: semibold)
    }

    public convenience init?(light: CGFloat) {
        self.init(name: "PingFangSC-Light", size: light)
    }

    public convenience init?(dinalternate: CGFloat) {
        self.init(name: "DIN Alternate", size: dinalternate)
    }

    public convenience init?(digitial: CGFloat) {
        self.init(name: "DS-Digital-Bold", size: digitial)
    }

    public convenience init?(_ dinalternatebold: CGFloat) {
        self.init(name: "DINAlternate-Bold", size: dinalternatebold)
    }

    public convenience init?(fonteditor:CGFloat) {
        self.init(name: "fonteditor", size: fonteditor)
    }

    public convenience init?(fonteditorBold:CGFloat) {
        self.init(name: "DIN Black", size: fonteditorBold)
    }

    public convenience init?(DINCondBold:CGFloat) {
        self.init(name: "DINCond-Bold", size: DINCondBold)
    }

//    public convenience init?(dinC: CGFloat) {
//        self.init(name: "DIN Condensed", size: dinC)
//    }
}
