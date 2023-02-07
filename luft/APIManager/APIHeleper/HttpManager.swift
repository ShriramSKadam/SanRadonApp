//  HttpManager.swift
//  Created by CogInfo-Nandakumar on 23/11/17.
//  Copyright © 2017 CogInfo-Nandakumar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire.Swift

class HttpManager: NSObject {

    static let sharedInstance = HttpManager()
    var isFromGetNewPass = Bool()
    
    
    func getDefaultHeaderDetails() -> [String:String]
    {
        let headers = ["token":  AppSession.shared.getAccessToken()]
        return headers
    }
    
   
    func getCurrentDeviceTokenDetails() -> [String:String]
    {
        let headers = ["token":  AppSession.shared.getCurrentDeviceToken()]
        return headers
    }
    
    func loginWithUserEmailData(userData: NSDictionary,
                             successBlock: @escaping kModelSuccessBlock,
                             failureBlock : @escaping kModelErrorBlock){
        var urlValue = String()
        urlValue = API_MANAGER_GET_BASE_URL + API_LOGIN_EMAIL as String
        self.convertDictionaryToJsonString(userDict: userData, url: urlValue)
        
        Alamofire.request(urlValue, method: .post, parameters: userData as? [String : AnyObject], encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    successBlock(true, "Success",response.result.value as AnyObject)
                }
                
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func getHomeBuildTypeMe(userData: String,
                            successBlock: @escaping kModelSuccessBlock,
                            failureBlock : @escaping kModelErrorBlock){
        let getStateParamStr:String = API_MANAGER_GET_BASE_URL + API_SETTING_HOME_BULIDING_TYPE
        self.urlString(strUrl:getStateParamStr)
        
        
        Alamofire.request(getStateParamStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getDefaultHeaderDetails()).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    successBlock(true, "success", response.result.value as AnyObject)
                }
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    func getMitigationTypeMe(userData: String,
                            successBlock: @escaping kModelSuccessBlock,
                            failureBlock : @escaping kModelErrorBlock){
        let getStateParamStr:String = API_MANAGER_GET_BASE_URL + API_SETTING_HOME_MITIGATION_TYPE
        self.urlString(strUrl:getStateParamStr)
        
        
        Alamofire.request(getStateParamStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getDefaultHeaderDetails()).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    successBlock(true, "success", response.result.value as AnyObject)
                }
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func getMyDeviceDetails(userData: String,
                            successBlock: @escaping kModelSuccessBlock,
                            failureBlock : @escaping kModelErrorBlock){
        let getStateParamStr:String = API_MANAGER_GET_BASE_URL + API_SETTING_HOME_BULIDING_TYPE
        self.urlString(strUrl:getStateParamStr)
        
        
        Alamofire.request(getStateParamStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getDefaultHeaderDetails()).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    successBlock(true, "success", response.result.value as AnyObject)
                }
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func getSignUpAPIData(userData: [UpdateDeviceSettingViewModel]? = nil,
                                successBlock: @escaping kModelSuccessBlock,
                                failureBlock : @escaping kModelErrorBlock){
        var urlValue = String()
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: userData)
        urlValue = API_MANAGER_GET_BASE_URL + API_SETTING_SAVE_DEVICE_DATA as String
        Alamofire.request(urlValue , method: .post, parameters:parameters as? [String : AnyObject], encoding: URLEncoding.default).responseJSON { (response:DataResponse<Any>) in

            print(response)
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    successBlock(true, "Success",response.result.value as AnyObject)
                }
                break

            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func getOutsideDataAPI(latValue: String,longValue: String,
                             successBlock: @escaping kModelSuccessBlock,
                             failureBlock : @escaping kModelErrorBlock){
        
        let getStateParamStr:String = String(format: "%@?lat=%@&lon=%@&appid=%@", LIVE_OPEN_WEATHER_MAP_URL,latValue,longValue,OUTSIDE_DATA_API_KEY)
        self.urlString(strUrl:getStateParamStr)
        
        Alamofire.request(getStateParamStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getDefaultHeaderDetails()).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    successBlock(true, "success", response.result.value as AnyObject)
                }
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func getOutsideAirQualityAPI(latValue: String,longValue: String,
                             successBlock: @escaping kModelSuccessBlock,
                             failureBlock : @escaping kModelErrorBlock){
        
        let getStateParamStr:String = String(format: "%@?lat=%@&lon=%@&appid=%@", LIVE_OPEN_AIR_QUALITY_URL ,latValue,longValue,OUTSIDE_DATA_API_KEY)
        self.urlString(strUrl:getStateParamStr)
        
        Alamofire.request(getStateParamStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getDefaultHeaderDetails()).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    successBlock(true, "success", response.result.value as AnyObject)
                }
                break
                
            case .failure(let error):
                failureBlock(error.localizedDescription as String)
                break
            }
        }
    }
    
    func convertDictionaryToJsonString(userDict: NSDictionary?,url:String) {
        print("***********************?************************")
        let jsonData = try? JSONSerialization.data(withJSONObject: userDict ?? [], options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        print(jsonString ?? "Not parsed")
        print("***********************?************************")
        print("URL = " + url)
        
    }
    func urlString(strUrl:String) {
        print("***********************?************************")
        print("URL = " + strUrl)
        print("***********************?************************")
    }
}
