//
//  SolidColorButton.swift
//  PassioAppModule
//
//  Created by Patrick Goley on 4/20/21.
//

import UIKit

@IBDesignable
open class ColoredButton: UIButton {

    fileprivate var colorsByState: [UInt: UIColor] = [:]

    @IBInspectable open var normalBackgroundColor: UIColor? {

        get { return colorForState(.normal) }

        set { setBackgroundColor(newValue, for: .normal) }
    }

    @IBInspectable open var highlightedBackgroundColor: UIColor? {

        get { return colorForState(.highlighted) }

        set { setBackgroundColor(newValue, for: .highlighted) }
    }

    @IBInspectable open var selectedBackgroundColor: UIColor? {

        get { return colorForState(.selected) }

        set { setBackgroundColor(newValue, for: .selected) }
    }

    open func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {

        setColorForState(color, state)

        updateBackgroundColorForCurrentState()
    }

    func colorForState(_ state: UIControl.State) -> UIColor? {

        return colorsByState[state.rawValue]
    }

    func setColorForState(_ color: UIColor?, _ state: UIControl.State) {

        var dict = colorsByState

        dict[state.rawValue] = color

        colorsByState = dict

        updateBackgroundColorForCurrentState()
    }

    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.masksToBounds = true
            self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable open var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    public override init(frame: CGRect) {

        super.init(frame: frame)

        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {

        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {

        updateBackgroundColorForCurrentState()

        if highlightedBackgroundColor == nil {

            highlightedBackgroundColor = normalBackgroundColor?.colorByDarkening(0.3)
        }
    }

    override open var isHighlighted: Bool {

        didSet {

            updateBackgroundColorForCurrentState()
        }
    }

    override open var isSelected: Bool {

        didSet {

            updateBackgroundColorForCurrentState()
        }
    }

    fileprivate func updateBackgroundColorForCurrentState() {

        if let color = colorForState(state) {

            backgroundColor = color
        } else {

            backgroundColor = normalBackgroundColor
        }
    }
}

private extension UIColor {

    func colorByDarkening(_ factor: CGFloat) -> UIColor {

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        if getRed(&r, green: &g, blue: &b, alpha: &a) {

            return UIColor(red: max(r - factor, 0.0), green: max(g - factor, 0.0), blue: max(b - factor, 0.0), alpha: a)
        }

        return UIColor()
    }
}
