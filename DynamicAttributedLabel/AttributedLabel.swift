import Foundation
import UIKit

public class AttributedLabel: UILabel {
  var sendTraits: Bool = false

  public init(text: String, sendTraits: Bool = false) {
    self.sendTraits = sendTraits
    super.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false

    self.text = text

    adjustsFontForContentSizeCategory = true
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(adjustTextSizeForContentSizeCategory),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil
    )
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  public override var text: String? {
    didSet {
      setAttributedText()
    }
  }

  @objc private func adjustTextSizeForContentSizeCategory() {
    setAttributedText()
  }

  private func setAttributedText() {
    guard let text else { return }

    let attributedString = NSMutableAttributedString(
      attributedString: .attributedString(
        with: text,
        traits: sendTraits ? traitCollection : nil
      )
    )
    scaleLineHeightFor(attributedString)

    let savedAlignment = textAlignment
    attributedText = attributedString
    textAlignment = savedAlignment
  }

  private func scaleLineHeightFor(_ string: NSMutableAttributedString) {
    string.enumerateAttribute(
      .paragraphStyle,
      in: NSRange(location: 0, length: string.length),
      options: [],
      using: { value, range, _ in
        if let paragraphStyle = value as? NSMutableParagraphStyle,
           let newParagraphStyle = paragraphStyle.mutableCopy() as? NSMutableParagraphStyle,
           let font = string.attribute(
            .font, at: range.location, effectiveRange: nil
           ) as? UIFont {
          let lineHeight = font.lineHeight
          newParagraphStyle.minimumLineHeight = lineHeight
          newParagraphStyle.maximumLineHeight = lineHeight
          string.addAttribute(
            .paragraphStyle,
            value: newParagraphStyle,
            range: range
          )

          string.addAttribute(
            .baselineOffset,
            value: 0,
            range: range
          )
        }
      }
    )
  }
}

extension NSAttributedString {
  static func attributedString(with text: String, traits: UITraitCollection?) -> NSAttributedString {
    NSAttributedString(string: text, attributes: attributes(traits))
  }

  static func attributes(_ traits: UITraitCollection?) -> [NSAttributedString.Key: Any] {
    let font = UIFont.systemFont(ofSize: 18, weight: .bold).scaledFont(traits)
    let lineHeight = CGFloat(22)

    let paragraph = NSMutableParagraphStyle()
    paragraph.minimumLineHeight = lineHeight
    paragraph.maximumLineHeight = lineHeight

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .paragraphStyle: paragraph,
      .kern: 0.1,
      .baselineOffset: (lineHeight - font.lineHeight) / 2.0
    ]

    return attributes
  }
}

extension UIFont {
  func scaledFont(_ traits: UITraitCollection?) -> UIFont {
    if let traits {
      return UIFontMetrics.default.scaledFont(for: self, compatibleWith: traits)
    } else {
      return UIFontMetrics.default.scaledFont(for: self)
    }
  }
}
