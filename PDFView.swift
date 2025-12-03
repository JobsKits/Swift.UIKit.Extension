//  PDFView.swift
//  JobsSwiftBaseConfigDemo
//  Created by Mac on 11/3/25.

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import PDFKit

public extension PDFView {
    // MARK: 文档 & 展示
    @discardableResult func byDocument(_ doc: PDFDocument?) -> Self { self.document = doc; return self }
    @discardableResult func byDisplayMode(_ mode: PDFDisplayMode) -> Self { self.displayMode = mode; return self }
    @discardableResult func byDisplayDirection(_ direction: PDFDisplayDirection) -> Self { if #available(iOS 11.0, *) { self.displayDirection = direction }; return self }
    @discardableResult func byDisplaysPageBreaks(_ on: Bool) -> Self { self.displaysPageBreaks = on; return self }
    @discardableResult func byPageBreakMargins(_ insets: UIEdgeInsets) -> Self { if #available(iOS 11.0, *) { self.pageBreakMargins = insets }; return self }
    @discardableResult func byDisplaysAsBook(_ on: Bool) -> Self { self.displaysAsBook = on; return self }
    @discardableResult func byDisplaysRTL(_ on: Bool) -> Self { if #available(iOS 11.0, *) { self.displaysRTL = on }; return self }
    @discardableResult func byBgColor(_ color: UIColor) -> Self { self.backgroundColor = color; return self }
    @discardableResult func byInterpolationQuality(_ q: PDFInterpolationQuality) -> Self { if #available(iOS 11.0, *) { self.interpolationQuality = q }; return self }
    @discardableResult func byPageShadowsEnabled(_ on: Bool) -> Self { if #available(iOS 12.0, *) { self.pageShadowsEnabled = on }; return self }
    @discardableResult func byUsePageVC(_ enable: Bool, options: [AnyHashable: Any]? = nil) -> Self { if #available(iOS 11.0, *) { self.usePageViewController(enable, withViewOptions: options) }; return self }
    @discardableResult func byDelegate(_ d: PDFViewDelegate?) -> Self { self.delegate = d; return self }
    @available(iOS 16.0, *) @discardableResult func byOverlayProvider(_ provider: PDFPageOverlayViewProvider?) -> Self { self.pageOverlayViewProvider = provider; return self }
    // MARK: 缩放
    @discardableResult func byAutoScales(_ on: Bool = true) -> Self { self.autoScales = on; return self }
    @discardableResult func byScale(_ factor: CGFloat) -> Self { self.scaleFactor = factor; return self }
    @discardableResult func byScaleRange(min: CGFloat, max: CGFloat, auto: Bool? = nil) -> Self {
        if #available(iOS 11.0, *) { self.minScaleFactor = min; self.maxScaleFactor = max }
        if let auto { self.autoScales = auto }; return self
    }

    @discardableResult
    func byFitNow(maxScale limit: CGFloat = 4.0) -> Self {
        let fit = scaleFactorForSizeToFit
        if #available(iOS 11.0, *) {
            minScaleFactor = fit
            maxScaleFactor = Swift.max(fit, limit)
        }
        scaleFactor = fit
        return self
    }
    // MARK: 导航
    @discardableResult func byGoToFirst() -> Self { self.goToFirstPage(nil); return self }
    @discardableResult func byGoToLast() -> Self { self.goToLastPage(nil); return self }
    @discardableResult func byGoNext() -> Self { self.goToNextPage(nil); return self }
    @discardableResult func byGoPrev() -> Self { self.goToPreviousPage(nil); return self }
    @discardableResult func byGoBack() -> Self { self.goBack(nil); return self }
    @discardableResult func byGoForward() -> Self { self.goForward(nil); return self }
    @discardableResult func byGoTo(index: Int) -> Self { if let p = self.document?.page(at: index) { self.go(to: p) }; return self }
    @discardableResult func byGo(to destination: PDFDestination) -> Self { self.go(to: destination); return self }
    @discardableResult func byGo(to selection: PDFSelection) -> Self { self.go(to: selection); return self }
    @discardableResult func byGo(to rect: CGRect, on page: PDFPage) -> Self { self.go(to: rect, on: page); return self }
    // MARK: 选择 & 缩放按钮
    @discardableResult func bySet(selection: PDFSelection?, animate: Bool = false) -> Self {
        if #available(iOS 11.0, *) { self.setCurrentSelection(selection, animate: animate) } else { self.currentSelection = selection }; return self
    }
    @discardableResult func byClearSelection() -> Self { self.clearSelection(); return self }
    @discardableResult func bySelectAll() -> Self { self.selectAll(nil); return self }
    @discardableResult func byZoomIn() -> Self { self.zoomIn(nil); return self }
    @discardableResult func byZoomOut() -> Self { self.zoomOut(nil); return self }
    // MARK: 查找（iOS 16+）
    @discardableResult func byEnableFind(_ enabled: Bool = true) -> Self { if #available(iOS 16.0, *) { self.isFindInteractionEnabled = enabled }; return self }
    // then/with
    @discardableResult func byApply(_ block: (PDFView) -> Void) -> Self { block(self); return self }
    /// 基于 `scaleFactorForSizeToFit`
    @discardableResult func byFitScale(max: CGFloat = 4.0, auto: Bool? = nil) -> Self {
        let fit = scaleFactorForSizeToFit
        if #available(iOS 11.0, *) { minScaleFactor = fit; maxScaleFactor = max }
        if let auto { autoScales = auto }; return self
    }
}
