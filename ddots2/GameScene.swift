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
import AVFoundation
import DeviceKit
import Firebase

var noAdsIcon:SKSpriteNode!

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate
{
    var sliders:[SKShapeNode]! = []
    var scrollSpeed:CGFloat = 2
    let gameScrollSpeed:CGFloat = 14
    let regScrollSpeed:CGFloat = 2
    let ballSpeed:CGFloat = 1409 / -3
    let adFrequency:UInt32 = 6
    
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
    var isOnTutorial:Bool = false
    
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
    var newBestScoreLabel:SKLabelNode!
    
    var producedLabel:SKLabelNode!
    var platiplurLabel:SKLabelNode!
    var codedLabel:SKLabelNode!
    var zukLabel:SKLabelNode!
    var musicLabel:SKLabelNode!
    var hessLabel:SKLabelNode!
    var infoBackdrop:SKShapeNode!
    var restorePurchasesLabel:SKLabelNode!
    
    var musicAudioPlayer:AVAudioPlayer!
    var effectAudioPlayer:AVAudioPlayer!
    var gameFeedbackAudioPlayer:AVAudioPlayer!
    
    var cAIS:Int?
    var shouldBeOnTutorial:Bool = false
    var lastTouchWasRight:String?
    
    var howLabel:SKLabelNode!
    var unoTutLabel:SKLabelNode!
    var dosTutLabel:SKLabelNode!
    var tresTutLabel:SKLabelNode!
    var leftTouch:SKSpriteNode!
    var rightTouch:SKSpriteNode!
    
    //MARK: END OF VARIABLES
    
    override func didMove(to view: SKView)
    {
        authPlayer()
        self.scene?.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 239/255, alpha: 1)
        self.physicsWorld.contactDelegate = self
        
        musicAudioPlayer = AVAudioPlayer()
        effectAudioPlayer = AVAudioPlayer()
        gameFeedbackAudioPlayer = AVAudioPlayer()
        
        setupBounds()
        setupAudio()
        
        colors = [yellowColor,redColor,blueColor,greenColor,yellowColor,redColor]
        
        moveRight = SKAction.moveBy(x: self.frame.width/2, y: 0, duration: 0.25)
        moveLeft = SKAction.moveBy(x: self.frame.width/2 * -1, y: 0, duration: 0.25)
        moveUp = SKAction.moveBy(x: 0, y: self.frame.height/2, duration: 0.25)
        moveDown = SKAction.moveBy(x: 0, y: self.frame.height/2 * -1, duration: 0.25)
        
        setupMenuLabels()
        
        let userDefaults = Foundation.UserDefaults.standard
        if userDefaults.bool(forKey: "hasPlayedGame") == false
        {
            shouldBeOnTutorial = true
            userDefaults.set(true, forKey: "hasPlayedGame")
        }
        
        for i in 0...5
        {
            let slider = initiateSliders(number: i)
            self.addChild(slider)
            sliders.append(slider)
        }
//        let device = Device()
//        print(device)
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isOnMenu || isOnGameOver
        {
            slideSliders()
        }
        else
        {
//            if isTouchingScreen && !isOnGameOver
            if !isOnGameOver
            {
                if cAIS == nil && dots.count > 0 && isOnTutorial
                {
                    for (index,slider) in sliders.enumerated()
                    {
                        if slider.frame.maxX > frame.minX && slider.position.x < frame.maxX && slider.name == dots[0].name
                        {
                            cAIS = index
                        }
                    }
                }
                else if isOnTutorial && dots.count > 0 && cAIS != nil
                {
                    if dots[0].frame.minY <= sliders[0].frame.maxY || (dots[0].frame.minX > sliders[cAIS!].frame.minX+50 && dots[0].frame.maxX < sliders[cAIS!].frame.maxX-50)
                    {
                        scrollSpeed = 0
                        if lastTouchWasRight != nil && lastTouchWasRight == "none"
                        {
                            rightTouch.texture = SKTexture(imageNamed: "touch")
                            leftTouch.texture = SKTexture(imageNamed: "touch")
                        }
                        lastTouchWasRight = "none"
                    }
                    else if dots[0].frame.midX > sliders[cAIS!].frame.midX
                    {
                        scrollSpeed = gameScrollSpeed
                        if lastTouchWasRight != nil && lastTouchWasRight == "right"
                        {
                            rightTouch.texture = SKTexture(imageNamed: "touchFilled")
                            leftTouch.texture = SKTexture(imageNamed: "touch")
                        }
                        lastTouchWasRight = "right"
                    }
                    else if dots[0].frame.midX < sliders[cAIS!].frame.midX
                    {
                        scrollSpeed = gameScrollSpeed * -1
                        if lastTouchWasRight != nil && lastTouchWasRight == "left"
                        {
                            leftTouch.texture = SKTexture(imageNamed: "touchFilled")
                            rightTouch.texture = SKTexture(imageNamed: "touch")
                        }
                        lastTouchWasRight = "left"
                    }
                }
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
                    if dot.frame.maxY < sliders[0].frame.minY && dot.userData!["Score"] as! Int == 1
                    {
                        self.score = self.score + (dot.userData!["Score"] as! Int)
                        dot.userData?.setValue(0, forKey: "Score")
                        self.playFeedbackAudio(isPointScored: true)
                        self.checkHS()
                    }
                }
            }
            
            if dots.count < 1 && !isOnGameOver
            {
                if isOnTutorial
                {
                    cAIS = nil
                }
                spawnDots()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            if (isOnMenu || isOnGameOver || isOnTutorial) && isOnInfoScreen == false
            {
                var isButton = false
                for button in buttons
                {
                    if button.contains(location)
                    {
                        let userDefaults = Foundation.UserDefaults.standard
                        playButtonAudio()
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
                            FIRAnalytics.logEvent(withName: "gameCenterUsed", parameters: nil)
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
                            FIRAnalytics.logEvent(withName: "ratedApp", parameters: nil)
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
                            FIRAnalytics.logEvent(withName: "sharedScore", parameters: nil)
                        }
                    }
                }
                if !isButton && isOnMenu && !isOnTutorial
                {
                    playButtonAudio()
                    let disappear = SKAction.fadeAlpha(to: 0, duration: 0.25)
                    noAdsIcon.run(moveRight, completion: ({
                        noAdsIcon.isHidden = true
                        noAdsIcon.removeFromParent()
                    }))
                    infoIcon.run(moveRight, completion: ({
                        self.infoIcon.isHidden = true
                        self.infoIcon.removeFromParent()
                    }))
                    rateIcon.run(moveLeft, completion: ({
                        self.rateIcon.isHidden = true
                        self.rateIcon.removeFromParent()
                    }))
                    rankIcon.run(moveLeft, completion: ({
                        self.rankIcon.isHidden = true
                        self.rankIcon.removeFromParent()
                    }))
                    titleLabel.run(moveUp, completion: ({
                        self.titleLabel.isHidden = true
                        self.titleLabel.removeFromParent()
                    }))
                    if !shouldBeOnTutorial
                    {
                        playLabel.removeAllActions()
                        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
                        self.addChild(scoreCounterLabel)
                        scoreCounterLabel.run(fadeIn)
                        scrollSpeed = gameScrollSpeed
                    }
                    else
                    {
                        isOnTutorial = true
                        presentTutorial()
                    }
                    playLabel.run(disappear, completion: ({
                        self.playLabel.isHidden = true
                        if self.shouldBeOnTutorial
                        {
                            self.playLabel.position.y -= 200
                            self.playLabel.isHidden = false
                            let reappear = SKAction.fadeAlpha(to: 1, duration: 0.25)
                            self.playLabel.run(reappear)
                        }
                        else
                        {
                            self.playLabel.removeFromParent()
                        }
                    }))
                    isOnMenu = false
                }
                if isOnTutorial && shouldBeOnTutorial == false
                {
                    dismissTutorial()
                }
            }
            else if isOnInfoScreen
            {
                if platiplurLabel.contains(location)
                {
                    playButtonAudio()
                    platiplurLabel.colorBlendFactor = 0.5
                    platiplurLabel.color = UIColor.black
                    let url = NSURL(string: "https://platiplur.com")
                    UIApplication.shared.open(url as! URL, options: [:], completionHandler: { (success) in
                        self.platiplurLabel.colorBlendFactor = 0
                    })
                    FIRAnalytics.logEvent(withName: "visitedPlatiplurWebsite", parameters: nil)
                }
                else if restorePurchasesLabel.contains(location)
                {
                    playButtonAudio()
                    restorePurchasesLabel.colorBlendFactor = 0.5
                    restorePurchasesLabel.color = UIColor.black
                    (self.view?.window?.rootViewController as! GameViewController).restorePurchases(label: restorePurchasesLabel)
                }
                else
                {
                    playButtonAudio()
                    dismissInfo()
                }
            }
            else
            {
                isTouchingScreen = true
                if location.x > self.frame.midX && !isOnTutorial
                {
                    scrollSpeed = gameScrollSpeed
                }
                else if !isOnTutorial
                {
                    scrollSpeed = gameScrollSpeed * -1
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let location = touch.location(in: self)
            if !isOnMenu && !isOnGameOver
            {
                if location.x > self.frame.midX
                {
                    scrollSpeed = gameScrollSpeed
                }
                else
                {
                    scrollSpeed = gameScrollSpeed * -1
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isOnMenu || isOnGameOver
        {
            for button in buttons
            {
                if button != noAdsIcon
                {
                    button.colorBlendFactor = 0
                }
            }
        }
        else if !isOnTutorial
        {
            isTouchingScreen = false
            scrollSpeed = 0
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if contact.bodyA.node?.name == contact.bodyB.node?.name
        {
//            if contact.bodyA.node?.userData?["Score"] as? Int == 1
//            {
//                print((contact.bodyA.node?.frame.maxY)!)
//                _ = Timer(timeInterval: TimeInterval((contact.bodyB.node?.frame.height)!/(contact.bodyA.node?.physicsBody?.velocity.dy)!), repeats: false, block: ({
//                    timer in
//                    self.score = self.score + (contact.bodyA.node?.userData!["Score"] as! Int)
//                    contact.bodyA.node?.userData?.setValue(0, forKey: "Score")
//                    //                contact.bodyA.node?.physicsBody?.velocity.dx = 0
//                    self.playFeedbackAudio(isPointScored: true)
//                    self.checkHS()
//                }))
//            }
//            else if contact.bodyB.node?.userData?["Score"] as? Int == 1
//            {
//                print((contact.bodyB.node?.frame.maxY)!)
//                _ = Timer(timeInterval: TimeInterval((contact.bodyA.node?.frame.height)!/(contact.bodyB.node?.physicsBody?.velocity.dy)!), repeats: false, block: ({
//                    timer in
//                    self.score = self.score + (contact.bodyB.node?.userData!["Score"] as! Int)
//                    contact.bodyB.node?.userData?.setValue(0, forKey: "Score")
//                    //                contact.bodyA.node?.physicsBody?.velocity.dx = 0
//                    self.playFeedbackAudio(isPointScored: true)
//                    self.checkHS()
//                }))
//            }
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            {
//                score = score + (contact.bodyA.node?.userData!["Score"] as! Int)
//                contact.bodyA.node?.userData?.setValue(0, forKey: "Score")
                contact.bodyA.node?.physicsBody?.velocity.dx = 0
            }
            else
            {
//                score = score + (contact.bodyB.node?.userData!["Score"] as! Int)
//                contact.bodyB.node?.userData?.setValue(0, forKey: "Score")
                contact.bodyB.node?.physicsBody?.velocity.dx = 0
            }
        }
        else
        {
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask && !isOnGameOver && !isOnTutorial
            {
                gameOver(body: contact.bodyA)
            }
            else if !isOnTutorial
            {
                gameOver(body: contact.bodyB)
            }
            playFeedbackAudio(isPointScored: false)
        }
    }
    
    //MARK: CUSTOM METHODS
    
    func presentTutorial()
    {
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let labels = [howLabel, unoTutLabel, dosTutLabel, tresTutLabel]
        for labelE in labels
        {
            self.addChild(labelE!)
            labelE?.run(fadeIn)
        }
        self.addChild(rightTouch)
        self.addChild(leftTouch)
        rightTouch.run(fadeIn, completion: ({
            self.shouldBeOnTutorial = false
        }))
        leftTouch.run(fadeIn)
    }
    
    func dismissTutorial()
    {
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.25)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.25)
        let labels = [howLabel, unoTutLabel, dosTutLabel, tresTutLabel]
        for labelE in labels
        {
            labelE?.run(fadeOut, completion: ({
                labelE?.removeFromParent()
            }))
        }
        let touches = [rightTouch, leftTouch]
        for touch in touches
        {
            touch?.run(fadeOut, completion: ({
                touch?.removeFromParent()
            }))
        }
        playLabel.removeAllActions()
        playLabel.run(fadeOut, completion: ({
            self.playLabel.isHidden = true
            self.playLabel.position.y += 200
            self.playLabel.removeFromParent()
        }))
        self.addChild(scoreCounterLabel)
        scoreCounterLabel.run(fadeIn)
        isOnTutorial = false
        for dot in dots
        {
            let shrink = SKAction.scale(to: 0, duration: 0.1)
            dot.run(shrink, completion: ({
                dot.removeFromParent()
                self.dots = []
            }))
        }
        score = 0
        scoreCounterLabel.text = "0"
    }
    
    func checkHS()
    {
        if !isOnTutorial
        {
            scoreCounterLabel.text = "\(score)"
            let userDefaults = Foundation.UserDefaults.standard
            let value  = userDefaults.integer(forKey: "SSHighScore")
            if score == value + 1
            {
                self.newBestScoreLabel.removeAllActions()
                self.addChild(newBestScoreLabel)
                let fadIn = SKAction.fadeIn(withDuration: 0.25)
                let wait = SKAction.wait(forDuration: 1.25)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.25)
                newBestScoreLabel.run(fadIn, completion: ({
                    self.newBestScoreLabel.run(wait, completion: ({
                        self.newBestScoreLabel.run(fadeOut, completion: ({
                            self.newBestScoreLabel.removeFromParent()
                        }))
                    }))
                }))
            }
        }
    }
    
    func setupAudio()
    {
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            musicAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Daniel's song", ofType: "m4a")!))
            musicAudioPlayer.numberOfLoops = -1
            musicAudioPlayer.prepareToPlay()
            musicAudioPlayer.play()
        }
        catch
        {
            print(error)
        }
    }
    
    func playFeedbackAudio(isPointScored: Bool)
    {
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            var audioArray = "playerDied"
            if isPointScored
            {
                audioArray = "pointScored"
            }
            gameFeedbackAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: audioArray, ofType: "mp3")!))
            if gameFeedbackAudioPlayer.isPlaying
            {
                gameFeedbackAudioPlayer.stop()
            }
            gameFeedbackAudioPlayer.prepareToPlay()
            gameFeedbackAudioPlayer.play()
        }
        catch
        {
            print(error)
        }
    }
    
    func playButtonAudio()
    {
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            effectAudioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "ClickSound", ofType: "m4a")!))
            effectAudioPlayer.prepareToPlay()
            effectAudioPlayer.play()
        }
        catch
        {
            print(error)
        }
    }
    
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
        let right = [codedLabel, zukLabel, restorePurchasesLabel]
        for righer in right
        {
            righer?.run(newMoveRight, completion: ({
                righer?.removeFromParent()
            }))
        }
        let left = [musicLabel, hessLabel, producedLabel, platiplurLabel]
        for lefter in left
        {
            lefter?.run(newMoveLeft, completion: ({
                lefter?.removeFromParent()
            }))
        }
        infoBackdrop.run(newfadeOut, completion: ({
            self.isOnInfoScreen = false
            self.infoBackdrop.removeFromParent()
        }))
    }
    
    func infoCredits()
    {
        isOnInfoScreen = true
        
        let newMoveRight = SKAction.moveBy(x: self.frame.width, y: 0, duration: 0.25)
        let newMoveLeft = SKAction.moveBy(x: self.frame.width * -1, y: 0, duration: 0.25)
        let newFadeIn = SKAction.fadeAlpha(to: 0.9, duration: 0.25)
        let nodes:[SKNode] = [infoBackdrop, codedLabel, zukLabel, musicLabel, hessLabel, producedLabel, platiplurLabel, restorePurchasesLabel]
        for node in nodes
        {
            self.addChild(node)
        }
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
        (self.view?.window?.rootViewController as! GameViewController).updateNoAds()
//        (self.view?.window?.rootViewController as! GameViewController).bannerView.isHidden = false
        return screenShot!
    }
    
    func share()
    {
        let screenShot = getScreenshot(scene: self.scene!)
        let shareText = "OMG! I just got \(score) points in #SlideSort\nhttp://itunes.apple.com/app/id1191366864"
        let shareArray:[Any] = [screenShot,shareText]
        
        let activityVC = UIActivityViewController(activityItems: shareArray, applicationActivities: nil)
        let device = Device()
        if device.isPad && activityVC.responds(to: #selector(getter: UIViewController.popoverPresentationController))
        {
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.frame.size.width/2 + self.shareIcon.position.x, y: self.frame.size.height/2, width: 0, height: 0)
        }
        if device == .iPadPro12Inch || device == Device.simulator(.iPadPro12Inch)
        {
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.frame.size.width/2 + self.shareIcon.frame.width*2 + self.shareIcon.position.x/2, y: self.frame.size.height/2 - self.shareIcon.position.y, width: 0, height: 0)
        }
        
        (self.view?.window?.rootViewController as! GameViewController).present(activityVC, animated: true, completion: ({
            self.shareIcon.colorBlendFactor = 0
        }))
