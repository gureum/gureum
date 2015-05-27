//
//  AdsViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2015. 5. 27..
//  Copyright (c) 2015년 youknowone.org. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController {

    var bannerAdsView: GADBannerView! { get { return nil; } }

    func loadBannerAds() {
        if ADMOB_BANNER_ID != "" {
            self.bannerAdsView.adUnitID = ADMOB_BANNER_ID
            self.bannerAdsView.rootViewController = self

            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            self.bannerAdsView.loadRequest(request)
        }
    }

    func loadInterstitialAds() -> GADInterstitial! {
        if ADMOB_INTERSTITIAL_ID != "" {
            let interstitial = GADInterstitial(adUnitID: ADMOB_INTERSTITIAL_ID)
            interstitial.delegate = self as! GADInterstitialDelegate

            let request = GADRequest()
            //request.testDevices = [kGADSimulatorID]
            interstitial.loadRequest(request)
            return interstitial
        } else {
            return nil
        }
    }

}
