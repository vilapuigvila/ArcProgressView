//
//  CircularProgressView.swift
//  Path
//
//  Created by albert vila on 27/06/2020.
//  Copyright © 2020 albert vila. All rights reserved.
//

import UIKit

public protocol CircularProgressViewDelegate: AnyObject {
    func circularProgressView(_ view: CircularProgressView, thumbValue: Double)
}

public class CircularProgressView: UIView {
    
    private(set) lazy var thumbView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: configuration.thumbRadius, height: configuration.thumbRadius))
        view.layer.cornerRadius = configuration.thumbRadius / 2
        view.backgroundColor    = configuration.thumbColor
        return view
    }()
    private(set) lazy var lbLeft: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .black
        view.textAlignment = .center
        view.text = "-15%"
        return view
    }()
    private(set) lazy var lbRight: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .black
        view.textAlignment = .center
        view.text = "15%"
        return view
    }()
    
    private var viewCenter: CGPoint { CGPoint(x: frame.width / 2, y: frame.width / 2) }
    
    private(set) var arcLimits: ArcLimits = .default
    private(set) var configuration: Configuration
    
    private lazy var radius: CGFloat = frame.width / 2
    private lazy var thumbValue: Double = initialThumbPosition
        
    // MARK: - Public var -
    /// delegate
    public weak var delegate: CircularProgressViewDelegate?
    
    /// set initial thumb position, by default at center angle
    public var initialThumbPosition: Double = 0.5
    
    /// set start angle in degrees
    public lazy var startAngle: CGFloat = configuration.startAngle
    
    /// set end angle in degress
    public lazy var endAngle: CGFloat = configuration.endAngle

    @available(iOS 10.0, *)
    private lazy var impact: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        return generator
    }()
    
    // MARK: - unavailable -
    override private init(frame: CGRect) { fatalError() }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Life Cycle -
    public init(frame: CGRect, configuration: Configuration = .default) {
        assert(frame.width == frame.height, "only allow square views")
        
        self.configuration = configuration
        super.init(frame: frame)
        
        addPanGestureInThumb()
        addDoubleTapGestureInThumb()
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        drawArcPath(rect: frame)
        
        setupLabels()
    }
    
    private func drawArcPath(rect: CGRect) {
        radius = (rect.width / 2) - (configuration.thumbRadius / 2)
        arcLimits.setupVaues(viewCenter, radius: radius,
                             startAngle: startAngle,
                             endAngle: endAngle)
        
        let arcPath = UIBezierPath(arcCenter: viewCenter,
                                   radius: radius,
                                   startAngle: startAngle.toRadians(),
                                   endAngle: endAngle.toRadians(),
                                   clockwise: true)
    
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = arcPath.cgPath
        shapeLayer.fillColor = configuration.fillColor.cgColor
        shapeLayer.strokeColor = configuration.strokeColor.cgColor
        shapeLayer.lineWidth = configuration.lineWidth
        layer.addSublayer(shapeLayer)
        
        let thumbPosition = Rescale(from: (0, 1), to: (-225, 45)).rescaleAndClamp(initialThumbPosition)
        thumbView.center = pointInArc(angle: thumbPosition)
        addSubview(thumbView)
    }
    
    private func addPanGestureInThumb() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragThumb(recognizer:)))
        thumbView.addGestureRecognizer(panGesture)
    }
    
    private func addDoubleTapGestureInThumb() {
        let panGesture = UITapGestureRecognizer(target: self, action: #selector(moveThumbToCenterArc))
        panGesture.numberOfTapsRequired = 2
        addGestureRecognizer(panGesture)
    }
    
    @objc private func moveThumbToCenterArc() {
        let thumbPosition = Rescale(from: (0, 1), to: (-225, 45)).rescaleAndClamp(initialThumbPosition)
        thumbView.center = pointInArc(angle: thumbPosition)
        delegate?.circularProgressView(self, thumbValue: 0.5)
        impact.impactOccurred()
    }
    
    private func normalizeThumbValue(value: Double) {
        let normalize = Rescale(from: (startAngle, endAngle), to: (0, 1))
        thumbValue = Double(normalize.rescaleAndClamp(CGFloat(value))).round(places: 3)
        if thumbValue == 0.5 {
            if #available(iOS 13.0, *) {
                impact.impactOccurred(intensity: 0.8)
            }
        }
    }
    
    @objc private func dragThumb(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)

        guard let angle = getAngleOfTouchPoint(start: viewCenter, end: point) else {
            return
        }
        normalizeThumbValue(value: angle)
        delegate?.circularProgressView(self, thumbValue: thumbValue)
        
        thumbView.center = pointInArc(angle: angle)
    }
    
    private func getAngleOfTouchPoint(start: CGPoint, end: CGPoint) -> Double? {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let absDy = abs(dy)

        let constraint = Double.pi / 4
        var radians = Double(atan(absDy / dx))
        
        let quarter = TouchInCircle(dx: dx, dy: dy)
        
        if quarter.isInDownSide {
            radians = min(constraint, max(-constraint, radians))
        }
        
        let addition: Double = dx < 0 ? 180 : 0
        let degrees = (radians * 360 / (2.0 * Double.pi)) + addition
        
        let normalized: Double = {
            switch quarter {
            case .rightDown:
                return degrees
            case .leftDown:
                let diff = 180 - degrees
                return (180 + diff) * -1
            case .rightUp, .leftUp:
                return degrees * -1
            }
        }()
        
        if arcLimits.rightBoundsRange.contains(normalized) && quarter != .leftDown && thumbView.center == arcLimits.startPoint ||
           arcLimits.leftBoundsRange.contains(normalized) && quarter != .rightDown && thumbView.center == arcLimits.endPoint {
            return nil
        }
        return normalized
    }
    
    private func pointInArc(angle: Double) -> CGPoint {
        return CGPoint.pointOnCircle(center: viewCenter, radius: radius, angle: angle.toRadians())
    }
    
    private func setupLabels() {
        let width = frame.width / 3
        let offsetY = configuration.thumbRadius * 0.6
        let fontHeight = lbRight.font.lineHeight
        
        lbLeft.frame = CGRect(x: 0, y: 0, width: width, height: fontHeight)
        lbLeft.center = CGPoint(x: arcLimits.startPoint.x + 2, y: arcLimits.startPoint.y + offsetY)
        addSubview(lbLeft)
        
        lbRight.frame = CGRect(x: 0, y: 0, width: width, height: fontHeight)
        lbRight.center = CGPoint(x: arcLimits.endPoint.x - 2, y: arcLimits.endPoint.y + offsetY)
        addSubview(lbRight)
    }
}

