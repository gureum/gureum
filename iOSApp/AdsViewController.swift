//
//  AdsViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2015. 5. 27..
//  Copyright (c) 2015년 youknowone.org. All rights reserved.
//

import GoogleMobileAds
import UIKit

let ADMOB_BANNER_ID: String = ""
let ADMOB_INTERSTITIAL_ID: String = ""

@objc extension UIViewController {
    var bannerAdsView: GADBannerView! { return nil }

    func loadBannerAds() {
        if ADMOB_BANNER_ID != "" {
            bannerAdsView.adUnitID = ADMOB_BANNER_ID
            bannerAdsView.rootViewController = self

            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            bannerAdsView.load(request)
        }
    }

    func loadInterstitialAds() -> GADInterstitial! {
        if ADMOB_INTERSTITIAL_ID != "" {
            let interstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_ID)
            interstitial.delegate = self as? GADInterstitialDelegate

            let request = GADRequest()
            // request.testDevices = [kGADSimulatorID]
            interstitial.load(request)
            return interstitial
        } else {
            return nil
        }
    }
}
