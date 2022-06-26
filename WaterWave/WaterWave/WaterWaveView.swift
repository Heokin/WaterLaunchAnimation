//
//  WaterWaveView.swift
//  WaterWave
//
//  Created by Stas Dashkevich on 26.06.22.
//

import Foundation
import UIKit

class WaterWaveView: UIView {
    
    //MARK: - Properties
    private let firstLayer = CAShapeLayer()
    private let secondLayer = CAShapeLayer()
    
    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear
    
    private let twon: CGFloat = .pi*2
    private var offset: CGFloat = 0.0
    
    private let percentLbl = UILabel()
    
    private let width = screenWidth*0.5
    
    var showSingleWave = false
    private var start = false
    
    var progress: CGFloat = 0.0
    var waveHeight: CGFloat = 0.0
    
    var timer = Timer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
}

extension WaterWaveView {
    
    private func setupViews() {
        bounds = CGRect(x: 0.0, y: 0.0, width: min(width, width), height: min(width, width))
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = width/2
        waveHeight = 8.0
        
        firstColor = .black
        secondColor = .red.withAlphaComponent(0.4)
        
        createFirstLayer()
        
        if !showSingleWave{
            createFirstLayer()
        }
        
        createPercentLabel()
    }
    
    private func createFirstLayer() {
        firstLayer.frame = bounds
        firstLayer.anchorPoint = .zero
        firstLayer.fillColor = firstColor.cgColor
        layer.addSublayer(firstLayer)
    }
    
    private func createSecondLayer() {
        secondLayer.frame = bounds
        secondLayer.anchorPoint = .zero
        secondLayer.fillColor = secondColor.cgColor
        layer.addSublayer(secondLayer)
    }
    
    func  createPercentLabel() {
        percentLbl.textAlignment = .center
        percentLbl.text = "99%"
        percentLbl.font = UIFont.boldSystemFont(ofSize: 30)
        percentLbl.textColor = .darkGray
        addSubview(percentLbl)
        percentLbl.translatesAutoresizingMaskIntoConstraints = false
        percentLbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        percentLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func percentAnim() {
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 1.0
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        
        percentLbl.layer.add(anim, forKey: nil)
    }
     func setUpProgress(_ pr: CGFloat) {
        progress = pr
         percentLbl.text = String(format: "%ld%%", NSNumber(value: Float(pr*50)).intValue)
         timer = Timer.scheduledTimer(withTimeInterval: 11, repeats: false, block: { block in
             self.percentLbl.textColor = .white
         })
         let top: CGFloat = pr * bounds.size.height/2
        firstLayer.setValue(width-top, forKeyPath: "position.y")
        secondLayer.setValue(width-top, forKeyPath: "position.y")
        
        if !start {
            DispatchQueue.main.async {
                self.statAnim()
            }
        }
    }
    
    private func statAnim() {
        start = true
        waterWaveAnim()
    }
    
    private func waterWaveAnim() {
        let w = bounds.size.width
        let h = bounds.size.height
        
        let bezier = UIBezierPath()
        let path = CGMutablePath()
        
        var originalOffsetY: CGFloat = 0.0
        let startOffsetY = waveHeight * CGFloat(sinf(Float(offset * twon / w)))
        
        path.move(to: CGPoint(x: 0.0, y: startOffsetY), transform: .identity)
        bezier.move(to: CGPoint(x: 0.0, y: startOffsetY))
        
        for i in stride(from: 0.0, to: w*1000, by: 1) {
            originalOffsetY = waveHeight * CGFloat(sinf(Float(twon / w * i + offset * twon / w)))
            bezier.addLine(to: CGPoint(x: i, y: originalOffsetY))
        }
        
        bezier.addLine(to: CGPoint(x: w*1000, y: originalOffsetY))
        bezier.addLine(to: CGPoint(x: w*1000, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: startOffsetY))
        bezier.close()
        
        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 2.0
        anim.fromValue = -w*0.5
        anim.toValue = -w - w*0.5
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        
        firstLayer.fillColor = firstColor.cgColor
        firstLayer.path = bezier.cgPath
        firstLayer.add(anim, forKey: nil)
        
        if !showSingleWave {
            let bezier = UIBezierPath()
            
            var originalOffsetY: CGFloat = 0.0
            let startOffsetY = waveHeight * CGFloat(sinf(Float(offset * twon / w)))
            
            bezier.move(to: CGPoint(x: 0.0, y: startOffsetY))
            
            for i in stride(from: 0.0, to: w*1000, by: 1) {
                originalOffsetY = waveHeight * CGFloat(cosf(Float(twon / w * i + offset * twon / w)))
                bezier.addLine(to: CGPoint(x: i, y: originalOffsetY))
            }
            
            bezier.addLine(to: CGPoint(x: w*1000, y: originalOffsetY))
            bezier.addLine(to: CGPoint(x: w*1000, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: startOffsetY))
            bezier.close()
            
            secondLayer.fillColor = secondColor.cgColor
            secondLayer.path = bezier.cgPath
            secondLayer.add(anim, forKey: nil)
        }
    }
}
