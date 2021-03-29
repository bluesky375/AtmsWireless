//
//  APIManager.swift
//  AtmsWireless
//
//  Created by Big Sur on 3/9/21.
//

import Foundation
import Alamofire
import SWXMLHash
import KVNProgress
import PopupDialog

class APIManager {
    static let sharedInstance = APIManager()
    private init() {
        print("Navmanager Initialized")
    }

    public func getLists(username: String, password: String, type: String, completion: @escaping (_ result: [[String: Any]])->()) {
        let parameters = [
            "Username": username,
            "Password": password,
            "Type": type
        ]

        let headers = ["Content-Type": "application/json"]
        let urlString = "https://www.wtiwireless.com/RouterInfo.asmx/GetRouterList"

        AF.request(urlString, parameters: parameters).response { response in
            switch response.result {
            case .success(let JSON):
                let xml = SWXMLHash.parse(JSON!)
                let string = xml["string"].element?.text
                let post = self.convertToDictionary(text: string!)
                completion(post!)
            case .failure(let error):
                print(error.localizedDescription)
                KVNProgress.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    public func getRouterInfo(username: String, password: String, sn: String, completion: @escaping ([[String: Any]]?, Error?)->()) {
        let parameters = [
            "Username": username,
            "Password": password,
            "sn": sn
        ]

        let headers = ["Content-Type": "application/json"]
        let urlString = "https://www.wtiwireless.com/RouterInfo.asmx/GetRouterInfo"

        AF.request(urlString, parameters: parameters).response { response in
            switch response.result {
            case .success(let JSON):
                let xml = SWXMLHash.parse(JSON!)
                let string = xml["string"].element?.text
                let post = self.convertToDictionary(text: string!)
                completion(post!, nil)
            case .failure(let error):
                print(error.localizedDescription)
                KVNProgress.showError(withStatus: error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    func convertToDictionary(text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
