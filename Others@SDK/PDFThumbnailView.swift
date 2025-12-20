//  PDFThumbnailView.swift
//  JobsSwiftBaseConfigDemo
//  Created by Mac on 11/3/25.

#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif
import PDFKit

public extension PDFThumbnailView {
    @discardableResult func byPDFView(to pdfView: PDFView) -> Self {
        self.pdfView = pdfView;
        return self
    }
    @discardableResult func byLayoutMode(_ mode: PDFThumbnailLayoutMode) -> Self {
        self.layoutMode = mode;
        return self
    }
    @discardableResult func byThumbnailSize(_ size: CGSize) -> Self {
        self.thumbnailSize = size;
        return self
    }
    @discardableResult func byBgColor(_ color: UIColor) -> Self {
        self.backgroundColor = color;
        return self
    }
    @discardableResult func byContentInset(_ inset: UIEdgeInsets) -> Self {
        if #available(iOS 11.0, *) {
            self.contentInset = inset
        }; return self
    }
}
