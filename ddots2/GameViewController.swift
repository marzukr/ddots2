//
//  GameViewController.swift
//  ddots2
//
//  Created by Marzuk Rashid on 12/29/16.
//  Copyright © 2016 Platiplur. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds
import SwiftyStoreKit
import StoreKit

var sharedSecret = "860b2d45c04347dc96c9c9a16bb00bca"
let isGeimerBetaVersion = true

enum RegisteredPurchase : String {
    case NoAds = "testAd"
    case autoRenewable = "Auto Renewable"
}

class GameViewController: UIViewController, GADBannerViewDelegate
{
    @IBOutlet var bannerView: GADBannerView!
    var bigAd:GADInterstitial!
    var testDevices:[Any]!
    
    let bundleID = "com.platiplur.ddots2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            for product in products {
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                    print("purchased: \(product)")
                }
            }
        }
        
        testDevices = [kGADSimulatorID, "c004ebe3cfdc597aa62f15cf45117e8a", "de9a8891b5b6ab4f3c3ee561bbcc8e08"]
        
        let request = GADRequest()
        request.testDevices = testDevices
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-2589543338977180/4128839558"
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.rootViewController = self
        bannerView.load(request)
        
        bigAd = createAd()
//        bigAd.delegate = self
        
        updateNoAds()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func presentFullScreenAd()
    {
        let userDefaults = Foundation.UserDefaults.standard
        if bigAd.isReady && !isGeimerBetaVersion && userDefaults.bool(forKey: "didPurchaseNoAds") == false
        {
            bigAd.present(fromRootViewController: self)
            bigAd = self.createAd()
        }
    }
    
    func createAd() -> GADInterstitial
    {
        let ad = GADInterstitial(adUnitID: "ca-app-pub-2589543338977180/4488655951")
        let request = GADRequest()
        request.testDevices = testDevices
        ad.load(request)
        return ad
    }
    
    func updateNoAds()
    {
        let userDefaults = Foundation.UserDefaults.standard
        bannerView.isHidden = userDefaults.bool(forKey: "didPurchaseNoAds")
        if isGeimerBetaVersion
        {
            bannerView.isHidden = isGeimerBetaVersion
        }
    }
    
    func updateNoAdsLabel()
    {
        let userDefaults = Foundation.UserDefaults.standard
        if userDefaults.bool(forKey: "didPurchaseNoAds") == true
        {
            let texture = SKTexture(image: UIImage(named: "noAdsPurchasedIcon")!)
            noAdsIcon.texture = texture
        }
    }
    
    //MARK: IAD METHODS
    
    func getInfo(purchase: RegisteredPurchase)
    {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue], completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
        })
    }
    
    func purchase(purchase: RegisteredPurchase)
    {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            if case .success(let product) = result
            {
                if product.productId == self.bundleID + "." + RegisteredPurchase.NoAds.rawValue
                {
                    let userDefaults = Foundation.UserDefaults.standard
                    userDefaults.set(true, forKey: "didPurchaseNoAds")
                    self.updateNoAds()
                    self.updateNoAdsLabel()
                }
                
                if product.needsFinishTransaction
                {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                self.showAlert(alert: self.alertForPurchaseResult(result: result))
            }
            noAdsIcon.colorBlendFactor = 0
        })
    }
    
    func restorePurchases(label: SKLabelNode)
    {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for product in result.restoredProducts
            {
                if product.needsFinishTransaction
                {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            
            self.showAlert(alert: self.alertForRestorePurchases(result: result))
            label.colorBlendFactor = 0
        })
    }
    
    func verifyReceipt()
    {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            if case .error(let error) = result
            {
                if case .noReceiptData = error
                {
                    self.refreshReceipt()
                }
            }
        })
    }
    
    func verifyPurchase(product: RegisteredPurchase)
    {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.verifyReceipt(password: sharedSecret, completion: {
            result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                let productID = self.bundleID + "." + product.rawValue
                if product == .autoRenewable
                {
                    let purchaseResult = SwiftyStoreKit.verifySubscription(productId: productID, inReceipt: receipt, validUntil: Date())
                    self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
                }
                else
                {
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
                }
            case .error(let error):
                self.showAlert(alert: self.alertForVerifyReceipt(result: result))
                if case .noReceiptData = error
                {
                    self .refreshReceipt()
                }
            }
        })
    }
    
    func refreshReceipt()
    {
        SwiftyStoreKit.refreshReceipt(completion: {
            result in
            self.showAlert(alert: self.alertForRefreshReceipt(result: result))
        })
    }
}
