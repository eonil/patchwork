#if canImport(UIKit)
import UIKit

public extension String {
    func piece() -> Text.Section {
        Text.Section(characters: self, font: .system(.default(size: .system, weight: nil)))
    }
}
public extension Text.Section {
    static func + (_ a:Text.Section, _ b:Text.Section) -> Text {
        Text(content: [a,b])
    }
    static func + (_ a:Text, _ b:Text.Section) -> Text {
        var z = a
        z.content.append(b)
        return z
    }
}

public extension Text {
    func spawn() -> NSAttributedString {
        let x = NSMutableAttributedString()
        x.beginEditing()
        for s in content {
            x.append(s.spawn())
        }
        x.endEditing()
        return x
    }
}
extension Text {
    public struct Section {
        var characters: String
        var font: Font?
        var color: UIColor?
        public func spawn() -> NSAttributedString {
            var table = [NSAttributedString.Key: Any]()
            if let x = font?.spawn() { table[.font] = x }
            if let x = color { table[.foregroundColor] = x }
            return NSAttributedString(string: characters, attributes: table)
        }
    }
    public enum Font {
        /// Legacy style system font selector.
        /// - Most of these fonts can be covered with "descriptor"-based font selection except monospaced-digit font.
        case system(System)
        public enum System {
            case `default`(size:Size, weight:UIFont.Weight?)
            case monospaced(size:Size, weight:UIFont.Weight)
            case monospacedDigit(size:Size, weight:UIFont.Weight)
            case bold(size:Size)
            case italic(size:Size)
        }
        public enum Size {
            case label, button, smallSystem, system
            case custom(CGFloat)
            public func spawn() -> CGFloat {
                switch self {
                case .label: return UIFont.labelFontSize
                case .button: return UIFont.buttonFontSize
                case .smallSystem: return UIFont.smallSystemFontSize
                case .system: return UIFont.systemFontSize
                case let .custom(x): return x
                }
            }
        }
        case descriptor(Descriptor)
        public struct Descriptor {
            var style: UIFont.TextStyle
            /// Set this value only if you want to override default design of the style.
            var design: UIFontDescriptor.SystemDesign?
            /// Set this value only if you want to override default size of the style.
            var size: CGFloat?
        }
        public func spawn() -> UIFont {
            switch self {
            case let .system(.`default`(size, .none)): return UIFont.systemFont(ofSize: size.spawn())
            case let .system(.`default`(size, .some(weight))): return UIFont.systemFont(ofSize: size.spawn(), weight: weight)
            case let .system(.monospaced(size, weight)): return UIFont.monospacedSystemFont(ofSize: size.spawn(), weight: weight)
            case let .system(.monospacedDigit(size, weight)): return UIFont.monospacedDigitSystemFont(ofSize: size.spawn(), weight: weight)
            case let .system(.bold(size)): return UIFont.boldSystemFont(ofSize: size.spawn())
            case let .system(.italic(size)): return UIFont.italicSystemFont(ofSize: size.spawn())
            case let .descriptor(x):
                var font = UIFont.preferredFont(forTextStyle: x.style)
                if let design = x.design {
                    var desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: x.style)
                    desc = desc.withDesign(design) ?? desc
                    font = UIFont(descriptor: desc, size: desc.pointSize)
                }
                if let size = x.size {
                    font = font.withSize(size)
                }
                return font
            }
        }
    }
}
#endif
