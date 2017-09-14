//
//  TMConfettiView.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 6/30/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import QuartzCore

class TMConfettiView: UIView {
    
    var emitter: CAEmitterLayer!
    var colors: [UIColor]!
    var intensity: Float!
    
    fileprivate var active :Bool!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
    }
    
    func setup() {
        emitter = CAEmitterLayer()

        colors = [UIColor.TMColorWithRGBFloat(255.0, green: 103.0, blue: 93.0, alpha: 1.0),
                  UIColor.TMColorWithRGBFloat(252.0, green: 203.0, blue: 232.0, alpha: 1.0),
                  UIColor.TMColorWithRGBFloat(273.0, green: 180.0, blue: 135.0, alpha: 1.0)
        ]
        intensity = 0.2
        
        active = false
    }
    
    func startConfetti() {
        emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: -20)
        emitter.emitterShape = kCAEmitterLayerLine
        
        var cells = [CAEmitterCell]()
        for (index, color) in colors.enumerated() {
            cells.append(confettiWithColor(color, index: index))
        }
        
        emitter.emitterCells = cells
        layer.addSublayer(emitter)
        active = true
    }
    
    func stopConfetti() {
        emitter?.birthRate = 0
        active = false
    }
    
    func confettiWithColor(_ color: UIColor, index: Int) -> CAEmitterCell {
        let confetti = CAEmitterCell()
        
        confetti.name = "\(index)"
        confetti.birthRate = 4.0 * intensity
        confetti.lifetime = 180.0 * intensity
        confetti.lifetimeRange = 0
        confetti.color = color.cgColor
        confetti.velocity = CGFloat(250.0 * intensity)
        confetti.velocityRange = CGFloat(80.0 * intensity)
        confetti.emissionLongitude = CGFloat.pi
        confetti.emissionRange = CGFloat.pi/4
        confetti.spin = CGFloat(3.5 * intensity)
        confetti.spinRange = CGFloat(4.0 * intensity)
        
        confetti.alphaSpeed = -1.0 / 180.0 * intensity
        confetti.redSpeed = -1.0 / 180.0 * intensity
        confetti.blueSpeed = -1.0 / 180.0 * intensity
        confetti.greenSpeed = -1.0 / 180.0 * intensity
        
        confetti.contents = UIImage(named: "confetti")?.cgImage
        return confetti
    }
    
    internal func isActive() -> Bool {
        return self.active
    }
}