//        (self.view?.window?.rootViewController as! GameViewController).updateNoAds()
    }
    
    func retry()
    {
        homeIcon.run(moveLeft, completion: ({
            self.homeIcon.removeFromParent()
        }))
        rankIcon.run(moveLeft, completion: ({
            self.rankIcon.position.x -= 150
            self.rankIcon.removeFromParent()
        }))
        rateIcon.run(moveRight, completion: ({
            self.rateIcon.position.x = self.rankIcon.position.x + 150
            self.rateIcon.removeFromParent()
        }))
        noAdsIcon.run(moveRight, completion: ({
            noAdsIcon.position.x -= 150
            noAdsIcon.removeFromParent()
            self.retryIcon.colorBlendFactor = 0
        }))
        let upMov = [scoreTitleLabel, scoreLabel, highScoreTitleLabel, highScoreLabel]
        for label in upMov
        {
            label?.run(moveUp, completion: ({
                label?.removeFromParent()
            }))
        }
        retryIcon.run(moveLeft, completion: ({
            self.retryIcon.removeFromParent()
        }))
        shareIcon.run(moveRight, completion: ({
            self.shareIcon.removeFromParent()
        }))
        score = 0
        self.addChild(scoreCounterLabel)
        scoreCounterLabel.text = "\(0)"
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        scoreCounterLabel.run(fadeIn)
        scrollSpeed = gameScrollSpeed
        isOnGameOver = false
    }
    
    func startHomeOwnersAssociation()
    {
        self.addChild(infoIcon)
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
            if conservative == homeIcon
            {
                conservative.run(newMoveRight, completion: ({
                    conservative.removeFromParent()
                }))
            }
            else
            {
                conservative.run(newMoveRight)
            }
        }
        for neoNazi in altRightWingers
        {
            neoNazi.run(newMoveRight, completion: ({
                neoNazi.position = neoNazi.userData!["OP"] as! CGPoint
                neoNazi.removeFromParent()
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
        
        self.addChild(titleLabel)
        self.addChild(playLabel)
        titleLabel.position = CGPoint(x: -1 * self.frame.width, y: self.frame.height/4)
        titleLabel.isHidden = false
        playLabel.position = CGPoint(x: -1 * self.frame.width, y: titleLabel.position.y - titleLabel.frame.height/2 - 75)
        playLabel.alpha = 1
        playLabel.isHidden = false
        titleLabel.run(newMoveRight)
        playLabel.run(newMoveRight)
        playLabel.run(playLabel.userData!["UA"] as! SKAction)
        
        shareIcon.run(moveRight, completion: ({
            self.shareIcon.removeFromParent()
        }))
        retryIcon.run(newMoveRight, completion: ({
            self.retryIcon.position = self.retryIcon.userData!["OP"] as! CGPoint
            self.retryIcon.removeFromParent()
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
                let device = Device()
                if device != .iPhone5 && device != .iPhone5c && device != .simulator(.iPhone5)
                {
                    shake(times: 50)
                }
                
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
            if button != infoIcon
            {
                self.addChild(button)
            }
        }
        print(shareIcon.position)
        rankIcon.position = CGPoint(x: homeIcon.position.x + 150, y: 0)
        homeIcon.run(moveRight, completion: ({
            let randNum = arc4random_uniform(self.adFrequency)
            if randNum == 0
            {
                (self.view?.window?.rootViewController as! GameViewController).presentFullScreenAd()
            }
        }))
        rankIcon.run(moveRight)
        rateIcon.position = noAdsIcon.position
        rateIcon.run(moveLeft)
        noAdsIcon.position = infoIcon.position
        noAdsIcon.run(moveLeft)
        retryIcon.run(moveRight)
        shareIcon.run(moveLeft)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        scoreCounterLabel.run(fadeOut, completion: ({
            self.scoreCounterLabel.removeFromParent()
        }))
        
        FIRAnalytics.logEvent(withName: kFIREventPostScore, parameters: [kFIRParameterLevel: "Slide Sort" as NSObject, kFIRParameterCharacter: "Slide Sort" as NSObject, kFIRParameterScore: "\(score)" as NSObject])
        
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
        
        let labels = [highScoreLabel, highScoreTitleLabel, scoreLabel, scoreTitleLabel]
        for label in labels
        {
            self.addChild(label!)
        }
        
        highScoreLabel.text = "\(highScore)"
        scoreTitleLabel.run(moveDown)
        scoreLabel.text = "\(score)"
        scoreLabel.run(moveDown)
        highScoreTitleLabel.run(moveDown)
        highScoreLabel.run(moveDown)
        
        newBestScoreLabel.removeAllActions()
        newBestScoreLabel.run(SKAction.fadeAlpha(to: 0, duration: 0.25), completion: ({
            self.newBestScoreLabel.removeFromParent()
        }))
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
        let randomDir = arc4random_uniform(2)
        var dx:CGFloat = 800
        if randomDir == 0
        {
            dx = -800
        }
        dot.physicsBody?.velocity = CGVector(dx: dx, dy: ballSpeed)
        dot.physicsBody?.restitution = 1
//        let moveDown = SKAction.moveTo(y: -1 * (self.frame.height/2 + dot.frame.height/2), duration: 3)
//        dot.run(moveDown)
        dots.append(dot)
        self.addChild(dot)
    }
    
    func setupMenuLabels()
    {
        let device = Device()
        
        titleLabel = self.childNode(withName: "titleLabel") as! SKLabelNode
        titleLabel.position = CGPoint(x: 0, y: self.frame.height/4)
        titleLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        titleLabel.verticalAlignmentMode = .center
        
        newBestScoreLabel = self.childNode(withName: "newBestScoreLabel") as! SKLabelNode
        newBestScoreLabel.position = titleLabel.position
        newBestScoreLabel.fontColor = titleLabel.fontColor
        newBestScoreLabel.verticalAlignmentMode = .center
        newBestScoreLabel.alpha = 0
        newBestScoreLabel.removeFromParent()
        
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
        homeIcon.removeFromParent()
        
        shareIcon = self.childNode(withName: "shareIcon") as! SKSpriteNode
        shareIcon.position = CGPoint(x: 75 + self.frame.width/2, y: -150)
        shareIcon.removeFromParent()
        
        retryIcon = self.childNode(withName: "retryIcon") as! SKSpriteNode
        retryIcon.position = CGPoint(x: -75 - self.frame.width/2, y: shareIcon.position.y)
        retryIcon.userData = ["OP":retryIcon.position]
        retryIcon.removeFromParent()
        
        buttons = [noAdsIcon, infoIcon, rateIcon, rankIcon, homeIcon, shareIcon, retryIcon]
        if device.isPad
        {
            for button in buttons
            {
                button.scale(to: CGSize(width: 75, height: 75))
            }
        }
        
        for button in buttons
        {
            button.color = SKColor.black
        }
        
        scoreCounterLabel = self.childNode(withName: "scoreCounterLabel") as! SKLabelNode
        scoreCounterLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 50)
        if device.isPad
        {
            scoreCounterLabel.position = CGPoint(x: self.frame.maxX - 50, y: self.frame.maxY - 200)
        }
        scoreCounterLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        scoreCounterLabel.zPosition = 5
        scoreCounterLabel.alpha = 0
        scoreCounterLabel.removeFromParent()
        
        scoreTitleLabel = self.childNode(withName: "scoreTitleLabel") as! SKLabelNode
        scoreTitleLabel.position = CGPoint(x: 0, y: (self.frame.height*(3/8)) + self.frame.height/2)
        scoreTitleLabel.userData = ["OP":scoreTitleLabel.position]
        scoreTitleLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        scoreTitleLabel.removeFromParent()
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.position = CGPoint(x: 0, y: scoreTitleLabel.position.y - scoreTitleLabel.frame.height/2 - 75)
        scoreLabel.userData = ["OP":scoreLabel.position]
        scoreLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        scoreLabel.removeFromParent()
        
        highScoreTitleLabel = self.childNode(withName: "highScoreTitleLabel") as! SKLabelNode
        highScoreTitleLabel.position = CGPoint(x: 0, y: scoreLabel.position.y - scoreLabel.frame.height/2 - 75)
        highScoreTitleLabel.userData = ["OP":highScoreTitleLabel.position]
        highScoreTitleLabel.fontColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1)
        highScoreTitleLabel.removeFromParent()
        
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        highScoreLabel.position = CGPoint(x: 0, y: highScoreTitleLabel.position.y - highScoreTitleLabel.frame.height/2 - 75)
        highScoreLabel.userData = ["OP":highScoreLabel.position]
        highScoreLabel.fontColor = UIColor(red: 108/255, green: 122/255, blue: 137/255, alpha: 1)
        highScoreLabel.removeFromParent()
        
        if device.isPad
        {
            let scoreLabels:[SKLabelNode] = [scoreTitleLabel, scoreLabel, highScoreTitleLabel, highScoreLabel]
            for scoreLabelo in scoreLabels
            {
                scoreLabelo.position.y -= 75
                scoreLabelo.userData!["OP"] = scoreLabelo.position
            }
        }
        
        platiplurLabel = self.childNode(withName: "platiplurLabel") as! SKLabelNode
        platiplurLabel.zPosition = 3
        platiplurLabel.position = CGPoint(x: self.frame.width * -1, y: self.frame.height*(1/8))
        platiplurLabel.removeFromParent()
        
        producedLabel = self.childNode(withName: "producedLabel") as! SKLabelNode
        producedLabel.position = CGPoint(x: self.frame.width * -1, y: platiplurLabel.position.y + 75)
        producedLabel.zPosition = 3
        producedLabel.removeFromParent()
        
        codedLabel = self.childNode(withName: "codedLabel") as! SKLabelNode
        codedLabel.position = CGPoint(x: self.frame.width, y: 75/2 + codedLabel.frame.height/2)
        codedLabel.zPosition = 3
        codedLabel.removeFromParent()
        
        zukLabel = self.childNode(withName: "zukLabel") as! SKLabelNode
        zukLabel.position = CGPoint(x: self.frame.width, y: codedLabel.position.y - 75)
        zukLabel.zPosition = 3
        zukLabel.removeFromParent()
        
        musicLabel = self.childNode(withName: "musicLabel") as! SKLabelNode
        musicLabel.position = CGPoint(x: self.frame.width * -1, y: self.frame.height * (-1/8))
        musicLabel.zPosition = 3
        musicLabel.removeFromParent()
        
        hessLabel = self.childNode(withName: "hessLabel") as! SKLabelNode
        hessLabel.position = CGPoint(x: self.frame.width * -1, y: musicLabel.position.y - 75)
        hessLabel.zPosition = 3
        hessLabel.removeFromParent()
        
        restorePurchasesLabel = self.childNode(withName: "restorePurchasesLabel") as! SKLabelNode
        restorePurchasesLabel.position = CGPoint(x: self.frame.width, y: self.frame.height/8 * -1 * 3)
        if device.isPad
        {
            restorePurchasesLabel.position = CGPoint(x: self.frame.width, y: self.frame.height/8 * -1 * 2.25)
        }
        restorePurchasesLabel.zPosition = 3
        restorePurchasesLabel.removeFromParent()
        
        infoBackdrop = SKShapeNode.init(rect: self.frame)
        infoBackdrop.fillColor = SKColor.black
        infoBackdrop.strokeColor = SKColor.clear
        infoBackdrop.alpha = 0
        infoBackdrop.zPosition = 2
        infoBackdrop.position = CGPoint.zero
        
        if device.isPad
        {
            let highScoreLabels:[SKLabelNode] = [highScoreTitleLabel, highScoreLabel, scoreTitleLabel, scoreLabel]
            for label in highScoreLabels
            {
                label.setScale(0.75)
                if label != highScoreLabel
                {
                    label.position.y -= 25
                    label.userData!["OP"]! = label.position
                }
            }
            highScoreTitleLabel.position.y += 12
            highScoreTitleLabel.userData!["OP"]! = highScoreTitleLabel.position
        }
        
        howLabel = self.childNode(withName: "howLabel") as! SKLabelNode
        howLabel.position = CGPoint(x: 0, y: self.frame.height*0.25)
        howLabel.alpha = 0
        howLabel.zPosition = 20
        howLabel.fontColor = titleLabel.fontColor
        howLabel.removeFromParent()
        
        unoTutLabel = self.childNode(withName: "unoTutLabel") as! SKLabelNode
        unoTutLabel.position = CGPoint(x: 0, y: howLabel.frame.minY - 25)
        unoTutLabel.alpha = 0
        unoTutLabel.zPosition = 20
        unoTutLabel.fontColor = titleLabel.fontColor
        unoTutLabel.removeFromParent()
        
        dosTutLabel = self.childNode(withName: "dosTutLabel") as! SKLabelNode
        dosTutLabel.position = CGPoint(x: 0, y: unoTutLabel.frame.minY - 25)
        dosTutLabel.alpha = 0
        dosTutLabel.zPosition = 20
        dosTutLabel.fontColor = titleLabel.fontColor
        dosTutLabel.removeFromParent()
        
        tresTutLabel = self.childNode(withName: "tresTutLabel") as! SKLabelNode
        tresTutLabel.position = CGPoint(x: 0, y: dosTutLabel.frame.minY - 25)
        tresTutLabel.alpha = 0
        tresTutLabel.zPosition = 20
        tresTutLabel.fontColor = titleLabel.fontColor
        tresTutLabel.removeFromParent()
        
        leftTouch = self.childNode(withName: "leftTouch") as! SKSpriteNode
        leftTouch.position = CGPoint(x: 0 - self.frame.width/4, y: 0 - self.frame.height/8)
        leftTouch.alpha = 0
        leftTouch.zPosition = 20
        leftTouch.color = titleLabel.fontColor!
        leftTouch.colorBlendFactor = 1
        leftTouch.removeFromParent()
        
        rightTouch = self.childNode(withName: "rightTouch") as! SKSpriteNode
        rightTouch.position = CGPoint(x: 0 + self.frame.width/4, y: 0 - self.frame.height/8)
        rightTouch.alpha = 0
        rightTouch.zPosition = 20
        rightTouch.color = titleLabel.fontColor!
        rightTouch.colorBlendFactor = 1
        rightTouch.removeFromParent()
    }
    
    func slideSliders()
    {
        if !(scrollSpeed == 0 && sliders[0].userData!["SS"]! as! CGFloat == 0)
        {
            for node in sliders
            {
    //            node.position.x += self.scrollSpeed
                if (node.userData!["SS"]! as! CGFloat) != scrollSpeed
                {
                    node.removeAllActions()
                }
                if node.hasActions() == false
                {
                    let action = SKAction.moveBy(x: self.scrollSpeed * 60, y: 0, duration: 1)
                    node.userData!["SS"]! = scrollSpeed
                    node.run(action)
                }
                
                var bigPos:CGFloat = 0
                var smallPos:CGFloat = 0
                for slider in sliders
                {
                    if slider.position.x > bigPos
                    {
                        bigPos = slider.position.x
                    }
                    if slider.position.x < smallPos
                    {
                        smallPos = slider.position.x
                    }
                }
                
                if node.position.x < self.frame.minX - node.frame.width && self.scrollSpeed != abs(self.scrollSpeed)
                {
                    self.colors.append(self.colors[2])
                    self.colors.removeFirst()
                    
                    node.position.x = bigPos + node.frame.width
                    node.fillColor = colors.last!
                    node.name = String(colors.last!.description)
                }
                else if node.position.x > self.frame.maxX && self.scrollSpeed == abs(self.scrollSpeed)
                {
                    self.colors.insert(self.colors[3], at: 0)
                    self.colors.removeLast()
                    
                    node.position.x = smallPos - node.frame.width
                    node.fillColor = colors.first!
                    node.name = String(colors.first!.description)
                }
            }
        }
    }
    
    func initiateSliders(number: Int) -> SKShapeNode
    {
        var rect = CGRect(x: 0, y: -1 * self.frame.height/4 - 25, width: self.frame.width/4, height: 50)
        let device = Device()
        if device.isPad
        {
            rect = CGRect(x: 0, y: -1 * self.frame.height/4, width: self.frame.width/4, height: 50)
        }
        let slider = SKShapeNode(rect: rect)
        slider.strokeColor = UIColor.clear
        slider.physicsBody = SKPhysicsBody(rectangleOf: CGSize.init(width: rect.width, height: rect.height), center: CGPoint(x: rect.midX, y: rect.midY))
        slider.physicsBody?.affectedByGravity = false
        slider.physicsBody?.categoryBitMask = PhysicsCategory.bar
        slider.physicsBody?.collisionBitMask = PhysicsCategory.none
        slider.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        
        slider.fillColor = colors[number]
        slider.name = String(colors[number].description)
        slider.position.x = self.frame.width * (CGFloat(2*number - 6)/8)
        slider.userData = ["SS": scrollSpeed]
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
