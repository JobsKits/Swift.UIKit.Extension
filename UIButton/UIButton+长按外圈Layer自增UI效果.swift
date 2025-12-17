//
//  UIButton+长按外圈Layer自增UI效果.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/17/25.
//

import UIKit
import ObjectiveC
import QuartzCore

public typealias JobsPressFuseTick = (_ btn: UIButton, _ elapsed: TimeInterval, _ progress: CGFloat) -> Void
public typealias JobsPressFuseEnd  = (_ btn: UIButton, _ elapsed: TimeInterval, _ progress: CGFloat) -> Void

private final class JobsPressFuseDriver: NSObject {
    weak var btn: UIButton?
    var tickInterval: TimeInterval = 1.0 / 60.0
    var durationToFull: TimeInterval = 1.5          // 多久涨满一圈
    var loopWhenFull: Bool = false                  // 满了之后是否循环（不循环就停在 100%）
    var removeLayerOnEnd: Bool = true               // 松手是否移除外圈
    var config: JobsFuseConfig = JobsFuseConfig(
        lineWidth: 2,
        color: .white,
        inset: 0,
        removeOnFinish: false,
        direction: .clockwise
    )

    var onTick: JobsPressFuseTick?
    var onEnd: JobsPressFuseEnd?

    private var timer: JobsTimerProtocol?
    private var startTS: CFTimeInterval = 0
    private var lastProgress: CGFloat = 0

    func begin() {
        guard let btn else { return }

        // 准备外圈（progress=0）
        btn.jobs_prepareFuseProgress(config: config)
        lastProgress = 0
        startTS = CACurrentMediaTime()

        // DisplayLink 更适合这种“持续增长”的视觉（你 JobsTimer 里就有）:contentReference[oaicite:9]{index=9}
        timer?.stop()
        let cfg = JobsTimerConfig(
            interval: 1.0 / 60.0,
            repeats: true,
            tolerance: 0,
            queue: .main,
            runLoop: .main,
            runLoopMode: .common,
            pauseInBackground: true,
            autoManageAppState: true
        ) // JobsTimerConfig 字段定义见这里 :contentReference[oaicite:10]{index=10}

        timer = JobsTimerFactory.make(kind: .displayLink, config: cfg) { [weak self] in
            self?.tickOnce()
        } // 工厂方法在这里 :contentReference[oaicite:11]{index=11}

        timer?.start()
    }

    func endPress() {
        guard let btn else { return }

        timer?.stop()
        timer = nil

        let elapsed = max(0, CACurrentMediaTime() - startTS)
        let progress = lastProgress

        if removeLayerOnEnd {
            btn.jobs_cancelFuseCountdown(removeLayer: true)
        }

        startTS = 0
        onEnd?(btn, elapsed, progress)
    }

    private func tickOnce() {
        guard let btn else { return }
        guard startTS > 0 else { return }

        let elapsed = max(0, CACurrentMediaTime() - startTS)
        let raw = elapsed / max(0.0001, durationToFull)

        let p: CGFloat
        if loopWhenFull {
            p = CGFloat(raw.truncatingRemainder(dividingBy: 1.0))
        } else {
            p = min(1, CGFloat(raw))
        }

        lastProgress = p
        btn.jobs_updateFuseProgress(p, animated: false)
        onTick?(btn, elapsed, p)

        // 不循环：满了就停（外圈保持 100%）
        if !loopWhenFull, p >= 1 {
            timer?.stop()
            timer = nil
        }
    }
}

public extension UIButton {
    private struct JobsPressFuseKeys {
        static var driverKey: UInt8 = 0
        static var gestureKey: UInt8 = 0
    }

    private var jobs_pressFuseDriver: JobsPressFuseDriver? {
        get { objc_getAssociatedObject(self, &JobsPressFuseKeys.driverKey) as? JobsPressFuseDriver }
        set { objc_setAssociatedObject(self, &JobsPressFuseKeys.driverKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @discardableResult
    func jobs_enablePressFuseCountUp(
        tickInterval: TimeInterval = 1.0 / 60.0,
        durationToFull: TimeInterval = 1.5,
        loopWhenFull: Bool = false,
        removeLayerOnEnd: Bool = true,
        config: JobsFuseConfig = JobsFuseConfig(
            lineWidth: 2,
            color: .white,
            inset: 0,
            removeOnFinish: false,
            direction: .clockwise
        ),
        onTick: JobsPressFuseTick? = nil,
        onEnd: JobsPressFuseEnd? = nil
    ) -> Self {

        let d = jobs_pressFuseDriver ?? JobsPressFuseDriver()
        d.btn = self
        d.tickInterval = tickInterval
        d.durationToFull = durationToFull
        d.loopWhenFull = loopWhenFull
        d.removeLayerOnEnd = removeLayerOnEnd
        d.config = config
        d.onTick = onTick
        d.onEnd = onEnd
        jobs_pressFuseDriver = d

        if objc_getAssociatedObject(self, &JobsPressFuseKeys.gestureKey) == nil {
            let g = UILongPressGestureRecognizer(target: self, action: #selector(jobs_onPressFuse(_:)))
            g.minimumPressDuration = 0
            g.allowableMovement = 10_000
            g.cancelsTouchesInView = false
            addGestureRecognizer(g)
            objc_setAssociatedObject(self, &JobsPressFuseKeys.gestureKey, g, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        };return self
    }

    func jobs_disablePressFuseCountUp() {
        jobs_pressFuseDriver?.endPress()
        jobs_pressFuseDriver = nil

        if let g = objc_getAssociatedObject(self, &JobsPressFuseKeys.gestureKey) as? UILongPressGestureRecognizer {
            removeGestureRecognizer(g)
        }
        objc_setAssociatedObject(self, &JobsPressFuseKeys.gestureKey, nil, .OBJC_ASSOCIATION_ASSIGN)
    }

    @objc private func jobs_onPressFuse(_ g: UILongPressGestureRecognizer) {
        guard let d = jobs_pressFuseDriver else { return }
        switch g.state {
        case .began:
            d.begin()
        case .ended, .cancelled, .failed:
            d.endPress()
        default:
            break
        }
    }
}
