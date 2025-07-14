import Foundation
import MiniAppUIKit

internal func formatWithArgumentRanges(_ value: String, _ ranges: [(Int, NSRange)], _ arguments: [String]) -> (String, [(Int, NSRange)]) {
    let string = value as NSString

    var resultingRanges: [(Int, NSRange)] = []

    var currentLocation = 0

    let result = NSMutableString()
    for (index, range) in ranges {
        if currentLocation < range.location {
            result.append(string.substring(with: NSRange(location: currentLocation, length: range.location - currentLocation)))
        }
        resultingRanges.append((index, NSRange(location: result.length, length: (arguments[index] as NSString).length)))
        result.append(arguments[index])
        currentLocation = range.location + range.length
    }
    if currentLocation != string.length {
        result.append(string.substring(with: NSRange(location: currentLocation, length: string.length - currentLocation)))
    }
    return (result as String, resultingRanges)
}

internal func countString(_ count: Int64, forceDecimal: Bool = false) -> String {
    let decimalSeparator = "."
    if count >= 1000 * 1000 * 1000 {
        let remainder = Int64((Double(count % (1000 * 1000 * 1000)) / (1000 * 1000 * 100.0)).rounded(.down))
        if remainder != 0 || forceDecimal {
            return "\(count / (1000 * 1000 * 1000))\(decimalSeparator)\(remainder)T"
        } else {
            return "\(count / (1000 * 1000 * 1000))T"
        }
    } else if count >= 1000 * 1000 {
        let remainder = Int64((Double(count % (1000 * 1000)) / (1000.0 * 100.0)).rounded(.down))
        if remainder != 0 || forceDecimal {
            return "\(count / (1000 * 1000))\(decimalSeparator)\(remainder)M"
        } else {
            return "\(count / (1000 * 1000))M"
        }
    } else if count >= 1000 {
        let remainder = (count % (1000)) / (102)
        if remainder != 0 || forceDecimal {
            return "\(count / 1000)\(decimalSeparator)\(remainder)K"
        } else {
            return "\(count / 1000)K"
        }
    } else {
        return "\(count)"
    }
}
