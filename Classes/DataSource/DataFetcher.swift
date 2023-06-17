//
//  DataFetcher.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

import Foundation
import AlamofireSoap
import SWXMLHash

/// Fetcher for making network requests to the DMG backend.
class DataFetcher : NSObject {
    
    /// Signs-in a user.
    @objc func signInUser(password: String, completion : @escaping (_ object: DMUser?, _ status: String?, _ message: String?) -> Void) {
        let authPassword = password.uppercased()

        let namespace = "http://webservice.dmwebpro.com"
        let params = ["AuthKey": authPassword]
        let method = "Authenticate"
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=Authenticate",
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            
            guard let responseXML = response.value else {
                completion(nil, "False", "Error! Please try again.")
                return
            }
            
            // Parse the XML response.
            let xml = XMLHash.parse(responseXML)
            guard let jsonString = xml["soap:Envelope"]["soap:Body"]["AuthenticateResponse"]["AuthenticateResult"].element?.text as String? else {
                completion(nil, "False", "Error! Please try again.")
                return
            }
            
            // Parse the JSON.
            let data = jsonString.data(using: .utf8)!
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    completion(nil, "False", "Error! Please try again.")
                    return
                }
                let jsonResult = jsonArray[0]
                let user = DMUser(dictionary: (jsonResult as NSDictionary) as! [AnyHashable : Any])
                completion(user, jsonResult["Status"] as? String, jsonResult["Message"] as? String)
            } catch let error as NSError {
                print(error)
                completion(nil, "False", "Error! Please try again.")
            }
        }
    }
}
