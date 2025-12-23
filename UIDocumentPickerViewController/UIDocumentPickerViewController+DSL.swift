//
//  UIDocumentPickerViewController+DSL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/23/25.
//
#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers // iOS 14+
#endif

public extension UIDocumentPickerViewController {
    // MARK: Factory (Open / Import)
    /// iOS14+：打开/导入文件（推荐）
    @available(iOS 14.0, *)
    static func jobs_opening(
        _ contentTypes: [UTType],
        asCopy: Bool = true,
        allowsMultipleSelection: Bool = false,
        shouldShowFileExtensions: Bool = true
    ) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: asCopy)
        picker.allowsMultipleSelection = allowsMultipleSelection
        picker.shouldShowFileExtensions = shouldShowFileExtensions
        return picker
    }
    /// 只选 .xlsx（推荐，最精准）
    @available(iOS 14.0, *)
    static func jobs_openXLSX(
        asCopy: Bool = true,
        allowsMultipleSelection: Bool = false,
        shouldShowFileExtensions: Bool = true
    ) -> UIDocumentPickerViewController {
        let xlsx = UTType(filenameExtension: "xlsx") ?? .data
        return jobs_opening([xlsx], asCopy: asCopy,
                            allowsMultipleSelection: allowsMultipleSelection,
                            shouldShowFileExtensions: shouldShowFileExtensions)
    }
    /// 常规“表格类”（Numbers/Excel 等更泛）
    @available(iOS 14.0, *)
    static func jobs_openSpreadsheet(
        asCopy: Bool = true,
        allowsMultipleSelection: Bool = false,
        shouldShowFileExtensions: Bool = true
    ) -> UIDocumentPickerViewController {
        return jobs_opening([.spreadsheet], asCopy: asCopy,
                            allowsMultipleSelection: allowsMultipleSelection,
                            shouldShowFileExtensions: shouldShowFileExtensions)
    }
    // MARK: Factory (Export)
    /// iOS14+：导出/移动文件
    @available(iOS 14.0, *)
    static func jobs_exporting(
        _ urls: [URL],
        asCopy: Bool = false,
        shouldShowFileExtensions: Bool = true
    ) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: urls, asCopy: asCopy)
        picker.shouldShowFileExtensions = shouldShowFileExtensions
        return picker
    }
    // MARK: Chain Config
    @discardableResult
    func byDelegate(_ v: UIDocumentPickerDelegate?) -> Self {
        self.delegate = v
        return self
    }

    @discardableResult
    func byAllowsMultipleSelection(_ v: Bool) -> Self {
        self.allowsMultipleSelection = v
        return self
    }

    @discardableResult
    func byShouldShowFileExtensions(_ v: Bool) -> Self {
        self.shouldShowFileExtensions = v
        return self
    }

    @discardableResult
    func byDirectoryURL(_ url: URL?) -> Self {
        self.directoryURL = url
        return self
    }

    @discardableResult
    func byAdd(_ block: (UIDocumentPickerViewController) -> Void) -> Self {
        block(self)
        return self
    }
}
