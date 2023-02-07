//
//  WebDataViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/22/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import WebKit

protocol LTIntialAGREEDelegate:class {
    func selectedIntialAGREE()
}

class WebDataViewController: UIViewController,WKNavigationDelegate,WKUIDelegate {

    @IBOutlet weak var lblHeader: LTHeaderTitleLabel!
    @IBOutlet weak var btnBack: LTBackImageButton!
    @IBOutlet weak var dataWebView: UIView!
    @IBOutlet weak var headerView: AppHeaderView!
    @IBOutlet weak var intialBackView: UIView!
    @IBOutlet weak var btnWebView: UIButton!
    @IBOutlet weak var webViewIntial: WKWebView!
    @IBOutlet weak var activityWebview: UIActivityIndicatorView!
    @IBOutlet weak var activityWebview1: UIActivityIndicatorView!
    @IBOutlet weak var webView: WKWebView!
    
    var strTitle:String = ""
    var isFromIntial:Bool = false
    var delegateIntailAgree:LTIntialAGREEDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isFromIntial == true {
           let link = URL(string:PRIVACY_POLICY)!
            self.webViewIntial?.uiDelegate = self
            self.webViewIntial.navigationDelegate = self
            let request = URLRequest(url: link)
            self.webViewIntial?.load(request)
        }else {
            self.webView?.uiDelegate = self
            self.webView.navigationDelegate = self
            self.lblHeader.text = self.strTitle
            var linkStr:String = ""
            if self.lblHeader.text == TERMS_AND_CONDITIONS_TITLE {
                linkStr = TERMS_AND_CONDTIONS
            }
            if self.lblHeader.text == PRIVACY_POLICY_TITLE {
                linkStr = PRIVACY_POLICY
            }
            if self.lblHeader.text == PRODUCT_WARRANTY {
                linkStr = PRODUCT_WARRANTY_URL
            }
            if self.lblHeader.text == SERVICE_WARRANTY {
                linkStr = SERVICE_WARRANTY_URL
            }
            let link = URL(string:linkStr)!
            let request = URLRequest(url: link)
            self.webView?.load(request)
            textLog.write("Loaded New Facebook or Google Login Web View - 4")
        }
        self.btnBack.addTarget(self, action:#selector(self.btnBackTap(_sender:)), for: .touchUpInside)
        self.btnWebView.addTarget(self, action:#selector(self.btnWebViewTap(_sender:)), for: .touchUpInside)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnWebView.isHidden = false
        if self.isFromIntial == true {
            self.headerView.isHidden = true
            self.dataWebView.isHidden = true
            self.intialBackView.isHidden = false
            self.view.backgroundColor = UIColor.init(hexString: "545454")
            self.btnWebView.setTitle("AGREE PRIVACY POLICY AND CONTINUE", for: .normal)
        }else {
            self.dataWebView.isHidden = false
            self.headerView.isHidden = false
            self.btnWebView.isHidden = true
            self.intialBackView.isHidden = true
            self.showActivityIndicator(self.view)
        }
        self.btnWebView.tag = 1002
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
            self.hideActivityIndicator(self.view)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
         self.tabBarController?.tabBar.isHidden = false
    }
 
    @objc func btnBackTap(_sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnWebViewTap(_sender:UIButton) {
        if _sender.tag == 1001 {
            self.delegateIntailAgree?.selectedIntialAGREE()
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.btnWebView.setTitle("AGREE TERMS & CONDITIONS AND CONTINUE", for: .normal)
        let link = URL(string:TERMS_AND_CONDTIONS)!
        let request = URLRequest(url: link)
        self.webViewIntial?.load(request)
        self.showActivityIndicator(self.webViewIntial)
        _sender.tag = 1001
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.hideActivityIndicator(self.webViewIntial)
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showDefaultActivity()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation:
        WKNavigation!) {
        self.hideDefaultActivity()
    }
    
    func webView(_ webView: WKWebView, didFail navigation:
        WKNavigation!, withError error: Error) {
        self.hideDefaultActivity()
    }
    
    func showDefaultActivity()  {
        if self.isFromIntial == true {
            self.activityWebview?.startAnimating()
        }else {
            self.activityWebview1?.startAnimating()
        }
    }
    
    func hideDefaultActivity()  {
        if self.isFromIntial == true {
            self.activityWebview?.stopAnimating()
            self.activityWebview?.isHidden = true
        }else {
            self.activityWebview1?.stopAnimating()
            self.activityWebview1?.isHidden = true
        }
    }
}


