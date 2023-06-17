//
//  FactualMetadata.h
//  FactualSDK
//
//  Created by Brandon Yoshimoto on 8/1/12.
//  Copyright (c) 2012 Facutal Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactualRowMetadata : NSObject

/*! @method 
 @discussion Initialize metadata with a username for the person submitting the data 
 */
+(FactualRowMetadata*) metadata: (NSString *) username;

/*! @property 
 @discussion Set a user name for the person submitting the data 
 */
@property (nonatomic, strong) NSString* username;

/*! @property 
 @discussion Set a comment that will help to explain your corrections
 */
@property (nonatomic, strong) NSString* comment;

/*! @property 
 @discussion Set a reference to a URL, title, person, etc. that is the source of this data
 */
@property (nonatomic, strong) NSString* reference;

@end
