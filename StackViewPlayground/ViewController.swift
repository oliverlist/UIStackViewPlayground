import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var axisButton: UIBarButtonItem!
    @IBOutlet weak var alignmentButton: UIBarButtonItem!
    @IBOutlet weak var distributionButton: UIBarButtonItem!
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var debugView: DebugView!
    @IBOutlet var hConstraint: NSLayoutConstraint!
    @IBOutlet var vConstraint: NSLayoutConstraint!

    @IBAction func onToggleAxis(_ sender: Any) {
        outerStackView.axis = outerStackView.axis.next()
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        self.debugView.setNeedsDisplay()
        updateButtonLabels()
    }

    @IBAction func onToggleAlignment(_ sender: Any) {
        outerStackView.alignment = outerStackView.alignment.next(axis: outerStackView.axis)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.debugView.setNeedsDisplay()
        }
        updateButtonLabels()
    }

    @IBAction func onToggleDistribution(_ sender: Any) {
        outerStackView.distribution = outerStackView.distribution.next()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.debugView.setNeedsDisplay()
        }
        updateButtonLabels()
    }

    @IBAction func onReset(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            for view in self.outerStackView.arrangedSubviews {
                view.isHidden = false
            }
        }
        debugView.setNeedsDisplay()
    }

    @IBAction func onSize(_ sender: Any) {
        hConstraint.isActive = !hConstraint.isActive
        vConstraint.isActive = !vConstraint.isActive
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        debugView.setNeedsDisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        debugView.add(view: outerStackView, type: .bounds, color:UIColor(red: 0, green: 1, blue: 0, alpha: 0.5))
        for view in outerStackView.arrangedSubviews {
            debugView.add(view: view, type: [], color: UIColor(red: 0, green: 0, blue: 1, alpha: 0.5))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTap(_:)))
            view.addGestureRecognizer(tapRecognizer)
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onDoubleTap(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTapRecognizer)
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress(_:)))
            view.addGestureRecognizer(longPressRecognizer)

        }
        updateButtonLabels()
    }

    func updateButtonLabels() {
        axisButton.title = "Ax: " + String(describing: outerStackView.axis)
        alignmentButton.title = "Al: " + String(describing: outerStackView.alignment)
        distributionButton.title = "Dst: " + String(describing: outerStackView.distribution)
    }

    func onTap(_ sender: UITapGestureRecognizer) {
        debugView.toggleTypeFor(view: sender.view!)
        debugView.setNeedsDisplay()
    }

    func onDoubleTap(_ sender: UITapGestureRecognizer) {
        debugView.resetTypeFor(view: sender.view!)
        debugView.setNeedsDisplay()
    }

    func onLongPress(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25) {
            sender.view!.isHidden = true;
        }
        debugView.setNeedsDisplay()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        debugView.setNeedsDisplay()
    }
}

extension UILayoutConstraintAxis: CustomStringConvertible {
    public var description: String {
        switch self {
        case .horizontal:
            return "H"
        case .vertical:
            return "V"
        }
    }

    func next() -> UILayoutConstraintAxis {
        switch self {
        case .horizontal:
            return .vertical
        default:
            return .horizontal
        }
    }
}

extension UIStackViewAlignment: CustomStringConvertible {
    func next() -> UIStackViewAlignment {
        let raw = rawValue < UIStackViewAlignment.lastBaseline.rawValue ? rawValue + 1 : 0
        return UIStackViewAlignment(rawValue: raw)!
    }

    func next(axis: UILayoutConstraintAxis) -> UIStackViewAlignment {
        if axis == UILayoutConstraintAxis.vertical {
            var alignment = next()
            while alignment == UIStackViewAlignment.firstBaseline || alignment == UIStackViewAlignment.lastBaseline {
                alignment = alignment.next()
            }
            return alignment
        }
        return next()
    }

    public var description: String {
        switch self {
        case .fill:
            return "Fill"
        case .center:
            return "Center"
        case .firstBaseline:
            return "1st base (H*)"
        case .lastBaseline:
            return "Last base (H*)"
        case .leading:
            return "Leading"
        case .trailing:
            return "Trailing"
        }
    }
}

extension UIStackViewDistribution: CustomStringConvertible {
    func next() -> UIStackViewDistribution {
        let raw = rawValue < UIStackViewDistribution.equalCentering.rawValue ? rawValue + 1 : 0
        return UIStackViewDistribution(rawValue: raw)!
    }

    public var description: String {
        switch self {
        case .equalCentering:
            return "== Center"
        case .equalSpacing:
            return "== Space"
        case .fill:
            return "Fill"
        case .fillEqually:
            return "== Fill"
        case .fillProportionally:
            return "prop Fill"
        }
    }
}
