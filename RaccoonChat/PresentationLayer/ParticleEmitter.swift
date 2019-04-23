//
//  TouchesAnalyzer.swift
//  RaccoonChat
//
//  Created by Анна Якусевич on 22/04/2019.
//  Copyright © 2019 Hanna Yakusevych. All rights reserved.
//

import Foundation

class ParticleEmitter: UIView {

  var particleEmitter = CAEmitterLayer()
  var lastParticleEmitter: CAEmitterLayer!

  func touchBegan(_ position: CGPoint) {
    self.particleEmitter.lifetime = 0
    self.lastParticleEmitter = self.particleEmitter
    self.particleEmitter = CAEmitterLayer()
    self.particleEmitter.lifetime = 1
    self.createParticles(in: position)
  }
  func touchEnded(_ position: CGPoint) {
    self.particleEmitter.lifetime = 0
  }

  func createParticles(in position: CGPoint) {
    particleEmitter.emitterPosition = position
    particleEmitter.emitterShape = .point
    particleEmitter.emitterSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)

    particleEmitter.emitterCells = [makeEmitterCell(), makeEmitterCell(), makeEmitterCell(), makeEmitterCell()]

    self.layer.addSublayer(self.particleEmitter)
  }
  func makeEmitterCell() -> CAEmitterCell {
    let cell = CAEmitterCell()
    cell.birthRate = 4
    cell.emissionLongitude = .pi / 2.0
    cell.emissionRange = CGFloat.pi / 2.0
    cell.lifetime = 0.8
    cell.scale = 0.02
    cell.scaleRange = 0.01
    cell.velocity = 80

    cell.contents = UIImage(named: "tinkoff")?.cgImage
    return cell
  }
}
