//
//  FetchUtilities.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/26/23.
//

import Foundation
import SWXMLHash

/// Utilities for fetching.
@objc class FetchUtilities : NSObject {
    
    /// Takes an XML Response as a string along with the method name and returns the Data that
    /// is inside the XML response.
    @objc public class func processXMLToData(xmlString: String?, methodName: String?) -> Data? {
        guard let xmlString = xmlString, let methodName = methodName else { return nil }
        
        let xml = XMLHash.parse(xmlString)
        guard let jsonString = xml["soap:Envelope"]["soap:Body"][methodName + "Response"][methodName + "Result"].element?.text as String? else {
            return nil
        }
        
        let data = jsonString.data(using: .utf8)!
        return data
    }
}
