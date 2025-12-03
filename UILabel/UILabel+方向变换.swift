//
//  UILabel+方向变换.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/3/25.
//
#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
extension UILabel {
    // MARK: 方向变换（使用 CATextLayer，避免富文本/对齐丢失）
    @discardableResult
    func transformLayer(_ direction: TransformLayerDirectionType) -> Self {
        superview?.layoutIfNeeded()
        // 清理旧 layer（避免重复叠加）
        layer.sublayers?
            .filter { $0 is CATextLayer && $0.name == "JobsTextLayer" }
            .forEach { $0.removeFromSuperlayer() }

        let textLayer = CATextLayer()
        textLayer.name = "JobsTextLayer"
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.alignmentMode = ._jobs_fromNSTextAlignment(textAlignment)
        textLayer.truncationMode = (lineBreakMode == .byTruncatingHead) ? .start :
                                   (lineBreakMode == .byTruncatingMiddle) ? .middle :
                                   (lineBreakMode == .byTruncatingTail) ? .end : .none
        textLayer.isWrapped = (numberOfLines == 0)

        if let attributed = attributedText {
            textLayer.string = attributed
        } else {
            textLayer.string = text ?? ""
            textLayer.foregroundColor = textColor.cgColor
            textLayer.font = font
            textLayer.fontSize = font.pointSize
        }
        textLayer.frame = bounds

        switch direction {
        case .up:
            break
        case .left:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
        case .down:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi, 0, 0, 1)
        case .right:
            textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            textLayer.transform = CATransform3DMakeRotation(.pi/2, 0, 0, 1)
        }

        layer.addSublayer(textLayer)
        textColor = .clear // 只显示 layer 的文字
        return self
    }
}
// MARK: - 对齐映射（CATextLayerAlignmentMode ← NSTextAlignment）
private extension CATextLayerAlignmentMode {
    static func _jobs_fromNSTextAlignment(_ a: NSTextAlignment) -> CATextLayerAlignmentMode {
        switch a {
        case .left: return .left
        case .right: return .right
        case .center: return .center
        case .justified: return .justified
        case .natural: return .natural
        @unknown default: return .natural
        }
    }
}
