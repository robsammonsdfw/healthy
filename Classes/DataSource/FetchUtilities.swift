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
        // Soap 1.0.
        var jsonString = ""
        if let response = xml["soap:Envelope"]["soap:Body"][methodName + "Response"][methodName + "Result"].element?.text as String?  {
            jsonString = response
        }
        // Soap 1.2.
        if let response12 = xml["soap12:Envelope"]["soap12:Body"][methodName + "Response"][methodName + "Result"].element?.text as String?  {
            jsonString = response12
        }

        let data = jsonString.data(using: .utf8)!
        return data
    }
}
