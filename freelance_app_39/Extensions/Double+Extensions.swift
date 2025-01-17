import Foundation

extension Double {
  var withTwoDigits: Double {
    Double(String(format: "%.2f", self)) ?? self
  }
}
