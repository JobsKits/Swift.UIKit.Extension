//
//  UIButton+倒计时.swift
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

#if canImport(JobsSwiftBaseTools)
import JobsSwiftBaseTools
#endif
// MARK: 统一计时器
public enum TimerState { case idle, running, paused, stopped }
private enum _TimerMode {
    case countUp(elapsed: Int)
    case countdown(remain: Int, total: Int)
}

private extension _TimerMode {
    var isCountdown: Bool {
        if case .countdown = self { return true }
        return false
    }
}
private var _timerTickAnyKey: UInt8   = 0
private var _timerFinishAnyKey: UInt8 = 0
private var _legacyCountdownTickKey:   UInt8 = 0
private var _legacyCountdownFinishKey: UInt8 = 0
private var _timerCoreKey:  UInt8 = 0
private var _timerKindKey:  UInt8 = 0
private var _timerModeKey:  UInt8 = 0
private var _timerStateKey: UInt8 = 0
private var _timerStateDidChangeKey: UInt8 = 0

public typealias TimerStateChangeHandler = (_ button: UIButton,
                                            _ oldState: TimerState,
                                            _ newState: TimerState) -> Void

public extension UIButton {
    var timer: JobsTimerProtocol? {
        get { objc_getAssociatedObject(self, &_timerCoreKey) as? JobsTimerProtocol }
        set { objc_setAssociatedObject(self, &_timerCoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    var timerState: TimerState {
        get { (objc_getAssociatedObject(self, &_timerStateKey) as? TimerState) ?? .idle }
        set {
            let old = timerState
            objc_setAssociatedObject(self, &_timerStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let hook = objc_getAssociatedObject(self, &_timerStateDidChangeKey) as? (UIButton, TimerState, TimerState) -> Void {
                hook(self, old, newValue)
            } else {
                applyDefaultTimerUI(for: newValue)
            }
            if #available(iOS 15.0, *) { setNeedsUpdateConfiguration() }
        }
    }

    @discardableResult
    func onTimerStateChange(_ handler: @escaping TimerStateChangeHandler) -> Self {
        objc_setAssociatedObject(self, &_timerStateDidChangeKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    private func applyDefaultTimerUI(for state: TimerState) {
        switch state {
        case .idle, .stopped:
            isEnabled = true; alpha = 1.0
        case .running:
            isEnabled = true; alpha = 1.0
        case .paused:
            isEnabled = true; alpha = 0.85
        }
    }

    @discardableResult
    func onTimerTick(_ handler: @escaping (_ button: UIButton,
                                           _ current: Int,
                                           _ total: Int?,
                                           _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerTickAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onTimerFinish(_ handler: @escaping (_ button: UIButton,
                                             _ kind: JobsTimerKind) -> Void) -> Self {
        objc_setAssociatedObject(self, &_timerFinishAnyKey, handler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onCountdownTick(_ handler: @escaping (_ button: UIButton,
                                               _ remain: Int, _ total: Int,
                                               _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerTick { btn, current, totalOpt, kind in
            if let total = totalOpt { handler(btn, current, total, kind) }
        }
    }

    @discardableResult
    func onCountdownFinish(_ handler: @escaping (_ button: UIButton,
                                                 _ kind: JobsTimerKind) -> Void) -> Self {
        return onTimerFinish(handler)
    }

    @discardableResult
    func startTimer(total: Int? = nil,
                    interval: TimeInterval = 1.0,
                    kind: JobsTimerKind = .gcd) -> Self {
        stopTimer()
        if let total {
            objc_setAssociatedObject(self,
                                     &_timerModeKey,
                                     _TimerMode.countdown(remain: total, total: total),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            isEnabled = false
            setTitle("\(total)s", for: .normal)
        } else {
            objc_setAssociatedObject(self,
                                     &_timerModeKey,
                                     _TimerMode.countUp(elapsed: 0),
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setTitle("0", for: .normal)
        }
        objc_setAssociatedObject(self,
                                 &_timerKindKey,
                                 kind,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let cfg = JobsTimerConfig(interval: interval, repeats: true, tolerance: 0.01, queue: .main)
        let core = JobsTimerFactory.make(kind: kind, config: cfg) { [weak self] in
            guard let self else { return }
            guard var mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode else { return }
            let k = (objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind) ?? kind

            switch mode {
            case .countUp(let elapsed0):
                let elapsed = elapsed0 + 1
                mode = .countUp(elapsed: elapsed)
                objc_setAssociatedObject(self,
                                         &_timerModeKey,
                                         mode,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.setTitle("\(elapsed)", for: .normal)
                if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                    as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                    tick(self, elapsed, nil, k)
                }

            case .countdown(let remain0, let total):
                let remain = remain0 - 1
                if remain > 0 {
                    mode = .countdown(remain: remain, total: total)
                    objc_setAssociatedObject(self,
                                             &_timerModeKey,
                                             mode,
                                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    self.setTitle("\(remain)s", for: .normal)
                    if let tick = objc_getAssociatedObject(self, &_timerTickAnyKey)
                        as? (UIButton, Int, Int?, JobsTimerKind) -> Void {
                        tick(self, remain, total, k)
                    }
                    if let legacy = objc_getAssociatedObject(self, &_legacyCountdownTickKey) as? (Int, Int) -> Void {
                        legacy(remain, total)
                    }
                } else {
                    if let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey)
                        as? (UIButton, JobsTimerKind) -> Void {
                        fin(self, k)
                    }
                    if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                        legacyFin()
                    }
                    self.stopTimer()
                    self.isEnabled = true
                    self.setTitle("重新获取", for: .normal)
                }
            }
        }
        self.timer = core
        self.timerState = .running
        core.start()
        return self
    }

    @discardableResult
    func pauseTimer() -> Self {
        (self.timer)?.pause()
        self.timerState = .paused
        return self
    }

    @discardableResult
    func resumeTimer() -> Self {
        (self.timer)?.resume()
        self.timerState = .running
        return self
    }

    @discardableResult
    func fireTimerOnce() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        (self.timer)?.fireOnce()
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取".tr, for: .normal)
        };return self
    }

    @discardableResult
    func stopTimer() -> Self {
        let mode = objc_getAssociatedObject(self, &_timerModeKey) as? _TimerMode
        if let c = self.timer { c.stop() }
        self.timer = nil
        objc_setAssociatedObject(self, &_timerModeKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.timerState = .stopped
        if mode?.isCountdown == true {
            self.isEnabled = true
            self.setTitle("重新获取".tr, for: .normal)
        };return self
    }
}

public extension UIButton {
    @discardableResult
    func startJobsTimer(total: Int? = nil,
                        interval: TimeInterval = 1.0,
                        kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func pauseJobsTimer() -> Self { pauseTimer() }

    @discardableResult
    func resumeJobsTimer() -> Self { resumeTimer() }

    @discardableResult
    func fireJobsTimerOnce() -> Self { fireTimerOnce() }

    @discardableResult
    func stopJobsTimer() -> Self { stopTimer() }

    @discardableResult
    func startJobsCountdown(total: Int,
                            interval: TimeInterval = 1.0,
                            kind: JobsTimerKind = .gcd) -> Self {
        startTimer(total: total, interval: interval, kind: kind)
    }

    @discardableResult
    func stopJobsCountdown(triggerFinish: Bool = false) -> Self {
        if triggerFinish {
            if let k = objc_getAssociatedObject(self, &_timerKindKey) as? JobsTimerKind,
               let fin = objc_getAssociatedObject(self, &_timerFinishAnyKey) as? (UIButton, JobsTimerKind) -> Void {
                fin(self, k)
            }
            if let legacyFin = objc_getAssociatedObject(self, &_legacyCountdownFinishKey) as? () -> Void {
                legacyFin()
            }
        };return stopTimer()
    }

    @discardableResult
    func onJobsCountdownTick(_ block: @escaping (_ remain: Int, _ total: Int) -> Void) -> Self {
        objc_setAssociatedObject(self,
                                 &_legacyCountdownTickKey,
                                 block,
            .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }

    @discardableResult
    func onJobsCountdownFinish(_ block: @escaping () -> Void) -> Self {
        objc_setAssociatedObject(self,
                                 &_legacyCountdownFinishKey,
                                 block,
            .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return self
    }
}
