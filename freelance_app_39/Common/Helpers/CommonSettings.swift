import Foundation

protocol CommonSettings {
  static var animationDuration: TimeInterval { get }
  static var minScaleFactor: CGFloat { get }
  
  static var baseSideIndent: CGFloat { get }
  static var baseCornerRadius: CGFloat { get }
}
extension CommonSettings {
  static var animationDuration: TimeInterval { 0.5 }
  static var minScaleFactor: CGFloat { 0.5 }
  
  static var baseSideIndent: CGFloat { 16.0 }
  static var baseCornerRadius: CGFloat {
    let cornerRadius = 24.0
    return cornerRadius.sizeProportion
  }
}
