//
//  CHGTViewController.h
//  EduEye
//
//  Thanks for QR-code stuff: https://gist.github.com/Alex04/6976945
//  Created by Einari Kurvinen on 16/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AsyncUdpSocket.h"
#import "HTTPServer.h"

//Use RoutingHTTPServer which is build on top of CocoaHTTPServer
//https://github.com/mattstevens/RoutingHTTPServer
#import "RoutingHTTPServer.h"

@protocol CHGTViewControllerDelegate;

@interface CHGTViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) id<CHGTViewControllerDelegate> delegate;
@property (strong, nonatomic) RoutingHTTPServer *httpServer;

@property (weak, nonatomic) IBOutlet UILabel *textField1;
@property (weak, nonatomic) IBOutlet UIButton *readQRBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitScan;

//QR-Code scanning
-(IBAction)scanQRCode;
-(IBAction)exitQRCode;

-(void) startScanning;
-(void) stopScanning;
-(void) setTextToLabel:(NSString *) text;

//Wifi connection
-(IBAction)connectToWifi;
-(BOOL)isConnected;

//UDP communication
-(void)sendUDPDatagram: (NSString *) dest;

//HTTP-server methods
-(void) startServer;
-(void) stopServer;

//Image streaming
-(void) setupImageStreaming;
-(void) startImageStreaming;
-(void) stopImageStreaming;
-(void)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@protocol CHGTViewControllerDelegate <NSObject>
@optional
-(void) scanViewController:(CHGTViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

@end