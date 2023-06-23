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
    private let namespace = "http://webservice.dmwebpro.com"
    private let userId = UserDefaults.standard.string(forKey: "userid_dietmastergo")
    private let authKey = UserDefaults.standard.string(forKey: "authkey_dietmastergo")
    
    // MARK: - Public

    /// Signs-in a user. Also used to syncronize the user's details such as name, etc. This does NOT sync
    /// a user's BirthDate, BMR, Goals, etc. Use -getUserDetails for that information.
    /// NOTE: The reason an NSError is not returned is because the server returns a status message which is
    /// then parsed by the system.
    @objc func signInUser(password: String, completion : @escaping (_ object: DMUser?, _ status: String?, _ message: String?) -> Void) {
        let authPassword = password.uppercased()
        let params = ["AuthKey": authPassword]
        let method = "Authenticate"
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            guard let responseXML = response.value else {
                completion(nil, "False", "Error! Please try again.")
                return
            }
            
            // Parse the XML response.
            guard let data = self.processXMLToData(xmlString: responseXML, for: method) else {
                completion(nil, "False", "Error! Please try again.")
                return
            }
            
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
                return
            }
        }
    }
    
    /// Fetches the current user's details, such as BMR, Height, Weight, etc.
    /// This is very similar to -signInUser, except it doesn't give UserID, CompanyID, or name info.
    @objc func getUserDetails(completion : @escaping (_ user: DMUser?, _ error: NSError?) -> Void) {
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            completion(nil, error)
            return
        }
        
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId ]
        let method = "SyncUser"
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            guard let responseXML = response.value else {
                let error = DMGUtilities.error(withMessage: "Response not valid.", code: 200) as NSError
                completion(nil, error)
                return
            }
            
            // Parse the XML response.
            guard let data = self.processXMLToData(xmlString: responseXML, for: method) else {
                let error = DMGUtilities.error(withMessage: "Cannot parse XML.", code: 300) as NSError
                completion(nil, error)
                return
            }
            
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    let error = DMGUtilities.error(withMessage: "Error parsing JSON or Invalid Auth.", code: 400) as NSError
                    completion(nil, error)
                    return
                }
                let jsonResult = jsonArray[0]
                let user = DMUser(dictionary: (jsonResult as NSDictionary) as! [AnyHashable : Any])
                completion(user, nil)
            } catch let error as NSError {
                completion(nil, error)
                return
            }
        }
    }
        
    /// Fetches the messages between the user and coach/provider.
    @objc func getMessages(completion : @escaping (_ messages: [DMMessage]?, _ error: NSError?) -> Void) {
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            completion(nil, error)
            return
        }
        
        // For LastMessageID, zero returns ALL, although the old code passed a DateTime object OF the LastMessage.
        // In the format of: "MM/dd/yyyy HH:mm:ss a". So, we'll just fetch all for now.
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId,
                      "LastMessageID": "0"]
        let method = "GetMessages"
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            
            guard let responseXML = response.value else {
                let error = DMGUtilities.error(withMessage: "Response not valid.", code: 200) as NSError
                completion(nil, error)
                return
            }
            
            // Parse the XML response.
            guard let data = self.processXMLToData(xmlString: responseXML, for: method) else {
                let error = DMGUtilities.error(withMessage: "Cannot parse XML.", code: 300) as NSError
                completion(nil, error)
                return
            }
            
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> else {
                    let error = DMGUtilities.error(withMessage: "Error parsing JSON or Invalid Auth.", code: 400) as NSError
                    completion(nil, error)
                    return
                }
                let jsonArray = jsonDict["Messages"] as! [Dictionary<String, Any>]
                
                var messages:[DMMessage] = []
                for dict in jsonArray {
                    let message = DMMessage(dictionary: (dict as NSDictionary) as! [AnyHashable : Any])
                    messages.append(message)
                }
                completion(messages, nil)
            } catch let error as NSError {
                completion(nil, error)
                return
            }
        }
    }
    
    /// Fetches the messages between the user and coach/provider.
    @objc func saveMessage(text: String?, completion : @escaping (_ message: DMMessage?, _ error: NSError?) -> Void) {
        guard let text = text else {
            let error = DMGUtilities.error(withMessage: "No message to save.", code: 000) as NSError
            completion(nil, error)
            return
        }
        
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            completion(nil, error)
            return
        }
        
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId,
                      "MessageText": text]
        let method = "SendMessage"
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            
            guard let responseXML = response.value else {
                let error = DMGUtilities.error(withMessage: "Response not valid.", code: 200) as NSError
                completion(nil, error)
                return
            }
            
            // Parse the XML response.
            guard let data = self.processXMLToData(xmlString: responseXML, for: method) else {
                let error = DMGUtilities.error(withMessage: "Cannot parse XML.", code: 300) as NSError
                completion(nil, error)
                return
            }
            
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    let error = DMGUtilities.error(withMessage: "Error parsing JSON or Invalid Auth.", code: 400) as NSError
                    completion(nil, error)
                    return
                }
                let jsonResult = jsonArray[0]
                let message = DMMessage(dictionary: jsonResult)
                message.updateText(text, senderId: userId, dateSent: Date())
                completion(message, nil)
            } catch let error as NSError {
                completion(nil, error)
                return
            }
        }
    }
    
    /// Fetches the messages between the user and coach/provider.
    /// Response is an array of dictionarys: {\"Status\":\"Success\",\"MessageID\":\"1722482\"}.
    @objc func setMessagesRead(messages: [DMMessage]?, completion : @escaping (_ messageIds: [Dictionary<String, Any>]?, _ error: NSError?) -> Void) {
        guard let messages = messages, messages.count > 0 else {
            let error = DMGUtilities.error(withMessage: "No message to set as read.", code: 000) as NSError
            completion(nil, error)
            return
        }
        
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            completion(nil, error)
            return
        }
        
        // Create array of messageIDs we will send to server.
        var messageIds = [[String: Any]]()
        for message in messages {
            let dict = ["MessageID" : message.messageId]
            messageIds.append(dict)
        }
        do {
            // Convert messages to JSON.
            let messageData = try JSONSerialization.data(withJSONObject: messageIds)
            guard let messageJSON = String(data: messageData, encoding: .utf8) else {
                let error = DMGUtilities.error(withMessage: "JSON is invalid.", code: 150) as NSError
                completion(nil, error)
                return
            }
            let params = ["AuthKey": authKey.uppercased(),
                          "UserID": userId,
                          "strJSON": messageJSON] as [String : Any]
            let method = "SetMessageRead"
            
            AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                      soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
                
                guard let responseXML = response.value else {
                    let error = DMGUtilities.error(withMessage: "Response not valid.", code: 200) as NSError
                    completion(nil, error)
                    return
                }
                
                // Parse the XML response.
                guard let data = self.processXMLToData(xmlString: responseXML, for: method) else {
                    let error = DMGUtilities.error(withMessage: "Cannot parse XML.", code: 300) as NSError
                    completion(nil, error)
                    return
                }
                
                do {
                    guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else {
                        let error = DMGUtilities.error(withMessage: "Error parsing JSON or Invalid Auth.", code: 400) as NSError
                        completion(nil, error)
                        return
                    }
                    completion(jsonArray, nil)
                } catch let error as NSError {
                    completion(nil, error)
                    return
                }
            }
        } catch let error as NSError {
            completion(nil, error)
            return
        }
    }

    // MARK: - Helpers

    /// Takes an XML Response as a string along with the method name and returns the Data that
    /// is inside the XML response.
    private func processXMLToData(xmlString: String?, for method: String?) -> Data? {
        guard let xmlString = xmlString, let method = method else { return nil }
        
        let xml = XMLHash.parse(xmlString)
        guard let jsonString = xml["soap:Envelope"]["soap:Body"][method + "Response"][method + "Result"].element?.text as String? else {
            return nil
        }
        
        let data = jsonString.data(using: .utf8)!
        return data
    }

}
