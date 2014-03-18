//
//  CHGTViewController.m
//  EduEye
//
//  Created by Einari Kurvinen on 16/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import "CHGTViewController.h"
#import "Reachability.h"

@interface CHGTViewController ()

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@end

@implementation CHGTViewController
@synthesize textField1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // [self readQRCode];
    
    //Check that user is connected to WLAN
    if (![self isConnected]) {
        [self connectToWifi];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setTextToLabel:(NSString *) text {
    
}

//Handle situations where camera is not available
- (void) setupNoCameraView;
{
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = [UIColor blackColor];
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

//Handle device rotation
//- (NSUInteger)supportedInterfaceOrientations;
//{
//    return true;
//    //return UIInterfaceOrientationMaskLandscape;
//}

- (BOOL)shouldAutorotate;
{
    return [[UIDevice currentDevice] orientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    else {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
}


// Return true/false whether wlan is enabled or not.
-(BOOL)isConnected
{
    NSLog(@"Connection status: %d",[[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]);

    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi) {
        NSLog(@"Not connected");
        return NO;
    }
    else {
        NSLog(@"Connected");
        return YES;
    }

}

//Show notification, which tells the user to connect to wlan.
-(IBAction)connectToWifi
{
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Wifi missing" message:@"Please turn on the Wifi connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
}


// QR-code scanning
- (BOOL) isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)startScanning;
{
    [self.session startRunning];
    
}

- (void) stopScanning;
{
    [self.session stopRunning];
    
    [self.preview removeFromSuperlayer];
}

- (void) setupScanner;
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
}

-(IBAction)scanQRCode
{
    [self setupScanner];
    [self startScanning];
    
//    NSLog(@"Scan QR-Code");
//    AVCaptureSession *session = [[AVCaptureSession alloc] init];
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    NSError *error = nil;
//    
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//    
//    if(input) {
//        [session addInput:input];
//    }
//    else {
//        NSLog(@"Error: %@", error);
//    }
//    
//    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
//    
//    [output availableMetadataObjectTypes];
//    NSLog(@"Available metadata... %@", [output availableMetadataObjectTypes]);
//    
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
//    [session addOutput:output];
//    
//    [session startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            //if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                NSLog(@"Scanned value: %@", scannedValue);
                [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
            //set text to textfield
            NSString *outputStr =  [NSString stringWithFormat:@"Connected to: %@", scannedValue];
            self.textField1.text = outputStr;
            
            [self stopScanning];
            //}
        }
    }
}

@end
