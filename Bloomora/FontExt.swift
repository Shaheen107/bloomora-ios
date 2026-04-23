import UIKit

extension UIFont {
    static func bloomoraSerif(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let name: String
        switch weight {
        case .bold, .heavy, .black, .semibold:
            name = "PlayfairDisplay-SemiBold"
        case .medium:
            name = "PlayfairDisplay-Medium"
        default:
            name = "PlayfairDisplay-Regular"
        }

        if let font = UIFont(name: name, size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    static func bloomoraSerifItalic(size: CGFloat) -> UIFont {
        if let font = UIFont(name: "PlayfairDisplay-Italic", size: size) {
            return font
        }
        let base = UIFont.systemFont(ofSize: size, weight: .regular)
        guard let descriptor = base.fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: size)
    }

    static func bloomoraRounded(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: size)
    }
}

extension UIColor {
    convenience init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.init(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    static let bloomoraBackground = UIColor(red: 0.949, green: 0.949, blue: 0.957)
    static let bloomoraPrimaryText = UIColor(red: 0.10, green: 0.10, blue: 0.10)
    static let bloomoraSecondaryText = UIColor(red: 0.56, green: 0.58, blue: 0.60)
    static let bloomoraMutedText = UIColor(red: 0.47, green: 0.50, blue: 0.52)
    static let bloomoraGoalGreen = UIColor(red: 0.25, green: 0.76, blue: 0.40)
    static let bloomoraToggleGreen = UIColor(red: 0.40, green: 0.76, blue: 0.30)
}

extension UIView {
    @discardableResult
    func useAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview)
    }
}

extension UILabel {
    func setBloomoraText(_ text: String, lineSpacing: CGFloat = 0) {
        guard lineSpacing > 0 else {
            self.text = text
            return
        }

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = textAlignment
        paragraph.lineSpacing = lineSpacing
        attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font as Any,
                .foregroundColor: textColor as Any,
                .paragraphStyle: paragraph
            ]
        )
    }
}
