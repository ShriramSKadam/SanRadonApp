//
//  LUWebViewController.swift
//  Luft
//
//  Created by user on 5/13/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import WebKit

class LUWebViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var webViewData: WKWebView!
    @IBOutlet weak var btnBack: UIButton!
    var urlTypeInt: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
        var linkStr:String = ""
        switch self.urlTypeInt {
        case 1:
            linkStr = "https://sunradon.com/resources-support#faq"
            self.lblTitle?.text = "Terms and Conditions"
            break
        case 2:
            linkStr = "https://sunradon.com/resources-support#faq"
            self.lblTitle?.text = "Privacy Policy"
        case 3:
            linkStr = "https://sunradon.com/resources-support#faq"
            self.lblTitle?.text = "Contact User Manual"
            break
        case 4:
            linkStr = "https://sunradon.com/resources-support#faq"
            self.lblTitle?.text = "Privacy Policy"
            break
        case 5:
            linkStr = "https://sunradon.com/resources-support#faq"
            self.lblTitle?.text = "FAQ"
            break
        default:
            break
        }
        let link = URL(string:linkStr)!
        let request = URLRequest(url: link)
        self.webViewData.load(request)
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
}
extension LUWebViewController{
    
    func initialSetup(){
        self.btnBack.addTarget(self, action: #selector(self.backButtonTapped), for: .touchUpInside)
        self.webViewData?.uiDelegate = self
        self.webViewData.navigationDelegate = self
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.showActivityIndicator(self.view)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension LUWebViewController:WKNavigationDelegate,WKUIDelegate{
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showActivityIndicator(self.view)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation:
        WKNavigation!) {
        self.hideActivityIndicator(self.view)
    }
    
    func webView(_ webView: WKWebView, didFail navigation:
        WKNavigation!, withError error: Error) {
        self.hideActivityIndicator(self.view)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if webView != self.webViewData {
            decisionHandler(.allow)
            return
        }
        
        let app = UIApplication.shared
        if let url = navigationAction.request.url {
            // Handle target="_blank"
            if navigationAction.targetFrame == nil {
                if app.canOpenURL(url) {
                    app.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            // Handle phone and email links
            if url.scheme == "tel" || url.scheme == "mailto" {
                if app.canOpenURL(url) {
                    app.open(url)
                }
                
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
    }
    
}
