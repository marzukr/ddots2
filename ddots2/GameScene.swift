//
//  GameScene.swift
//  ddots2
//
//  Created by Marzuk Rashid on 12/29/16.
//  Copyright © 2016 Platiplur. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var sliders:[SKShapeNode]! = []
    var scrollSpeed:CGFloat = 2
    let redColor = UIColor(red: 242/255, green: 38/255, blue: 19/255, alpha: 1)
    let blueColor = UIColor(red: 25/255, green: 181/255, blue: 254/255, alpha: 1)
    let greenColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    let yellowColor = UIColor(red: 247/255, green: 202/255, blue: 24/255, alpha: 1)
    var colors:[UIColor]! = []
    
    var dots:[SKShapeNode]! = []
    
    var titleLabel:SKLabelNode!
    var playLabel:SKLabelNode!
    
    var noAdsIcon:SKSpriteNode!
    var infoIcon:SKSpriteNode!
    var rateIcon:SKSpriteNode!
    var rankIcon:SKSpriteNode!
    var buttons:[SKSpriteNode]! = []
    
    var isOnMenu:Bool = true
    var isTouchingScreen:Bool = false
    
    struct PhysicsCategory
    {
        static let none:UInt32 = 0
        static let ball:UInt32 = 0b01 //1
        static let bar:UInt32 = 0b10 //2
        static let all:UInt32 = UInt32.max
    }
    
    override func didMove(to view: SKView)
    {
        self.scene?.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 239/255, alpha: 1)
        self.physicsWorld.contactDelegate = self
        colors = [redColor,blueColor,greenColor,yellowColor]
        
        setupMenuLabels()
        
        for i in -2...2
        {
            let slider = initiateSliders(number: i)
            self.addChild(slider)
            sliders.append(slider)
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isOnMenu
        {
            slideSliders()
        }
        else
        {
            if isTouchingScreen
            {
                slideSliders()
            }
            
            for (index,dot) in dots.enumerated()
            {
                if dot.position.y <= CGFloat(-1 * (self.frame.height/2 + 75/2))
                {
                    dot.removeFromParent()
                    dots.remove(at: index)
                }
            }
            
            if dots.count < 1
            {
                spawnDots()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            if isOnMenu
            {
                var isButton = false
                for button in buttons
                {
                    if button.contains(location)
                    {
                        button.colorBlendFactor = 0.5
                        isButton = true
                    }
                }
                if !isButton
                {
                    let moveRight = SKAction.moveBy(x: self.frame.width/2, y: 0, duration: 0.25)
                    let moveLeft = SKAction.moveBy(x: self.frame.width/2 * -1, y: 0, duration: 0.25)
                    let moveUp = SKAction.moveBy(x: 0, y: self.frame.height/2, duration: 0.25)
                    let disappear = SKAction.fadeAlpha(to: 0, duration: 0.25)
                    noAdsIcon.run(moveRight)
                    infoIcon.run(moveRight)
                    rateIcon.run(moveLeft)
                    rankIcon.run(moveLeft)
                    titleLabel.run(moveUp)
                    playLabel.run(disappear)
                    scrollSpeed = 12
                    isOnMenu = false
                }
            }
            else
            {
                isTouchingScreen = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isOnMenu
        {
            for button in buttons
            {
                button.colorBlendFactor = 0
            }
        }
        else
        {
            isTouchingScreen = false
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if contact.bodyA.node?.name == contact.bodyB.node?.name
        {
            print("Same Color Collision")
        }
        else
        {
            print("Game Over")
        }
    }
    
    func spawnDots()
    {
        var randomAbs = CGFloat(arc4random_uniform(UInt32(self.frame.width/2 - 50 - 75/2)))
        if drand48() >= 0.5
        {
            randomAbs = randomAbs * -1
        }
        let randomColorIndex = Int(arc4random_uniform(UInt32(colors.count)))
        
        let dot = SKShapeNode.init(circleOfRadius: 75/2)
        dot.fillColor = colors[randomColorIndex]
        dot.name = String(colors[randomColorIndex].description)
        dot.strokeColor = UIColor.clear
        dot.position = CGPoint(x: randomAbs, y: self.frame.height/2 + dot.frame.height/2)
        dot.physicsBody = SKPhysicsBody(circleOfRadius: 75/2)
        dot.physicsBody?.affectedByGravity = false
        dot.physicsBody?.categoryBitMask = PhysicsCategory.ball
        dot.physicsBody?.collisionBitMask = PhysicsCategory.none
        dot.physicsBody?.contactTestBitMask = PhysicsCategory.bar
        let moveDown = SKAction.moveTo(y: -1 * (self.frame.height/2 + dot.frame.height/2), duration: 3)
        dot.run(moveDown)
        dots.append(dot)
        self.addChild(dot)
    }
    
    func setupMenuLabels()
    {
        titleLabel = self.childNode(withName: "titleLabel") as! SKLabelNode
        titleLabel.position = CGPoint(x: 0, y: self.frame.height/4)
        titleLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        titleLabel.verticalAlignmentMode = .center
        
        playLabel = self.childNode(withName: "playLabel") as! SKLabelNode
        playLabel.position = CGPoint(x: 0, y: titleLabel.position.y - titleLabel.frame.height/2 - 75)
        playLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        
        noAdsIcon = self.childNode(withName: "noAdsIcon") as! SKSpriteNode
        noAdsIcon.position = CGPoint(x: 25 + 50, y: 0)
        
        infoIcon = self.childNode(withName: "infoIcon") as! SKSpriteNode
        infoIcon.position = CGPoint(x: noAdsIcon.position.x + 150, y: 0)
        
        rateIcon = self.childNode(withName: "rateIcon") as! SKSpriteNode
        rateIcon.position = CGPoint(x: noAdsIcon.position.x - 150, y: 0)
        
        rankIcon = self.childNode(withName: "rankIcon") as! SKSpriteNode
        rankIcon.position = CGPoint(x: rateIcon.position.x - 150, y: 0)
        
        buttons = [noAdsIcon, infoIcon, rateIcon, rankIcon]
        
        for button in buttons
        {
            button.color = SKColor.black
        }
    }
    
    func slideSliders()
    {
        for node in sliders
        {
            node.position.x += self.scrollSpeed
            
            if node.position.x > (self.frame.width/2)
            {
                self.colors.insert(self.colors.last!, at: 0)
                self.colors.removeLast(1)
                
                node.position.x -= self.frame.width + node.frame.width
                node.fillColor = colors.last!
                node.name = String(colors.last!.description)
            }
        }
    }
    
    func initiateSliders(number: Int) -> SKShapeNode
    {
        let rect = CGRect(x: 0, y: -1 * self.frame.height/4 - 25, width: self.frame.width/4, height: 50)
        let slider = SKShapeNode(rect: rect)
        slider.strokeColor = UIColor.clear
        slider.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: rect.width, height: rect.height), center: CGPoint(x: rect.midX, y: rect.midY))
        slider.physicsBody?.affectedByGravity = false
        slider.physicsBody?.categoryBitMask = PhysicsCategory.bar
        slider.physicsBody?.collisionBitMask = PhysicsCategory.none
        slider.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        if number != 2
        {
            slider.fillColor = colors[number+2]
            slider.name = String(colors[number+2].description)
            slider.position.x = self.frame.width * (CGFloat(2*number)/8)
        }
        else
        {
            slider.fillColor = colors[3]
            slider.name = String(colors[3].description)
            slider.position.x = self.frame.width * (-6/8)
        }
        return slider
    }
}
