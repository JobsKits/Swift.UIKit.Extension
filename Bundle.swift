//
//  Bundle.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Mac on 11/1/25.
//

#if os(OSX)
    import AppKit
#endif

#if os(iOS) || os(tvOS)
    import UIKit
#endif
import ObjectiveC.runtime
#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif
private var _jobs_swizzled: Bool = false
extension Bundle {
    static func jobs_enableLanguageHook() {
        guard !_jobs_swizzled,
              let ori = class_getInstanceMethod(Bundle.self, #selector(localizedString(forKey:value:table:))),
              let new = class_getInstanceMethod(Bundle.self, #selector(jobs_localizedString(forKey:value:table:))) else { return }
        method_exchangeImplementations(ori, new)
        _jobs_swizzled = true
    }

    @objc private func jobs_localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // 只改 main.bundle，避免递归和第三方 bundle 受影响
        if self == .main {
            let b = LanguageManager.shared.localizedBundle
            return b.jobs_localizedString(forKey: key, value: value, table: tableName)
        };return self.jobs_localizedString(forKey: key, value: value, table: tableName)
    }
}
