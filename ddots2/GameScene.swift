//
//  GameScene.swift
//  ddots2
//
//  Created by Marzuk Rashid on 12/29/16.
//  Copyright © 2016 Platiplur. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

var noAdsIcon:SKSpriteNode!

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate
{
    var sliders:[SKShapeNode]! = []
    var scrollSpeed:CGFloat = 2
    let gameScrollSpeed:CGFloat = 12
    let regScrollSpeed:CGFloat = 2
    let ballSpeed:CGFloat = 1409 / -3
    
    let redColor = UIColor(red: 242/255, green: 38/255, blue: 19/255, alpha: 1)
    let blueColor = UIColor(red: 25/255, green: 181/255, blue: 254/255, alpha: 1)
    let greenColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
    let yellowColor = UIColor(red: 247/255, green: 202/255, blue: 24/255, alpha: 1)
    var colors:[UIColor]! = []
    
    var dots:[SKShapeNode]! = []
    
    var titleLabel:SKLabelNode!
    var playLabel:SKLabelNode!
    
//    var noAdsIcon:SKSpriteNode!
    var infoIcon:SKSpriteNode!
    var rateIcon:SKSpriteNode!
    var rankIcon:SKSpriteNode!
    var homeIcon:SKSpriteNode!
    var shareIcon:SKSpriteNode!
    var retryIcon:SKSpriteNode!
    var buttons:[SKSpriteNode]! = []
    
    var isOnMenu:Bool = true
    var isOnGameOver:Bool = false
    var isOnInfoScreen:Bool = false
    var isTouchingScreen:Bool = false
    
    struct PhysicsCategory
    {
        static let none:UInt32 = 0
        static let ball:UInt32 = 0b001 //1
        static let bar:UInt32 = 0b010 //2
        static let edge:UInt32 = 0b100 //4
        static let all:UInt32 = UInt32.max
    }
    
    var moveRight:SKAction!
    var moveLeft:SKAction!
    var moveUp:SKAction!
    var moveDown:SKAction!
    
    var score:Int = 0
    var scoreCounterLabel:SKLabelNode!
    var scoreTitleLabel:SKLabelNode!
    var scoreLabel:SKLabelNode!
    var highScoreTitleLabel:SKLabelNode!
    var highScoreLabel:SKLabelNode!
    
    var producedLabel:SKLabelNode!
    var platiplurLabel:SKLabelNode!
    var codedLabel:SKLabelNode!
    var zukLabel:SKLabelNode!
    var musicLabel:SKLabelNode!
    var hessLabel:SKLabelNode!
    var infoBackdrop:SKShapeNode!
    var restorePurchasesLabel:SKLabelNode!
    
    //MARK: END OF VARIABLES
    
    override func didMove(to view: SKView)
    {
        authPlayer()
        self.scene?.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 239/255, alpha: 1)
        self.physicsWorld.contactDelegate = self
        
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.physicsBody?.categoryBitMask = PhysicsCategory.edge
//        self.physicsBody?.collisionBitMask = PhysicsCategory.ball
//        self.physicsBody?.contactTestBitMask = PhysicsCategory.none
//        self.physicsBody?.isDynamic = false
        
        setupBounds()
        
        colors = [redColor,blueColor,greenColor,yellowColor]
        
        moveRight = SKAction.moveBy(x: self.frame.width/2, y: 0, duration: 0.25)
        moveLeft = SKAction.moveBy(x: self.frame.width/2 * -1, y: 0, duration: 0.25)
        moveUp = SKAction.moveBy(x: 0, y: self.frame.height/2, duration: 0.25)
        moveDown = SKAction.moveBy(x: 0, y: self.frame.height/2 * -1, duration: 0.25)
        
        setupMenuLabels()
        
        for i in -2...2
        {
            let slider = initiateSliders(number: i)
            self.addChild(slider)
            sliders.append(slider)
        }
        print(self.frame)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isOnMenu || isOnGameOver
        {
            slideSliders()
        }
        else
        {
            if isTouchingScreen && !isOnGameOver
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
                else
                {
                    dot.physicsBody?.velocity.dy = ballSpeed
                }
            }
            
            if dots.count < 1 && !isOnGameOver
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
            if (isOnMenu || isOnGameOver) && isOnInfoScreen == false
            {
                var isButton = false
                for button in buttons
                {
                    if button.contains(location)
                    {
                        let userDefaults = Foundation.UserDefaults.standard
                        if !(button == noAdsIcon && userDefaults.bool(forKey: "didPurchaseNoAds") == true)
                        {
                            button.colorBlendFactor = 0.5
                        }
                        isButton = true
                        if button == homeIcon
                        {
                            startHomeOwnersAssociation()
                        }
                        if button == rankIcon
                        {
                            showLeaderBoard()
                        }
                        if button == infoIcon
                        {
                            infoCredits()
                        }
                        if button == rateIcon
                        {
                            rateApp(appId: "id1191366864", completion: { success in
                                button.colorBlendFactor = 0
                            })
                        }
                        if button == noAdsIcon && userDefaults.bool(forKey: "didPurchaseNoAds") == false
                        {
                            (self.view?.window?.rootViewController as! GameViewController).purchase(purchase: RegisteredPurchase.NoAds)
//                            (self.view?.window?.rootViewController as! GameViewController).restorePurchases()
                        }
                        if button == retryIcon
                        {
                            retry()
                        }
                        if button == shareIcon
                        {
                            share()
                        }
                    }
                }
                if !isButton && isOnMenu
                {
                    playLabel.removeAllActions()
                    let disappear = SKAction.fadeAlpha(to: 0, duration: 0.25)
                    noAdsIcon.run(moveRight, completion: ({
                        noAdsIcon.isHidden = true
                    }))
                    infoIcon.run(moveRight, completion: ({
                        self.infoIcon.isHidden = true
                    }))
                    rateIcon.run(moveLeft, completion: ({
                        self.rateIcon.isHidden = true
                    }))
                    rankIcon.run(moveLeft, completion: ({
                        self.rankIcon.isHidden = true
                    }))
                    titleLabel.run(moveUp, completion: ({
                        self.titleLabel.isHidden = true
                    }))
                    playLabel.run(disappear, completion: ({
                        self.playLabel.isHidden = true
                    }))
                    let fadeIn = SKAction.fadeIn(withDuration: 0.25)
                    scoreCounterLabel.run(fadeIn)
                    scrollSpeed = gameScrollSpeed
                    isOnMenu = false
                }
            }
            else if isOnInfoScreen
            {
                if platiplurLabel.contains(location)
                {
                    platiplurLabel.colorBlendFactor = 0.5
                    platiplurLabel.color = UIColor.black
                    let url = NSURL(string: "https://platiplur.com")
                    UIApplication.shared.open(url as! URL, options: [:], completionHandler: { (success) in
                        self.platiplurLabel.colorBlendFactor = 0
                    })
                }
                else if restorePurchasesLabel.contains(location)
                {
                    restorePurchasesLabel.colorBlendFactor = 0.5
                    restorePurchasesLabel.color = UIColor.black
                    (self.view?.window?.rootViewController as! GameViewController).restorePurchases(label: restorePurchasesLabel)
                }
                else
                {
                    dismissInfo()
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
        if isOnMenu || isOnGameOver
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
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            {
                score = score + (contact.bodyA.node?.userData!["Score"] as! Int)
                contact.bodyA.node?.userData?.setValue(0, forKey: "Score")
            }
            else
            {
                score = score + (contact.bodyB.node?.userData!["Score"] as! Int)
                contact.bodyB.node?.userData?.setValue(0, forKey: "Score")
            }
            scoreCounterLabel.text = "\(score)"
        }
        else
        {
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask && !isOnGameOver
            {
                gameOver(body: contact.bodyA)
            }
            else
            {
                gameOver(body: contact.bodyB)
            }
        }
    }
    
    //MARK: CUSTOM METHODS
    
    func setupBounds()
    {
        let set:[[CGPoint]] = [[CGPoint(x: self.frame.maxX, y: self.frame.minY), CGPoint(x: self.frame.maxX, y: self.frame.maxY)], [CGPoint(x: self.frame.minX, y: self.frame.minY), CGPoint(x: self.frame.minX, y: self.frame.maxY)]]
        for pointSet in set
        {
            let rightPath = CGMutablePath()
            rightPath.move(to: pointSet[0])
            rightPath.addLine(to: pointSet[1])
            let rightBound = SKShapeNode(path: rightPath)
            rightBound.physicsBody = SKPhysicsBody(edgeChainFrom: rightPath)
            rightBound.physicsBody?.categoryBitMask = PhysicsCategory.edge
            rightBound.physicsBody?.collisionBitMask = PhysicsCategory.ball
            rightBound.physicsBody?.contactTestBitMask = PhysicsCategory.none
            rightBound.physicsBody?.isDynamic = false
            self.addChild(rightBound)
        }
    }
    
    func updateNoAds()
    {
        let userDefaults = Foundation.UserDefaults.standard
        if userDefaults.bool(forKey: "didPurchaseNoAds") == true
        {
            let texture = SKTexture(image: UIImage(named: "noAdsPurchasedIcon")!)
            noAdsIcon.texture = texture
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func dismissInfo()
    {
        let newfadeOut = SKAction.fadeOut(withDuration: 0.25)
        let newMoveRight = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.25)
        let newMoveLeft = SKAction.moveBy(x: self.frame.width * -1, y: 0, duration: 0.25)
        codedLabel.run(newMoveRight)
        zukLabel.run(newMoveRight)
        musicLabel.run(newMoveLeft)
        hessLabel.run(newMoveLeft)
        producedLabel.run(newMoveLeft)
        platiplurLabel.run(newMoveLeft)
        restorePurchasesLabel.run(newMoveRight)
        infoBackdrop.run(newfadeOut, completion: ({
            self.isOnInfoScreen = false
        }))
    }
    
    func infoCredits()
    {
        isOnInfoScreen = true
        
        let newMoveRight = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.25)
        let newMoveLeft = SKAction.moveBy(x: self.frame.width * -1, y: 0, duration: 0.25)
        let newFadeIn = SKAction.fadeAlpha(to: 0.9, duration: 0.25)
        
        infoBackdrop.run(newFadeIn)
        codedLabel.run(newMoveLeft)
        zukLabel.run(newMoveLeft)
        musicLabel.run(newMoveRight)
        hessLabel.run(newMoveRight)
        producedLabel.run(newMoveRight)
        platiplurLabel.run(newMoveRight)
        restorePurchasesLabel.run(newMoveLeft)
    }
    
    func getScreenshot(scene: SKScene) -> UIImage
    {
        (self.view?.window?.rootViewController as! GameViewController).bannerView.isHidden = true
        let bounds = self.scene!.view?.bounds
        UIGraphicsBeginImageContextWithOptions(bounds!.size, true, UIScreen.main.scale)
        self.scene?.view?.drawHierarchy(in: bounds!, afterScreenUpdates: true)
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        (self.view?.window?.rootViewController as! GameViewController).bannerView.isHidden = false
        return screenShot!
    }
    
    func share()
    {
        let screenShot = getScreenshot(scene: self.scene!)
        let shareText = "OMG! I just got \(score) points in #SlideSort\nhttp://itunes.apple.com/app/id1191366864"
        let shareArray:[Any] = [screenShot,shareText]
        
        let activityVC = UIActivityViewController(activityItems: shareArray, applicationActivities: nil)
        (self.view?.window?.rootViewController as! GameViewController).present(activityVC, animated: true, completion: ({
            self.shareIcon.colorBlendFactor = 0
        }))
    }
    
    func retry()
    {
        homeIcon.run(moveLeft)
        rankIcon.run(moveLeft, completion: ({
            self.rankIcon.position.x -= 150
        }))
        rateIcon.run(moveRight, completion: ({
            self.rateIcon.position.x = self.rankIcon.position.x + 150
        }))
        noAdsIcon.run(moveRight, completion: ({
            noAdsIcon.position.x -= 150
            self.retryIcon.colorBlendFactor = 0
        }))
        scoreTitleLabel.run(moveUp)
        scoreLabel.run(moveUp)
        highScoreTitleLabel.run(moveUp)
        highScoreLabel.run(moveUp)
        retryIcon.run(moveLeft)
        shareIcon.run(moveRight)
        score = 0
        scoreCounterLabel.text = "\(0)"
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        scoreCounterLabel.run(fadeIn)
        scrollSpeed = gameScrollSpeed
        isOnGameOver = false
    }
    
    func startHomeOwnersAssociation()
    {
        infoIcon.position = CGPoint(x: noAdsIcon.position.x - self.frame.width, y: 0)
        let fakeNoAds:SKSpriteNode! = noAdsIcon.copy() as! SKSpriteNode
        fakeNoAds.position.x = infoIcon.position.x - 150
        self.addChild(fakeNoAds)
        let fakeRate:SKSpriteNode! = rateIcon.copy() as! SKSpriteNode
        fakeRate.position.x = fakeNoAds.position.x - 150
        self.addChild(fakeRate)
        let fakeRank:SKSpriteNode! = rankIcon.copy() as! SKSpriteNode
        fakeRank.position.x = fakeRate.position.x - 150
        self.addChild(fakeRank)
        
        let newMoveRight = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.375)
        let rightWingers:[SKSpriteNode] = [noAdsIcon,rateIcon,rankIcon,homeIcon]
        let altRightWingers:[SKLabelNode] = [scoreTitleLabel,scoreLabel,highScoreLabel,highScoreTitleLabel]
        for conservative in rightWingers
        {
            conservative.run(newMoveRight)
        }
        for neoNazi in altRightWingers
        {
            neoNazi.run(newMoveRight, completion: ({
                neoNazi.position = neoNazi.userData!["OP"] as! CGPoint
            }))
        }
        
//        noAdsIcon.run(newMoveRight)
//        rateIcon.run(newMoveRight)
//        rankIcon.run(newMoveRight)
//        homeIcon.run(newMoveRight)
        
        infoIcon.run(newMoveRight)
        fakeNoAds.run(newMoveRight, completion: ({
            noAdsIcon.position = fakeNoAds.position
            fakeNoAds.removeFromParent()
        }))
        fakeRate.run(newMoveRight, completion: ({
            self.rateIcon.position = fakeRate.position
            fakeRate.removeFromParent()
        }))
        fakeRank.run(newMoveRight, completion: ({
            self.rankIcon.position = fakeRank.position
            fakeRank.removeFromParent()
            self.isOnGameOver = false
            self.isOnMenu = true
            self.homeIcon.position = CGPoint(x: self.rankIcon.position.x - self.frame.width/2, y: 0)
        }))
        
        titleLabel.position = CGPoint(x: -1 * self.frame.width, y: self.frame.height/4)
        titleLabel.isHidden = false
        playLabel.position = CGPoint(x: -1 * self.frame.width, y: titleLabel.position.y - titleLabel.frame.height/2 - 75)
        playLabel.alpha = 1
        playLabel.isHidden = false
        titleLabel.run(newMoveRight)
        playLabel.run(newMoveRight)
        playLabel.run(playLabel.userData!["UA"] as! SKAction)
        
        shareIcon.run(moveRight)
        retryIcon.run(newMoveRight, completion: ({
            self.retryIcon.position = self.retryIcon.userData!["OP"] as! CGPoint
        }))
        
        score = 0
        scoreCounterLabel.text = "\(0)"
    }
    
    func gameOver(body: SKPhysicsBody)
    {
        for ball in dots
        {
            if ball.physicsBody == body && !isOnGameOver
            {
                isOnGameOver = true
                scrollSpeed = regScrollSpeed
                ball.removeAllActions()
                let shrinkAction = SKAction.scale(to: 0, duration: 0.1)
                let explosion = SKEmitterNode(fileNamed: "dotExplode.sks")!
                explosion.particleColorSequence = nil
                explosion.particleColor = ball.fillColor
                explosion.position = ball.position
                for dot in dots
                {
                    dot.run(shrinkAction, completion: ({
                        dot.removeFromParent()
                    }))
                }
                dots.removeAll()
                self.addChild(explosion)
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: ({_ in
                    explosion.removeFromParent()
                }))
                
                let whiteFlash = SKShapeNode(rect: self.frame)
                whiteFlash.fillColor = UIColor.white
                whiteFlash.strokeColor = UIColor.clear
                whiteFlash.zPosition = 10
                let fadeWhiteFlash = SKAction.fadeAlpha(to: 0, duration: 1)
                self.addChild(whiteFlash)
                whiteFlash.run(fadeWhiteFlash, completion: ({
                    whiteFlash.removeFromParent()
                }))
                shake(times: 50)
                
                gameOverMenuIcons()
            }
            break
        }
    }
    
    func gameOverMenuIcons()
    {
        for button in buttons
        {
            button.isHidden = false
        }
        rankIcon.position = CGPoint(x: homeIcon.position.x + 150, y: 0)
        homeIcon.run(moveRight)
        rankIcon.run(moveRight)
        rateIcon.position = noAdsIcon.position
        rateIcon.run(moveLeft)
        noAdsIcon.position = infoIcon.position
        noAdsIcon.run(moveLeft)
        retryIcon.run(moveRight)
        shareIcon.run(moveLeft)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        scoreCounterLabel.run(fadeOut)
        
        let userDefaults = Foundation.UserDefaults.standard
        let value  = userDefaults.integer(forKey: "SSHighScore")
        var highScore = score
        if value < score
        {
            scoreTitleLabel.text = "NEW BEST SCORE"
            userDefaults.set(highScore, forKey: "SSHighScore")
        }
        else
        {
            scoreTitleLabel.text = "YOU SCORED"
            highScore = value
        }
        saveHighscore()
        highScoreLabel.text = "\(highScore)"
        scoreTitleLabel.run(moveDown)
        scoreLabel.text = "\(score)"
        scoreLabel.run(moveDown)
        highScoreTitleLabel.run(moveDown)
        highScoreLabel.run(moveDown)
    }
    
    func shake(times: Int)
    {
        let dummyNode = SKNode()
        dummyNode.removeFromParent()
        for child in self.children
        {
            child.removeFromParent()
            dummyNode.addChild(child)
        }
        self.addChild(dummyNode)
        let initialPoint:CGPoint = dummyNode.position
        let amplitudeX:Int = 32
        let amplitudeY:Int = 20
        var randomActions:[SKAction] = []
        for _ in 0..<times
        {
            let randX = Int(self.position.x) + Int(arc4random()) % amplitudeX - amplitudeX/2
            let randY = Int(self.position.y) + Int(arc4random()) % amplitudeY - amplitudeY/2
            let action = SKAction.move(to: CGPoint.init(x: CGFloat(randX), y: CGFloat(randY)), duration: 0.01)
            randomActions.append(action)
        }
        let randomSequence:SKAction = SKAction.sequence(randomActions)
        dummyNode.run(randomSequence, completion: ({
            dummyNode.position = initialPoint
            for child in dummyNode.children
            {
                child.removeFromParent()
                self.addChild(child)
            }
            dummyNode.removeFromParent()
        }))
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
        dot.userData = ["Score":1]
        dot.strokeColor = UIColor.clear
        dot.position = CGPoint(x: randomAbs, y: self.frame.height/2 + dot.frame.height/2)
        dot.physicsBody = SKPhysicsBody(circleOfRadius: 75/2)
        dot.physicsBody?.affectedByGravity = false
        dot.physicsBody?.categoryBitMask = PhysicsCategory.ball
        dot.physicsBody?.collisionBitMask = PhysicsCategory.edge
        dot.physicsBody?.contactTestBitMask = PhysicsCategory.bar
        dot.physicsBody?.velocity = CGVector(dx: 800, dy: ballSpeed)
        dot.physicsBody?.restitution = 1
//        let moveDown = SKAction.moveTo(y: -1 * (self.frame.height/2 + dot.frame.height/2), duration: 3)
//        dot.run(moveDown)
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
        let shrink = SKAction.scale(to: 0.85, duration: 0.75)
        let expand = SKAction.scale(to: 1, duration: 0.75)
        let cookieMonsterForever = SKAction.repeatForever(SKAction.sequence([shrink,expand]))
        playLabel.userData = ["UA":cookieMonsterForever]
        playLabel.run(cookieMonsterForever)
        
        
        noAdsIcon = self.childNode(withName: "noAdsIcon") as! SKSpriteNode
        noAdsIcon.position = CGPoint(x: 25 + 50, y: 0)
        updateNoAds()
        
        infoIcon = self.childNode(withName: "infoIcon") as! SKSpriteNode
        infoIcon.position = CGPoint(x: noAdsIcon.position.x + 150, y: 0)
        
        rateIcon = self.childNode(withName: "rateIcon") as! SKSpriteNode
        rateIcon.position = CGPoint(x: noAdsIcon.position.x - 150, y: 0)
        
        rankIcon = self.childNode(withName: "rankIcon") as! SKSpriteNode
        rankIcon.position = CGPoint(x: rateIcon.position.x - 150, y: 0)
        
        homeIcon = self.childNode(withName: "homeIcon") as! SKSpriteNode
        homeIcon.position = CGPoint(x: rankIcon.position.x - self.frame.width/2, y: 0)
        homeIcon.isHidden = true
        
        shareIcon = self.childNode(withName: "shareIcon") as! SKSpriteNode
        shareIcon.position = CGPoint(x: 75 + self.frame.width/2, y: -150)
        
        retryIcon = self.childNode(withName: "retryIcon") as! SKSpriteNode
        retryIcon.position = CGPoint(x: -75 - self.frame.width/2, y: shareIcon.position.y)
        retryIcon.userData = ["OP":retryIcon.position]
        
        buttons = [noAdsIcon, infoIcon, rateIcon, rankIcon, homeIcon, shareIcon, retryIcon]
        
        for button in buttons
        {
            button.color = SKColor.black
        }
        
        scoreCounterLabel = self.childNode(withName: "scoreCounterLabel") as! SKLabelNode
        scoreCounterLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 50)
        scoreCounterLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        scoreCounterLabel.zPosition = 5
        scoreCounterLabel.alpha = 0
        
        scoreTitleLabel = self.childNode(withName: "scoreTitleLabel") as! SKLabelNode
        scoreTitleLabel.position = CGPoint(x: 0, y: (self.frame.height*(3/8)) + self.frame.height/2)
        scoreTitleLabel.userData = ["OP":scoreTitleLabel.position]
        scoreTitleLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.position = CGPoint(x: 0, y: scoreTitleLabel.position.y - scoreTitleLabel.frame.height/2 - 75)
        scoreLabel.userData = ["OP":scoreLabel.position]
        scoreLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        
        highScoreTitleLabel = self.childNode(withName: "highScoreTitleLabel") as! SKLabelNode
        highScoreTitleLabel.position = CGPoint(x: 0, y: scoreLabel.position.y - scoreLabel.frame.height/2 - 75)
        highScoreTitleLabel.userData = ["OP":highScoreTitleLabel.position]
        highScoreTitleLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        highScoreLabel.position = CGPoint(x: 0, y: highScoreTitleLabel.position.y - highScoreTitleLabel.frame.height/2 - 75)
        highScoreLabel.userData = ["OP":highScoreLabel.position]
        highScoreLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        
        platiplurLabel = self.childNode(withName: "platiplurLabel") as! SKLabelNode
        platiplurLabel.zPosition = 3
        platiplurLabel.position = CGPoint(x: self.frame.width * -1, y: self.frame.height*(1/8))
        
        producedLabel = self.childNode(withName: "producedLabel") as! SKLabelNode
        producedLabel.position = CGPoint(x: self.frame.width * -1, y: platiplurLabel.position.y + 75)
        producedLabel.zPosition = 3
        
        codedLabel = self.childNode(withName: "codedLabel") as! SKLabelNode
        codedLabel.position = CGPoint(x: self.frame.width, y: 75/2 + codedLabel.frame.height/2)
        codedLabel.zPosition = 3
        
        zukLabel = self.childNode(withName: "zukLabel") as! SKLabelNode
        zukLabel.position = CGPoint(x: self.frame.width, y: codedLabel.position.y - 75)
        zukLabel.zPosition = 3
        
        musicLabel = self.childNode(withName: "musicLabel") as! SKLabelNode
        musicLabel.position = CGPoint(x: self.frame.width * -1, y: self.frame.height * (-1/8))
        musicLabel.zPosition = 3
        
        hessLabel = self.childNode(withName: "hessLabel") as! SKLabelNode
        hessLabel.position = CGPoint(x: self.frame.width * -1, y: musicLabel.position.y - 75)
        hessLabel.zPosition = 3
        
        restorePurchasesLabel = self.childNode(withName: "restorePurchasesLabel") as! SKLabelNode
        restorePurchasesLabel.position = CGPoint(x: self.frame.width, y: self.frame.height/8 * -1 * 3)
        restorePurchasesLabel.zPosition = 3
        
        infoBackdrop = SKShapeNode.init(rect: self.frame)
        infoBackdrop.fillColor = SKColor.black
        infoBackdrop.strokeColor = SKColor.clear
        infoBackdrop.alpha = 0
        infoBackdrop.zPosition = 2
        infoBackdrop.position = CGPoint.zero
        self.addChild(infoBackdrop)
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
    
    //MARK: GAMECENTER METHODS
    
    func authPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {
            (view, error) in
            
            if view != nil
            {
                self.view?.window?.rootViewController?.present(view!, animated: true, completion: nil)
            }
            else
            {
                print(GKLocalPlayer.localPlayer().isAuthenticated)
            }
        }
    }
    
    func saveHighscore(){
        
        if GKLocalPlayer.localPlayer().isAuthenticated
        {
            let scoreReporter = GKScore(leaderboardIdentifier: "SlideSortScoreLeaderboard")
            let userDefaults = Foundation.UserDefaults.standard
            let value  = userDefaults.integer(forKey: "SSHighScore")
            scoreReporter.value = Int64(value)
            let scoreArray : [GKScore] = [scoreReporter]
            GKScore.report(scoreArray, withCompletionHandler: nil)
        }
    }
    
    func showLeaderBoard(){
        let viewController = self.view?.window?.rootViewController
        let gcvc = GKGameCenterViewController()
        
        gcvc.gameCenterDelegate = self
        
        viewController?.present(gcvc, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
        rankIcon.colorBlendFactor = 0
        NetworkActivityIndicatorManager.networkOperationFinished()
    }
}
