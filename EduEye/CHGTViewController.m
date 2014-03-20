//
//  CHGTViewController.m
//  EduEye
//
//  Created by Einari Kurvinen on 16/03/14.
//  Copyright (c) 2014 chgt. All rights reserved.
//

#import "CHGTViewController.h"
#import "Reachability.h"
#import "CHGTConstants.h"

@interface CHGTViewController ()

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureVideoDataOutput* videoOutput;

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;
@property (strong, nonatomic) UIImage* capturedImage;
@end

@implementation CHGTViewController
@synthesize textField1;
@synthesize readQRBtn;
@synthesize exitScan;

//This method makes sure that scan stops!
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
    
    //Check that user is connected to WLAN
    if (![self isConnected]) {
        [self connectToWifi];
    }
    
    NSLog(@"viewDidLoad speaking");
    NSLog(@"viewLoad Orientation: %d", [[UIDevice currentDevice] orientation]);

    //Start http-server
    [self startServer];
    [self startImageStreaming];

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
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Could not open any camera." message:@"Try restarting EduEye" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
    
    [self stopServer];
    [self stopImageStreaming];
    self.readQRBtn.enabled = NO;
}

- (BOOL)shouldAutorotate;
{
    return YES;
    // return [[UIDevice currentDevice] orientation];
}

//Rotates both scan preview and image feed preview (same object)
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
    
    self.preview.frame = self.view.bounds;
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

//Starts scanning and image feeding
- (void)startScanning;
{
    [self.session startRunning];
    self.textField1.hidden = YES;
    self.readQRBtn.hidden = YES;

}

//Stops scanning and image feeding
- (void) stopScanning;
{
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
}

- (void) setupScanner;
{
    NSLog(@"Start QR-Code scanner");
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (!self.input) {
        // Handle the error appropriately.
    }

    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    NSLog(@"Orientation: %d", [[UIDevice currentDevice] orientation]);
    //initiate camera in correct position
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
    
    //self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.preview.frame = self.view.bounds;


    
}

-(IBAction)scanQRCode
{
    //Make sure that image feed is stopped.
    [self stopScanning];
    //Setup QR-code reader (different than imagefeed)
    [self setupScanner];
    
    //Start scanner view (image feed uses the same method)
    [self startScanning];
    
    self.exitScan.hidden = NO;

}

-(IBAction) exitQRCode
{
    self.exitScan.hidden = YES;
    [self stopScanning];
    [self startImageStreaming];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            //if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                NSLog(@"Scanned value: %@", scannedValue);
                [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
            //set text to textfield
            NSString *outputStr =  [NSString stringWithFormat:@"Connected to: %@", scannedValue];
            
            //Send packet to server
            [self sendUDPDatagram:scannedValue];
            //Show scanned ip
            self.textField1.text = outputStr;
            //Stop QR-code scanning
            [self stopScanning];
            //Start image feed
            [self startImageStreaming];
            
            //}
        }
    }
}


//UDP communication
//Send a packet to server so that the server knows where to look at images
- (void) sendUDPDatagram: (NSString *) dest
{
    NSLog(@"Sending packet to %@", dest);
    NSString *message = @"Hello, I'm an IOS-device";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc] initIPv4];
    [socket sendData:data toHost:dest port:PORT withTimeout:-1 tag:1];
}

// HTTP-Sever
-(void) startServer
{
    self.httpServer = [[RoutingHTTPServer alloc] init];
    
    NSLog(@"Set WWW port to %i", WWWPORT);
    [self.httpServer setPort:WWWPORT];
    [self.httpServer setDefaultHeader:@"Server" value:@"EduEye/1.0"];
    
    NSError *error = nil;
	if(![self.httpServer start:&error])
	{
        NSLog(@"Error starting HTTP Server: %@", error);
	}
    
    
    // Get requests =================================
    //cgi/query
    [self.httpServer get:@"/cgi/query" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response setHeader:@"Content-Type" value:@"text/plain"];
        [response respondWithString:[NSString stringWithFormat:@"ios"]];
    }];
    
    //cgi/setup
    [self.httpServer get:@"/cgi/setup" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSString* wid = [request param: @"wid"];
        NSString* hei = [request param: @"hei"];
        
        [response setHeader:@"Content-Type" value:@"text/plain"];
        NSLog(@"Wid: %@ and Hei: %@", wid, hei);
        [response respondWithString:[NSString stringWithFormat:@"setup"]];
    }];
    
    //cgi/getMaxZoom
    [self.httpServer get:@"/cgi/getMaxZoom" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response setHeader:@"Content-Type" value:@"text/plain"];
        [response respondWithString:[NSString stringWithFormat:@"5"]];
    }];
    
    //cgi/zoom
    [self.httpServer get:@"/cgi/zoom" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSString* zoom = [request param: @"zoom"];
        NSLog(@"Zoom %@", zoom);
        [response setHeader:@"Content-Type" value:@"text/plain"];
        [response respondWithString:[NSString stringWithFormat:@"OK"]];
    }];
    
    //cgi/focus
    [self.httpServer get:@"/cgi/focus" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response setHeader:@"Content-Type" value:@"text/plain"];
        [response respondWithString:[NSString stringWithFormat:@"OK"]];
    }];

    //stream/live.jpg
    [self.httpServer get:@"/stream/live.jpg*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSLog(@"Responding with image....");
        [response setHeader:@"Content-Type" value:@"image/jpeg"];
        NSData *imageData = UIImageJPEGRepresentation(self.capturedImage, 0.3);
        [response respondWithData:imageData];
    }];

}

-(void) stopServer
{
    [self.httpServer stop];
}


//Image streaming
-(void)setupImageStreaming
{
    NSLog(@"Starting image streaming");
    NSError *error = [[NSError alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!self.input) {
        NSLog(@"No input");
    }

    self.session = [[AVCaptureSession alloc] init];
    
    //Control video quality
    //There's also other possible resolutions
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    else {
        NSLog(@"Error setting resolution");
    }
    
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:self.videoOutput];
    [self.session addInput:self.input];

    //Output settings
    self.videoOutput.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    self.videoOutput.minFrameDuration = CMTimeMake(1, 15);
    
    //Should use something like this instead:
    //[self.device setActiveVideoMinFrameDuration: CMTimeMake(1, 15)];

    [self.videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;

    NSLog(@"Orientation: %d", [[UIDevice currentDevice] orientation]);
    NSLog(@"self.oriantation: %d", self.interfaceOrientation);
    if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    else if (self.interfaceOrientation  == UIDeviceOrientationPortrait) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    else if(self.interfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    else {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.preview.frame = self.view.bounds;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    [self imageFromSampleBuffer: sampleBuffer];
    
}

- (void)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    
    self.capturedImage = image;
    
}

-(void) stopImageStreaming
{
    [self.session stopRunning];
    [self.preview removeFromSuperlayer];
}

-(void)startImageStreaming
{
    [self setupImageStreaming];
    
    [self.session startRunning];
    
    self.readQRBtn.hidden = NO;
    self.textField1.hidden = NO;
    self.exitScan.hidden = YES;
}
@end
