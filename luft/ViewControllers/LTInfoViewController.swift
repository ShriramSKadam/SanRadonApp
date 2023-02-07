//
//  LTInfoViewController.swift
//  Luft
//
//  Created by iMac Augusta on 3/10/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

struct InfoValues{
    var title: String = ""
    var subTitle: String = ""
}

class LTInfoViewController: UIViewController {

    @IBOutlet weak var infoCollectionViewDevice: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var thisWidth:CGFloat = 0
    var arrInfoData:[InfoValues] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoCollectionViewDevice.register(UINib(nibName: cellIdentity.infoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: cellIdentity.infoCollectionViewCell)
        self.infoCollectionViewDevice?.delegate = self
        self.infoCollectionViewDevice?.dataSource = self
        //ThemeManager.applyTheme(theme: .theme2)
        self.view?.backgroundColor = ThemeManager.currentTheme().viewInfoBackgroundColor
        self.infoCollectionViewDevice?.backgroundColor = ThemeManager.currentTheme().viewInfoBackgroundColor
        //self.arrInfoData.append(InfoValues(title: "Verify Your Phone to Connect", subTitle: "Please verify that your iPhone is connected to the Wi-Fi network you would like to use with your Lüft Device."))
        self.arrInfoData.append(InfoValues(title: "Verify Your Phone is Connected to WiFi", subTitle: "To verify or setup a new Wi-Fi connection on your iPhone, please, open Settings/Wi-Fi. The Wi-Fi network must support the 2.4GHz Band. You will be asked to provide the Wi-Fi password later during the setup process. Wi-Fi connection is optional and can also be added and modified later."))
        self.arrInfoData.append(InfoValues(title: "Connect to Your Lüft Device", subTitle: "Please, plug your Lüft Device into a desired power outlet and stay within Bluetooth range (less than 15 feet) of that device during the entire setup procedure."))
        self.arrInfoData.append(InfoValues(title: "Warning!", subTitle: "This device emits LED light composed of Red, Green, and Blue colors.  Users with Photophobia conditions due to such LED lights should adjust Color, Brightness, or Disable the LED to avoid causing discomfort. After device setup, please, go to the Settings/Color menu to adjust LED settings for each device and each Indoor-Air-Quality status."))

        self.infoSetLatestStatusBar()
        
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
    }
    
   
    
    public func infoSetLatestStatusBar() {
        let sharedApplication = UIApplication.shared
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager!.statusBarFrame ?? CGRect.init(x: 0, y: 0, width: 0, height: 0))
            statusBar.backgroundColor = ThemeManager.currentTheme().viewInfoBackgroundColor
            sharedApplication.delegate?.window??.addSubview(statusBar)
        } else {
            sharedApplication.statusBarView?.backgroundColor = ThemeManager.currentTheme().viewInfoBackgroundColor
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pageControl.tintColor = UIColor.lightGray
        self.pageControl.numberOfPages = 3
        self.pageControl.currentPageIndicatorTintColor = ThemeManager.currentTheme().pageCurrentControlColor
        self.infoCollectionViewDevice?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource protocol
extension LTInfoViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
   }

   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let collectionViewWidth = collectionView.bounds.width
       return CGSize(width: collectionViewWidth, height: collectionView.bounds.height)
   }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOfDeviceNameCollection = self.infoCollectionViewDevice.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCell", for: indexPath) as! InfoCollectionViewCell
        cellOfDeviceNameCollection.btnDone.addTarget(self, action:#selector(self.btnTap(_sender:)), for: .touchUpInside)
        cellOfDeviceNameCollection.lblInfoCellTitle.text = self.arrInfoData[indexPath.row].title
        if indexPath.row == 2 {
            cellOfDeviceNameCollection.btnDone.isHidden = false
            cellOfDeviceNameCollection.imgViewCenter.image = UIImage.init(named: INFO_IMAGE3)
            
            let textString = self.arrInfoData[indexPath.row].subTitle
            let range = (textString as NSString).range(of: "Settings/Color")
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().subtitleTextColor, range: range)
            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.setAppFontBold(14), range: range)
            cellOfDeviceNameCollection.lblInfoCellSubTitle.attributedText = attributedString
        }else if indexPath.row == 1 {
            cellOfDeviceNameCollection.imgViewCenter.image = UIImage.init(named: INFO_IMAGE2)
            cellOfDeviceNameCollection.btnDone.isHidden = true
            cellOfDeviceNameCollection.lblInfoCellSubTitle.text = self.arrInfoData[indexPath.row].subTitle
            cellOfDeviceNameCollection.lblInfoCellSubTitle.textColor = ThemeManager.currentTheme().subtitleTextColor
        }else {
            cellOfDeviceNameCollection.imgViewCenter.image = UIImage.init(named: INFO_IMAGE1)
            cellOfDeviceNameCollection.btnDone.isHidden = true
            cellOfDeviceNameCollection.lblInfoCellSubTitle.text = self.arrInfoData[indexPath.row].subTitle
            cellOfDeviceNameCollection.lblInfoCellSubTitle.textColor = ThemeManager.currentTheme().subtitleTextColor

        }
        cellOfDeviceNameCollection.imgViewBacKLogo.image = ThemeManager.currentTheme().backUlogoImage
        
        return cellOfDeviceNameCollection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var nextItem = -1
        switch indexPath.item{
        case 0:
            nextItem = 1;
            break
        case 1:
            nextItem = 2;
            break
        case 2:
            nextItem = 0;
            break
            
        default:
            break
        }
        let nextIndexPath = IndexPath(item: nextItem, section: 0)
        collectionView.scrollToItem(at: nextIndexPath, at: UICollectionView.ScrollPosition.left, animated: true)
    }

    @objc func btnTap(_sender:UIButton) {
        AppSession.shared.setIsInfo(isInfo:true)
        self.navigationController?.popViewController(animated: false)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        //print(pageControl.currentPage)
        self.infoCollectionViewDevice.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControl.currentPage = Int(pageNumber)
            //print(pageControl.currentPage)

        }
    
}
