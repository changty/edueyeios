//
//  CaputredImageManager.h
//  EduEye
//
//  Created by Einari Kurvinen on 22/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CapturedImageManager : NSObject
{
    UIImage *capturedImage;
}

@property (nonatomic, retain) UIImage *capturedImage;

+ (id)sharedManager;
@end
