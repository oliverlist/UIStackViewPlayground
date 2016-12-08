import UIKit

struct OutlineType: OptionSet {
    let rawValue: Int
    static let bounds = OutlineType(rawValue: 0x10)
    static let verticalBounds = OutlineType(rawValue: 0x1)
    static let horizontalBounds = OutlineType(rawValue: 0x2)
    static let verticalCenter = OutlineType(rawValue: 0x4)
    static let horizontalCenter = OutlineType(rawValue: 0x8)

    func next() -> OutlineType {
        switch self.rawValue {
        case OutlineType.bounds.rawValue:
            return .verticalCenter

        case OutlineType.verticalCenter.rawValue:
            return .horizontalCenter

        case OutlineType.horizontalCenter.rawValue:
            return .bounds

        default:
            return .bounds
        }
    }
}

struct OutlineInfo {
    var view: UIView
    var type: OutlineType
    var color: UIColor

    func cycleOutline() -> OutlineInfo {
        return OutlineInfo(view: view, type: type.next(), color: color)
    }

    func resetOutline() -> OutlineInfo {
        return OutlineInfo(view: view, type: [], color: color)
    }
}

class DebugView: UIView {
    var viewInfos:Array<OutlineInfo> = Array()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        backgroundColor = UIColor.clear
    }

    public func add(view: UIView, type: OutlineType, color: UIColor) {
        let info = OutlineInfo(view: view, type: type, color: color)
        viewInfos.append(info)
    }

    public func toggleTypeFor(view: UIView) {
        viewInfos = viewInfos.map { (info: OutlineInfo) -> OutlineInfo in
            return info.view == view ? info.cycleOutline() : info
        }
    }

    public func resetTypeFor(view: UIView) {
        viewInfos = viewInfos.map { (info: OutlineInfo) -> OutlineInfo in
            return info.view == view ? info.resetOutline() : info
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        for info in viewInfos {
            let view = info.view
            if view.isHidden {
                continue
            }

            let left = convert(CGPoint.zero, from: view).x
            let top = convert(CGPoint.zero, from: view).y
            let right = convert(CGPoint(x: view.bounds.maxX, y: 0), from: view).x
            let bottom = convert(CGPoint(x: 0, y: view.bounds.maxY), from: view).y

            context.setFillColor(UIColor.clear.cgColor)
            context.setLineWidth(1)
            context.setStrokeColor(info.color.cgColor)

            if info.type.contains(.bounds) {
                context.addRect(convert(view.bounds, from: view))
            }

            if info.type.contains(.horizontalBounds) {
                context.move(to: CGPoint(x: 0, y: top))
                context.addLine(to: CGPoint(x: rect.maxX, y: top))

                context.move(to: CGPoint(x: 0, y: bottom))
                context.addLine(to: CGPoint(x: rect.maxX, y: bottom))
            }
            if info.type.contains(.verticalBounds) {
                context.move(to: CGPoint(x: left, y: 0))
                context.addLine(to: CGPoint(x: left, y: rect.maxY))

                context.move(to: CGPoint(x: right, y: 0))
                context.addLine(to: CGPoint(x: right, y: rect.maxY))
            }
            if info.type.contains(.horizontalCenter) {
                context.move(to: CGPoint(x: 0, y: 0.5*(bottom + top)))
                context.addLine(to: CGPoint(x: rect.maxX, y: 0.5*(bottom + top)))
            }
            if info.type.contains(.verticalCenter) {
                context.move(to: CGPoint(x: 0.5*(left + right), y: 0))
                context.addLine(to: CGPoint(x: 0.5*(left + right), y: rect.maxY))
            }

            context.strokePath()
        }
        context.restoreGState()
    }
}
