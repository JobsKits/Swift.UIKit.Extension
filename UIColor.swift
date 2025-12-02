//
//  UIColorExtensions.swift
//  PlayYes
//
//  Created by yihui on 2023/6/22.
//  扩展UIColor

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension UIColor {
    /// init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    /// init method with RGB values from 0 to 255, instead of 0 to 1. With alpha(default:1)
    public convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
    /// init method with hex string and alpha(default: 1)
    /// 支持格式：
    /// "#RRGGBB" / "RRGGBB" / "0xRRGGBB"
    /// "#RGB"   / "RGB"
    /// "#AARRGGBB" / "AARRGGBB"
    convenience init?(hexString: String, alpha: CGFloat = 1) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
                           .lowercased()
        // 去掉前缀
        if hex.hasPrefix("#") {
            hex.removeFirst()
        } else if hex.hasPrefix("0x") {
            hex.removeFirst(2)
        }
        // 3 位压缩格式：RGB -> RRGGBB
        if hex.count == 3 {
            let r = hex[hex.startIndex]
            let g = hex[hex.index(hex.startIndex, offsetBy: 1)]
            let b = hex[hex.index(hex.startIndex, offsetBy: 2)]
            hex = "\(r)\(r)\(g)\(g)\(b)\(b)"
        }

        var a: CGFloat = alpha
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0

        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }

        switch hex.count {
        case 6: // RRGGBB
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8)  / 255.0
            b = CGFloat( value & 0x0000FF)        / 255.0
        case 8: // AARRGGBB
            a = CGFloat((value & 0xFF000000) >> 24) / 255.0
            r = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((value & 0x0000FF00) >> 8)  / 255.0
            b = CGFloat( value & 0x000000FF)        / 255.0
        default:
            return nil
        };self.init(red: r, green: g, blue: b, alpha: a)
    }

    /// init method from Gray value and alpha(default:1)
    public convenience init(gray: CGFloat, alpha: CGFloat = 1) {
        self.init(red: gray/255, green: gray/255, blue: gray/255, alpha: alpha)
    }
}

extension UIColor {
    /// Red component of UIColor (get-only)
    public var redComponent: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }
    /// Green component of UIColor (get-only)
    public var greenComponent: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }
    /// blue component of UIColor (get-only)
    public var blueComponent: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }
    /// Alpha of UIColor (get-only)
    public var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
    /// 16 进制颜色
    class func hex(_ hex: UInt) -> UIColor {
        return hexAlpha(hex, alpha: 1.0)
    }
    /// 16 进制颜色 + 透明度
    class func hexAlpha(_ hex: UInt, alpha: Float) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(hex & 0x0000FF) / 255.0,
                       alpha: CGFloat(alpha))
    }
    /// 生成随机颜色
    static var randomColor: UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
/* 设置多颜色样式 会用到
 //透明度；alpha 取值对照
 100% — FF
 95% — F2
 90% — E6
 85% — D9
 80% — CC
 75% — BF
 70% — B3
 65% — A6
 60% — 99
 55% — 8C
 50% — 80
 45% — 73
 40% — 66
 35% — 59
 30% — 4D
 25% — 40
 20% — 33
 15% — 26
 10% — 1A
 5% — 0D
 0% — 00
 ————————————————
 版权声明：本文为CSDN博主「刘淏卿」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
 原文链接：https://blog.csdn.net/pinglingying/article/details/52403819
 辅助网站可通过16禁止颜色号看到颜色：https://www.colorhexa.com/83899b
 */