// MARK: - Helper's -
public extension CircularProgressView {
    
    enum TouchInCircle {
        case rightUp
        case rightDown
        case leftUp
        case leftDown
        
        public init(dx: CGFloat, dy: CGFloat) {
            if dy > 0 && dx > 0 {
                self = .rightDown
            } else if dy > 0 && dx < 0 {
                self = .leftDown
            } else if dy < 0 && dx > 0 {
                self = .rightUp
            } else  {
                self = .leftUp
            }
        }
        
        public var isInDownSide: Bool {
            switch self {
            case .rightDown, .leftDown: return true
            default: return false
            }
        }
    }
}

public extension CircularProgressView {
    
    struct ArcLimits: Equatable {
        private(set) var startPoint: CGPoint
        private(set) var endPoint: CGPoint
        
        private(set) var leftBoundsRange: ClosedRange<Double> = 0...0
        private(set) var rightBoundsRange: ClosedRange<Double> = 0...0
        
        public static var `default`: Self {
            .init(startPoint: .zero, endPoint: .zero)
        }
        
        public mutating func setupVaues<T: BinaryFloatingPoint>(_ center: CGPoint, radius: T, startAngle: T, endAngle: T) {
            startPoint = CGPoint.pointOnCircle(center: center, radius: CGFloat(radius), angle: Double(startAngle).toRadians())
            endPoint   = CGPoint.pointOnCircle(center: center, radius: CGFloat(radius), angle: Double(endAngle).toRadians())
            
            leftBoundsRange = Double(startAngle)...0.0
            rightBoundsRange = -180.0...Double(endAngle)
        }
    }
    
    struct ArcAngle: Equatable {
        let start: CGFloat
        let end: CGFloat
        
        public static var `default`: Self {
            .init(start: 0, end: 0)
        }
    }
}

public extension CircularProgressView {
    struct Configuration {
        let fillColor: UIColor
        let strokeColor: UIColor
        let lineWidth: CGFloat
        
        let thumbRadius: CGFloat
        let thumbColor: UIColor
        
        let startAngle: CGFloat
        let endAngle: CGFloat
        
        public static var `default`: Self {
            .init(
                fillColor: .clear,
                strokeColor: .gray,
                lineWidth: 1.5,
                thumbRadius: 25.0,
                thumbColor: .orange,
                startAngle: -CGFloat(225.0),
                endAngle: CGFloat(45)
            )
        }
    }
}
