//
//  CHGTViewController.h
//  EduEye
//
//  Thanks for: https://gist.github.com/Alex04/6976945
//  Created by Einari Kurvinen on 16/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CHGTViewControllerDelegate;

@interface CHGTViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<CHGTViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *textField1;

//QR-Code scanning
-(IBAction)scanQRCode;
-(void) startScanning;
-(void) stopScanning;
-(void) setTextToLabel:(NSString *) text;

//Wifi connection
-(IBAction)connectToWifi;
-(BOOL)isConnected;

@end

@protocol CHGTViewControllerDelegate <NSObject>
@optional

-(void) scanViewController:(CHGTViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

@end