//
//  WebViewController.swift
//  WorldTrotter
//
//  Created by Tim Miller on 7/14/19.
//  Copyright © 2019 Big Nerd Ranch. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    override func loadView() {
        let webView = WKWebView()
        
        let currentLocale = Locale.current
        
        var request = URLRequest(url: URL(string: "https://www.bignerdranch.com")!)
        request.setValue(currentLocale.identifier, forHTTPHeaderField: "Accept-Language")
        webView.load(request)
        
        view = webView
    }
    
}
