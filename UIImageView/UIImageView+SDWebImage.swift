//
//  UIImageView+SDWebImage.swift
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

#if canImport(SDWebImage)
import SDWebImage
public extension UIImageView {
    @discardableResult
    func sd_setImage(from string: String,
                     placeholder: UIImage? = nil,
                     fade: TimeInterval = 0.25) -> Self {
        switch string.imageSource {
        case .remote(let url)?:
            sd_setImage(
                with: url,
                placeholderImage: placeholder,
                options: [.avoidAutoSetImage]
            ) { [weak self] image, _, _, _ in
                guard let self = self else { return }
                UIView.transition(with: self,
                                  duration: fade,
                                  options: .transitionCrossDissolve,
                                  animations: { self.image = image },
                                  completion: nil)
            }
        case .local(let name)?:
            image = UIImage(named: name) ?? placeholder
        case nil:
            image = placeholder
        };return self
    }

    @discardableResult
    func byAsyncImageSD(
        _ src: String,
        fallback: @autoclosure @escaping @Sendable () -> UIImage
    ) -> Self {
        Task { @MainActor in
            let img = await src.sdLoadImage(fallbackImage: fallback())
            image = img
        };return self
    }
}
#endif
