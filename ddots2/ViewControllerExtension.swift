//
//  ViewControllerExtension.swift
//  ddots2
//
//  Created by Marzuk Rashid on 1/3/17.
//  Copyright © 2017 Platiplur. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

extension GameViewController
{
    func alertWithTitle(title: String, message:String) -> UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    func showAlert(alert: UIAlertController)
    {
        guard let _ = self.presentedViewController else
        {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController
    {
        if let product = result.retrievedProducts.first
        {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        }
        else if let invalidProductID = result.invalidProductIDs.first
        {
            return alertWithTitle(title: "Could not retrieve product info", message: "Invalid product indentifier: \(invalidProductID)")
        }
        else
        {
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please contact support"
            return alertWithTitle(title: "Could not retrieve product info", message: errorString)
        }
    }
    func alertForPurchaseResult(result: PurchaseResult) -> UIAlertController
    {
        switch result {
        case .success(let product):
            print("Purchase Succesful: \(product.productId)")
            return alertWithTitle(title: "Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error {
            case .failed(let error):
                if (error as NSError).domain == SKErrorDomain
                {
                    return alertWithTitle(title: "Purchase Failed", message: "Check your internet connection or try again later.")
                }
                else
                {
                    return alertWithTitle(title: "Purcahse Failed", message: "Unknown Error. Please contact support")
                }
            case .invalidProductId(let productID):
                return alertWithTitle(title: "Purchase Failed", message: "\(productID) is not a valid product identifier.")
            case .noProductIdentifier:
                return alertWithTitle(title: "Purchase Failed", message: "Product not found")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase Failed", message: "You are not allowed to make payments")
            }
        }
    }
    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController
    {
        if result.restoreFailedProducts.count > 0
        {
            print("Restore Failed: \(result.restoreFailedProducts)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please contact support.")
        }
        else if result.restoredProducts.count > 0
        {
            return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored")
        }
        else
        {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made.")
        }
        
    }
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController
    {
        switch result {
        case.success(let receipt):
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verification", message: "No receipt data found, application will try to get a new one. Try Again.")
            default:
                return alertWithTitle(title: "Receipt Verification", message: "Receipt verification failed")
            }
        }
    }
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController
    {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product is valid until \(expiryDate)")
        case .notPurchased:
            return alertWithTitle(title: "Product not Purchased", message: "This product has never been purchased")
        case .expired(let expiryDate):
            return alertWithTitle(title: "Product Expired", message: "Product is expired since \(expiryDate)")
        }
    }
    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController
    {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is Purchased", message: "Product will not expire")
        case .notPurchased:
            return alertWithTitle(title: "Product not Purchased", message: "Product has never been purchased")
        }
    }
    func alertForRefreshReceipt(result: RefreshReceiptResult) -> UIAlertController
    {
        switch result {
        case .success(let receiptData):
            return alertWithTitle(title: "Receipt Refreshed", message: "Receipt refreshed successfully")
        case .error(let error):
            return alertWithTitle(title: "Receipt Refresh Failed", message: "The receipt refresh failed")
        }
    }
}
