//
//  UIDatePicker.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 2025/6/16.
//


#if os(OSX)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension UIDatePicker {
    // datePickerMode; default is .dateAndTime
    @discardableResult
    func byDatePickerMode(_ mode: UIDatePicker.Mode) -> Self {
        self.datePickerMode = mode
        return self
    }
    // locale; default is Locale.current; set nil returns to default
    @discardableResult
    func byLocale(_ locale: Locale?) -> Self {
        self.locale = locale
        return self
    }
    // calendar; default is Calendar.current; set nil returns to default
    @discardableResult
    func byCalendar(_ calendar: Calendar?) -> Self {
        self.calendar = calendar
        return self
    }
    // timeZone; default is nil; use current time zone or time zone from calendar
    @discardableResult
    func byTimeZone(_ timeZone: TimeZone?) -> Self {
        self.timeZone = timeZone
        return self
    }
    // date; default is current date when picker created
    // setDate(_:animated:) with animated = true
    @discardableResult
    func byDateByAnimated(_ date: Date) -> Self {
        self.setDate(date, animated: true)
        return self
    }
    // date; default is current date when picker created
    // setDate(_:animated:) with animated = false
    @discardableResult
    func byDateBy(_ date: Date) -> Self {
        self.setDate(date, animated: false)
        return self
    }
    // minimumDate; specify min date range; default is nil
    @discardableResult
    func byMinimumDate(_ date: Date?) -> Self {
        self.minimumDate = date
        return self
    }
    // maximumDate; specify max date range; default is nil
    @discardableResult
    func byMaximumDate(_ date: Date?) -> Self {
        self.maximumDate = date
        return self
    }
    // countDownDuration; for .countDownTimer only; default is 0
    @discardableResult
    func byCountDownDuration(_ duration: TimeInterval) -> Self {
        self.countDownDuration = duration
        return self
    }
    // minuteInterval; must evenly divide 60; default is 1; min 1 max 30
    @discardableResult
    func byMinuteInterval(_ interval: Int) -> Self {
        self.minuteInterval = interval
        return self
    }
    // preferredDatePickerStyle; request a style (may require relayout/resize)
    // API_AVAILABLE(iOS 13.4) API_UNAVAILABLE(tvos, watchos)
    #if os(iOS)
    @discardableResult
    @available(iOS 13.4, *)
    func byPreferredDatePickerStyle(_ style: UIDatePickerStyle) -> Self {
        self.preferredDatePickerStyle = style
        return self
    }
    #endif
    // roundsToMinuteInterval; when true, date always rounds to minuteInterval; default true
    @discardableResult
    @available(iOS 15.0, tvOS 15.0, *)
    func byRoundsToMinuteInterval(_ enabled: Bool) -> Self {
        self.roundsToMinuteInterval = enabled
        return self
    }
}
