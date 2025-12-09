//
//  NumberFormatter+DSL.swift
//  JobsSwiftBaseConfigDemo
//
//  Created by Jobs on 12/9/25.
//
import Foundation
// MARK: - 链式 DSL
public extension NumberFormatter {
    // MARK: Context & Behavior
    @available(iOS 8.0, *)
    @discardableResult
    func byFormattingContext(_ context: Formatter.Context) -> Self {
        self.formattingContext = context
        return self
    }

    @discardableResult
    func byGeneratesDecimalNumbers(_ flag: Bool) -> Self {
        self.generatesDecimalNumbers = flag
        return self
    }

    @discardableResult
    func byFormatterBehavior(_ behavior: Behavior) -> Self {
        self.formatterBehavior = behavior
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byLenient(_ flag: Bool) -> Self {
        self.isLenient = flag
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byUsesSignificantDigits(_ flag: Bool) -> Self {
        self.usesSignificantDigits = flag
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byMinimumSignificantDigits(_ value: Int) -> Self {
        self.minimumSignificantDigits = value
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byMaximumSignificantDigits(_ value: Int) -> Self {
        self.maximumSignificantDigits = value
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byPartialStringValidationEnabled(_ flag: Bool) -> Self {
        self.isPartialStringValidationEnabled = flag
        return self
    }
    // MARK: Style & Locale
    @discardableResult
    func byNumberStyle(_ style: Style) -> Self {
        self.numberStyle = style
        return self
    }

    @discardableResult
    func byLocale(_ locale: Locale) -> Self {
        self.locale = locale
        return self
    }
    // MARK: Float / Decimal
    @discardableResult
    func byAllowsFloats(_ flag: Bool) -> Self {
        self.allowsFloats = flag
        return self
    }

    @discardableResult
    func byDecimalSeparator(_ separator: String) -> Self {
        self.decimalSeparator = separator
        return self
    }

    @discardableResult
    func byAlwaysShowsDecimalSeparator(_ flag: Bool) -> Self {
        self.alwaysShowsDecimalSeparator = flag
        return self
    }

    @discardableResult
    func byCurrencyDecimalSeparator(_ separator: String) -> Self {
        self.currencyDecimalSeparator = separator
        return self
    }
    // MARK: Grouping
    @discardableResult
    func byUsesGroupingSeparator(_ flag: Bool) -> Self {
        self.usesGroupingSeparator = flag
        return self
    }

    @discardableResult
    func byGroupingSeparator(_ separator: String) -> Self {
        self.groupingSeparator = separator
        return self
    }

    @discardableResult
    func byGroupingSize(_ size: Int) -> Self {
        self.groupingSize = size
        return self
    }

    @discardableResult
    func bySecondaryGroupingSize(_ size: Int) -> Self {
        self.secondaryGroupingSize = size
        return self
    }

    @available(iOS 18.0, *)
    @discardableResult
    func byMinimumGroupingDigits(_ value: Int) -> Self {
        self.minimumGroupingDigits = value
        return self
    }

    @available(iOS 2.0, *)
    @discardableResult
    func byCurrencyGroupingSeparator(_ separator: String) -> Self {
        self.currencyGroupingSeparator = separator
        return self
    }
    // MARK: Digits
    @discardableResult
    func byMinimumIntegerDigits(_ value: Int) -> Self {
        self.minimumIntegerDigits = value
        return self
    }

    @discardableResult
    func byMaximumIntegerDigits(_ value: Int) -> Self {
        self.maximumIntegerDigits = value
        return self
    }

    @discardableResult
    func byMinimumFractionDigits(_ value: Int) -> Self {
        self.minimumFractionDigits = value
        return self
    }

    @discardableResult
    func byMaximumFractionDigits(_ value: Int) -> Self {
        self.maximumFractionDigits = value
        return self
    }
    // MARK: Range
    @discardableResult
    func byMinimum(_ value: NSNumber?) -> Self {
        self.minimum = value
        return self
    }

    @discardableResult
    func byMaximum(_ value: NSNumber?) -> Self {
        self.maximum = value
        return self
    }
    // MARK: Format / Padding / Rounding
    @discardableResult
    func byFormatWidth(_ width: Int) -> Self {
        self.formatWidth = width
        return self
    }

    @discardableResult
    func byPaddingCharacter(_ character: String) -> Self {
        self.paddingCharacter = character
        return self
    }

    @discardableResult
    func byPaddingPosition(_ position: PadPosition) -> Self {
        self.paddingPosition = position
        return self
    }

    @discardableResult
    func byRoundingMode(_ mode: RoundingMode) -> Self {
        self.roundingMode = mode
        return self
    }

    @discardableResult
    func byRoundingIncrement(_ increment: NSNumber?) -> Self {
        self.roundingIncrement = increment
        return self
    }

    @discardableResult
    func byMultiplier(_ value: NSNumber?) -> Self {
        self.multiplier = value
        return self
    }
    // MARK: Symbols (zero / nil / NaN / ±∞)
    @discardableResult
    func byZeroSymbol(_ symbol: String?) -> Self {
        self.zeroSymbol = symbol
        return self
    }

    @discardableResult
    func byTextAttributesForZero(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForZero = attributes
        return self
    }

    @discardableResult
    func byNilSymbol(_ symbol: String) -> Self {
        self.nilSymbol = symbol
        return self
    }

    @discardableResult
    func byTextAttributesForNil(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForNil = attributes
        return self
    }

    @discardableResult
    func byNotANumberSymbol(_ symbol: String?) -> Self {
        self.notANumberSymbol = symbol
        return self
    }

    @discardableResult
    func byTextAttributesForNotANumber(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForNotANumber = attributes
        return self
    }

    @discardableResult
    func byPositiveInfinitySymbol(_ symbol: String) -> Self {
        self.positiveInfinitySymbol = symbol
        return self
    }

    @discardableResult
    func byTextAttributesForPositiveInfinity(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForPositiveInfinity = attributes
        return self
    }

    @discardableResult
    func byNegativeInfinitySymbol(_ symbol: String) -> Self {
        self.negativeInfinitySymbol = symbol
        return self
    }

    @discardableResult
    func byTextAttributesForNegativeInfinity(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForNegativeInfinity = attributes
        return self
    }
    // MARK: Positive / Negative Format & Attributes
    @discardableResult
    func byNegativeFormat(_ format: String?) -> Self {
        self.negativeFormat = format
        return self
    }

    @discardableResult
    func byTextAttributesForNegativeValues(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForNegativeValues = attributes
        return self
    }

    @discardableResult
    func byPositiveFormat(_ format: String?) -> Self {
        self.positiveFormat = format
        return self
    }

    @discardableResult
    func byTextAttributesForPositiveValues(_ attributes: [String: Any]?) -> Self {
        self.textAttributesForPositiveValues = attributes
        return self
    }
    // MARK: Prefix / Suffix
    @discardableResult
    func byPositivePrefix(_ value: String?) -> Self {
        self.positivePrefix = value
        return self
    }

    @discardableResult
    func byPositiveSuffix(_ value: String?) -> Self {
        self.positiveSuffix = value
        return self
    }

    @discardableResult
    func byNegativePrefix(_ value: String?) -> Self {
        self.negativePrefix = value
        return self
    }

    @discardableResult
    func byNegativeSuffix(_ value: String?) -> Self {
        self.negativeSuffix = value
        return self
    }
    // MARK: Currency / Percent / Signs / Exponent
    @discardableResult
    func byCurrencyCode(_ code: String?) -> Self {
        self.currencyCode = code
        return self
    }

    @discardableResult
    func byCurrencySymbol(_ symbol: String?) -> Self {
        self.currencySymbol = symbol
        return self
    }

    @discardableResult
    func byInternationalCurrencySymbol(_ symbol: String?) -> Self {
        self.internationalCurrencySymbol = symbol
        return self
    }

    @discardableResult
    func byPercentSymbol(_ symbol: String?) -> Self {
        self.percentSymbol = symbol
        return self
    }

    @discardableResult
    func byPerMillSymbol(_ symbol: String?) -> Self {
        self.perMillSymbol = symbol
        return self
    }

    @discardableResult
    func byMinusSign(_ symbol: String?) -> Self {
        self.minusSign = symbol
        return self
    }

    @discardableResult
    func byPlusSign(_ symbol: String?) -> Self {
        self.plusSign = symbol
        return self
    }

    @discardableResult
    func byExponentSymbol(_ symbol: String?) -> Self {
        self.exponentSymbol = symbol
        return self
    }
}
