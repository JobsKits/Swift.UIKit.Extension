//
//  UIScrollView+DSL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/2/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif

extension UIScrollView {
    // MARK:  Basics
    @discardableResult
    func byContentSize(_ size: CGSize) -> Self {
        self.contentSize = size
        return self
    }

    @discardableResult
    func byContentOffsetBy(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: false)
        return self
    }

    @discardableResult
    func byContentOffsetByAnimated(_ offset: CGPoint) -> Self {
        self.setContentOffset(offset, animated: true)
        return self
    }

    @discardableResult
    func byShowsVerticalScrollIndicator(_ show: Bool) -> Self {
        self.showsVerticalScrollIndicator = show
        return self
    }

    @discardableResult
    func byShowsHorizontalScrollIndicator(_ show: Bool) -> Self {
        self.showsHorizontalScrollIndicator = show
        return self
    }

    @discardableResult
    func byBounces(_ bounces: Bool) -> Self {
        self.bounces = bounces
        return self
    }

    @discardableResult
    func byAlwaysBounceVertical(_ enable: Bool) -> Self {
        self.alwaysBounceVertical = enable
        return self
    }

    @discardableResult
    func byAlwaysBounceHorizontal(_ enable: Bool) -> Self {
        self.alwaysBounceHorizontal = enable
        return self
    }

    @discardableResult
    func byPagingEnabled(_ enabled: Bool) -> Self {
        self.isPagingEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollEnabled(_ enabled: Bool) -> Self {
        self.isScrollEnabled = enabled
        return self
    }

    @discardableResult
    func byDirectionalLockEnabled(_ enabled: Bool) -> Self {
        self.isDirectionalLockEnabled = enabled
        return self
    }

    @discardableResult
    func byScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.scrollIndicatorInsets = insets
        return self
    }

    @discardableResult
    func byContentInset(_ insets: UIEdgeInsets) -> Self {
        self.contentInset = insets
        return self
    }

    @discardableResult
    func byIndicatorStyle(_ style: UIScrollView.IndicatorStyle) -> Self {
        self.indicatorStyle = style
        return self
    }
    /// 改为可选，便于置空
    @discardableResult
    func byDelegate(_ delegate: UIScrollViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }

    @discardableResult
    func byKeyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> Self {
        self.keyboardDismissMode = mode
        return self
    }

    @discardableResult
    func byRefreshControl(_ control: UIRefreshControl?) -> Self {
        self.refreshControl = control
        return self
    }

    @discardableResult
    func byDecelerationRate(_ rate: UIScrollView.DecelerationRate) -> Self {
        self.decelerationRate = rate
        return self
    }

    @discardableResult
    func byScrollsToTop(_ enabled: Bool) -> Self {
        self.scrollsToTop = enabled
        return self
    }
    // MARK:  Insets & Adjustment
    /// iOS 11.0+ 内容 inset 自动调整行为
    @available(iOS 11.0, *)
    @discardableResult
    func byContentInsetAdjustmentBehavior(_ behavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        self.contentInsetAdjustmentBehavior = behavior
        return self
    }
    /// iOS 13.0+ 自动调整滚动条 inset
    @available(iOS 13.0, *)
    @discardableResult
    func byAutomaticallyAdjustsScrollIndicatorInsets(_ enable: Bool) -> Self {
        self.automaticallyAdjustsScrollIndicatorInsets = enable
        return self
    }
    /// iOS 11.1+ 垂直滚动条 inset
    @available(iOS 11.1, *)
    @discardableResult
    func byVerticalScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.verticalScrollIndicatorInsets = insets
        return self
    }
    /// iOS 11.1+ 水平滚动条 inset
    @available(iOS 11.1, *)
    @discardableResult
    func byHorizontalScrollIndicatorInsets(_ insets: UIEdgeInsets) -> Self {
        self.horizontalScrollIndicatorInsets = insets
        return self
    }
    // MARK: Keyboard Scrolling
    /// iOS 17.0+ 允许键盘方向键滚动
    @available(iOS 17.0, *)
    @discardableResult
    func byAllowsKeyboardScrolling(_ enable: Bool) -> Self {
        self.allowsKeyboardScrolling = enable
        return self
    }
    // MARK: iOS 17.4+ 属性组
    /// iOS 17.4+ 内容对齐点
    @available(iOS 17.4, *)
    @discardableResult
    func byContentAlignmentPoint(_ point: CGPoint) -> Self {
        self.contentAlignmentPoint = point
        return self
    }
    /// iOS 17.4+ 水平回弹
    @available(iOS 17.4, *)
    @discardableResult
    func byBouncesHorizontally(_ enable: Bool) -> Self {
        self.bouncesHorizontally = enable
        return self
    }
    /// iOS 17.4+ 垂直回弹
    @available(iOS 17.4, *)
    @discardableResult
    func byBouncesVertically(_ enable: Bool) -> Self {
        self.bouncesVertically = enable
        return self
    }
    /// iOS 17.4+ 是否将水平滚动交给父级
    @available(iOS 17.4, *)
    @discardableResult
    func byTransfersHorizontalScrollingToParent(_ enable: Bool) -> Self {
        self.transfersHorizontalScrollingToParent = enable
        return self
    }
    /// iOS 17.4+ 是否将垂直滚动交给父级
    @available(iOS 17.4, *)
    @discardableResult
    func byTransfersVerticalScrollingToParent(_ enable: Bool) -> Self {
        self.transfersVerticalScrollingToParent = enable
        return self
    }
    /// iOS 17.4+ 滚动 offset 变化时强制显示滚动条
    @available(iOS 17.4, *)
    @discardableResult
    func byWithScrollIndicatorsShownForContentOffsetChanges(_ changes: () -> Void) -> Self {
        self.withScrollIndicatorsShown(forContentOffsetChanges: changes)
        return self
    }
    /// iOS 17.4+ 立即停止滚动与缩放动画
    @available(iOS 17.4, *)
    @discardableResult
    func byStopScrollingAndZooming() -> Self {
        self.stopScrollingAndZooming()
        return self
    }

    // MARK: Touch Behavior
    @discardableResult
    func byDelaysContentTouches(_ enable: Bool) -> Self {
        self.delaysContentTouches = enable
        return self
    }

    @discardableResult
    func byCanCancelContentTouches(_ enable: Bool) -> Self {
        self.canCancelContentTouches = enable
        return self
    }
    // MARK: Zoom
    @discardableResult
    func byMinimumZoomScale(_ scale: CGFloat) -> Self {
        self.minimumZoomScale = scale
        return self
    }

    @discardableResult
    func byMaximumZoomScale(_ scale: CGFloat) -> Self {
        self.maximumZoomScale = scale
        return self
    }

    @discardableResult
    func byZoomScale(_ scale: CGFloat, animated: Bool = false) -> Self {
        if animated {
            self.setZoomScale(scale, animated: true)
        } else {
            self.zoomScale = scale
        }
        return self
    }

    @discardableResult
    func byBouncesZoom(_ enable: Bool) -> Self {
        self.bouncesZoom = enable
        return self
    }

    @discardableResult
    func byZoom(to rect: CGRect, animated: Bool) -> Self {
        self.zoom(to: rect, animated: animated)
        return self
    }
    // MARK: Indicators
    @discardableResult
    func byShowsIndicators(vertical: Bool? = nil, horizontal: Bool? = nil) -> Self {
        if let v = vertical { self.showsVerticalScrollIndicator = v }
        if let h = horizontal { self.showsHorizontalScrollIndicator = h }
        return self
    }

    @discardableResult
    func byFlashScrollIndicators() -> Self {
        self.flashScrollIndicators()
        return self
    }
    // MARK: Visible Rect
    @discardableResult
    func byScrollRectToVisible(_ rect: CGRect, animated: Bool) -> Self {
        self.scrollRectToVisible(rect, animated: animated)
        return self
    }
    // MARK: Index Display
    @discardableResult
    func byIndexDisplayMode(_ mode: UIScrollView.IndexDisplayMode) -> Self {
        self.indexDisplayMode = mode
        return self
    }
    // MARK: Gesture Config
    @discardableResult
    func byPanGesture(_ config: (UIPanGestureRecognizer) -> Void) -> Self {
        config(self.panGestureRecognizer)
        return self
    }

    @available(iOS 5.0, *)
    @discardableResult
    func byPinchGesture(_ config: (UIPinchGestureRecognizer) -> Void) -> Self {
        if let pinch = self.pinchGestureRecognizer {
            config(pinch)
        }
        return self
    }

    @discardableResult
    func byDirectionalPressGesture(_ config: (UIGestureRecognizer) -> Void) -> Self {
        config(self.directionalPressGestureRecognizer)
        return self
    }
    // MARK:  iOS 26.0+ Scroll Edge Effects
    @available(iOS 26.0, *)
    @discardableResult
    func byTopEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.topEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byLeftEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.leftEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byBottomEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.bottomEdgeEffect)
        return self
    }

    @available(iOS 26.0, *)
    @discardableResult
    func byRightEdgeEffect(_ config: (UIScrollEdgeEffect) -> Void) -> Self {
        config(self.rightEdgeEffect)
        return self
    }
}
