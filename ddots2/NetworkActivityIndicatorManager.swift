//
//  NetworkActivityIndicatorManager.swift
//  ddots2
//
//  Created by Marzuk Rashid on 1/2/17.
//  Copyright © 2017 Platiplur. All rights reserved.
//

import UIKit

class NetworkActivityIndicatorManager: NSObject
{
    private static var loadingCount = 0
    
    class func NetworkOperationStarted()
    {
        if loadingCount == 0
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func networkOperationFinished()
    {
        if loadingCount > 0
        {
            loadingCount -= 1
        }
        if loadingCount == 0
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
