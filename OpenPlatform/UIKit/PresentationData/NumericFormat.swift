import Foundation

internal func compactNumericCountString(_ count: Int, decimalSeparator: String = ".") -> String {
    if count >= 1000 * 1000 {
        let remainder = (count % (1000 * 1000)) / (1000 * 100)
        if remainder != 0 {
            return "\(count / (1000 * 1000))\(decimalSeparator)\(remainder)M"
        } else {
            return "\(count / (1000 * 1000))M"
        }
    } else if count >= 1000 {
        let remainder = (count % (1000)) / (100)
        if remainder != 0 {
            return "\(count / 1000)\(decimalSeparator)\(remainder)K"
        } else {
            return "\(count / 1000)K"
        }
    } else {
        return "\(count)"
    }
}

internal func presentationStringsFormattedNumber(_ count: Int32, _ groupingSeparator: String = "") -> String {
    let string = "\(count)"
    if groupingSeparator.isEmpty || abs(count) < 1000 {
        return string
    } else {
        var groupedString: String = ""
        for i in 0 ..< Int(ceil(Double(string.count) / 3.0)) {
            let index = string.count - Int(i + 1) * 3
            if !groupedString.isEmpty {
                groupedString = groupingSeparator + groupedString
            }
            groupedString = String(string[string.index(string.startIndex, offsetBy: max(0, index)) ..< string.index(string.startIndex, offsetBy: index + 3)]) + groupedString
        }
        return groupedString
    }
}

internal enum TimeIntervalStringUsage {
    case generic
    case afterTime
    case timer
}
