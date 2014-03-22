//
//  CaputredImageManager.m
//  EduEye
//
//  Created by Einari Kurvinen on 22/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import "CapturedImageManager.h"

@implementation CapturedImageManager

@synthesize capturedImage;

+ (id)sharedManager {
    static CapturedImageManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        capturedImage = [[UIImage alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
