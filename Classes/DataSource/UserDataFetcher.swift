//
//  UserDataFetcher.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/17/23.
//

import Foundation
import AlamofireSoap

/// Fetcher for making network requests to the DMG backend to
/// fetch USER data, which includes Messages.
class UserDataFetcher : NSObject {
    private let namespace = "http://webservice.dmwebpro.com"
    private let userId: NSNumber? = DMAuthManager.sharedInstance().loggedInUser()?.userId
    private let authKey: String? = DMAuthManager.sharedInstance().loggedInUser()?.authToken
    
    // MARK: - Public

    /// Signs-in a user. Also used to syncronize the user's details such as name, etc. This does NOT sync
    /// a user's BirthDate, BMR, Goals, etc. Use -getUserDetails for that information.
    /// NOTE: The reason an NSError is not returned is because the server returns a status message which is
    /// then parsed by the system.
    @objc func signInUser(password: String, completion : @escaping (_ object: DMUser?, _ status: String?, _ message: String?) -> Void) {
        let authPassword = password.uppercased()
        let params = ["AuthKey": authPassword]
        let method = "Authenticate"
        
        performFetch(method: method, params: params, namespace: namespace) { xmlData, error in
            guard let xmlData = xmlData else {
                DispatchQueue.main.async {
                    completion(nil, "False", "Error! Please try again.")
                }
                return
            }
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: xmlData, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    let error = DMGUtilities.error(withMessage: "Error parsing fetched JSON.", code: 400) as NSError
                    DispatchQueue.main.async {
                        completion(nil, "False", "Error! Please try again.")
                    }
                    return
                }
                let jsonResult = jsonArray[0]
                let user = DMUser(dictionary: (jsonResult as NSDictionary) as! [AnyHashable : Any])
                DispatchQueue.main.async {
                    completion(user, jsonResult["Status"] as? String, jsonResult["Message"] as? String)
                }
            } catch let error as NSError {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, "False", "Error! Please try again.")
                }
                return
            }
        }
    }
    
    // MARK: User
    
    /// Fetches the current user's details, such as BMR, Height, Weight, etc.
    /// This is very similar to -signInUser, except it doesn't give UserID, CompanyID, or name info.
    @objc func getUserDetails(completion : @escaping (_ dict: [AnyHashable : Any]?, _ error: NSError?) -> Void) {
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId ] as [String : Any]
        let method = "SyncUser"
        
        performFetch(method: method, params: params, namespace: namespace) { xmlData, error in
            guard let xmlData = xmlData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: xmlData, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    let error = DMGUtilities.error(withMessage: "Error parsing fetched JSON.", code: 400) as NSError
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                let jsonResult = jsonArray[0]
                DispatchQueue.main.async {
                    completion((jsonResult as NSDictionary) as? [AnyHashable : Any], nil)
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
        }
    }
    
    // MARK: Messages
        
    /// Fetches the messages between the user and coach/provider.
    @objc func getMessages(completion : @escaping (_ messages: [DMMessage]?, _ error: NSError?) -> Void) {
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        // For LastMessageID, zero returns ALL, although the old code passed a DateTime object OF the LastMessage.
        // In the format of: "MM/dd/yyyy HH:mm:ss a". So, we'll just fetch all for now.
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId,
                      "LastMessageID": "0"] as [String : Any]
        let method = "GetMessages"
        
        performFetch(method: method, params: params, namespace: namespace) { xmlData, error in
            guard let xmlData = xmlData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: xmlData, options : .allowFragments) as? Dictionary<String,Any> else {
                    let error = DMGUtilities.error(withMessage: "Error parsing fetched JSON.", code: 400) as NSError
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                let jsonArray = jsonDict["Messages"] as! [Dictionary<String, Any>]
                var messages:[DMMessage] = []
                for dict in jsonArray {
                    let message = DMMessage(dictionary: (dict as NSDictionary) as! [AnyHashable : Any])
                    messages.append(message)
                }
                DispatchQueue.main.async {
                    completion(messages, nil)
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
        }
    }
    
    /// Fetches the messages between the user and coach/provider.
    @objc func saveMessage(text: String?, completion : @escaping (_ message: DMMessage?, _ error: NSError?) -> Void) {
        guard let text = text else {
            let error = DMGUtilities.error(withMessage: "No message to save.", code: 000) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        let params = ["AuthKey": authKey.uppercased(),
                      "UserID": userId,
                      "MessageText": text] as [String : Any]
        let method = "SendMessage"
        
        performFetch(method: method, params: params, namespace: namespace) { xmlData, error in
            guard let xmlData = xmlData else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            do {
                guard let jsonArray = try JSONSerialization.jsonObject(with: xmlData, options : .allowFragments) as? [Dictionary<String,Any>] else {
                    let error = DMGUtilities.error(withMessage: "Error parsing fetched JSON.", code: 400) as NSError
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                let jsonResult = jsonArray[0]
                let message = DMMessage(dictionary: jsonResult)
                message.updateText(text, senderId: userId.stringValue, dateSent: Date())
                DispatchQueue.main.async {
                    completion(message, nil)
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
        }
    }
    
    /// Sets the messages provided to "read" on the server.
    @objc func setMessagesRead(messages: [DMMessage]?, completion : @escaping (_ messageIds: [Dictionary<String, Any>]?, _ error: NSError?) -> Void) {
        guard let messages = messages, messages.count > 0 else {
            let error = DMGUtilities.error(withMessage: "No message to set as read.", code: 000) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
        
        guard let userId = userId, let authKey = authKey else {
            let error = DMGUtilities.error(withMessage: "User not authenticated.", code: 100) as NSError
            DispatchQueue.main.async {
                completion(nil, error)
            }
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
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let params = ["AuthKey": authKey.uppercased(),
                          "UserID": userId,
                          "strJSON": messageJSON] as [String : Any]
            let method = "SetMessageRead"
            
            performFetch(method: method, params: params, namespace: namespace) { xmlData, error in
                guard let xmlData = xmlData else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                do {
                    guard let jsonArray = try JSONSerialization.jsonObject(with: xmlData, options : .allowFragments) as? [Dictionary<String,Any>] else {
                        let error = DMGUtilities.error(withMessage: "Error parsing fetched JSON.", code: 400) as NSError
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(jsonArray, nil)
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
            }
        } catch let error as NSError {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }
    }
    
    /// Performs the fetch.
    private func performFetch(method: String, params: [String : Any], namespace: String,
                              completion : @escaping (_ xmlData: Data?, _ error: NSError?) -> Void) {
        
        AlamofireSoap.soapRequest("http://webservice.dmwebpro.com/DMGoWS.asmx?op=" + method,
                                  soapmethod: method, soapparameters: params, namespace: namespace).responseString { response in
            
            guard let responseXML = response.value else {
                let error = DMGUtilities.error(withMessage: "Response not valid.", code: 200) as NSError
                completion(nil, error)
                return
            }
            
            // Parse the XML response.
            guard let data = FetchUtilities.processXMLToData(xmlString: responseXML, methodName: method) else {
                let error = DMGUtilities.error(withMessage: "Cannot parse XML.", code: 300) as NSError
                completion(nil, error)
                return
            }
            
            // Success!
            completion(data, nil)
        }
    }
}
