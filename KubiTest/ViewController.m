//
//  ViewController.m
//  KubiTest
//
//  Created by Victor Nouvellet on 19/01/2017.
//  Copyright © 2017 Victor Nouvellet Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nullable, nonatomic, weak) RRDeviceSDK* sdk;
@property BOOL isScanning;
@property (nonatomic, strong) UIAlertController* connectionAlert;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanIndicator;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIView *connectionView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.sdk = [RRDeviceSDK deviceSdk];
    self.sdk.delegate = self;
    [self updateControlButtons];
    
    [self startScanning];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    [self updateControlButtons];
    [self startScanning];
}

- (IBAction)disconnectButtonPressed:(id)sender {
    [self.sdk disconnectDevice];
}

- (IBAction)shareButtonPressed:(id)sender {
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    if (kubi != nil) {
        // shareControlWithAppData method seems to be broken
//        [self.sdk shareControlWithAppData:nil success:^{
//            NSLog(@"SUCCESS");
//        } fail:^(NSError * _Nullable error) {
//            NSLog(@"FAIL");
//        }];
        NSLog(@"Identifier : %@ \n Type : %@", kubi.identifier, kubi.type);
        
    }
}

-(void)deviceSDK:(RRDeviceSDK *)deviceSDK didChangeConnectionState:(RRDeviceConnectionState)connectionState {
    NSLog(@"device SDK didChangeConnectionState");
    [self updateControlButtons];
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    switch (connectionState) {
        case RRDeviceConnectionStateConnected:
            [self.connectionAlert dismissViewControllerAnimated:true completion:nil];
            
            [kubi setPanEnabled:true error:nil];
            [kubi setTiltEnabled:true error:nil];
            
            break;
        case RRDeviceConnectionStateConnecting:
            [self.connectionAlert dismissViewControllerAnimated:true completion:nil];
            break;
        case RRDeviceConnectionStateDisconnected:
            break;
        case RRDeviceConnectionStateConnectionLost:
            break;
            
        default:
            break;
    }
}

-(void)deviceSDK:(RRDeviceSDK *)deviceSDK didUpdateDeviceList:(NSArray *)deviceList {
    NSLog(@"device SDK didUpdateDeviceList");
    
    if (self.sdk.deviceConnectionState == RRDeviceConnectionStateConnecting || self.sdk.deviceConnectionState == RRDeviceConnectionStateConnected) {
        [self stopScanning];
        return;
    }
    
    self.connectionAlert = [UIAlertController alertControllerWithTitle:@"Choose your device"
                                                                       message:@"Here is the list of available devices"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (RRDevice* device in deviceList) {
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:device.name style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self stopScanning];
                                                                  [self.sdk connectDevice:device];
                                                              }];
        [self.connectionAlert addAction:defaultAction];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Wait..." style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                          }];
    [self.connectionAlert addAction:defaultAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Stop scanning" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              [self stopScanning];
                                                          }];
    [self.connectionAlert addAction:cancelAction];
    
    
    if (!self.connectionAlert.isBeingPresented && self.isScanning == true) {
        [self presentViewController:self.connectionAlert animated:YES completion:nil];
    }
}

#pragma mark - Scan functions

-(void)startScanning {
    self.isScanning = true;
    self.scanButton.enabled = false;
    [self.scanIndicator startAnimating];
    [self.sdk startScan];
}

-(void)stopScanning {
    [self.sdk endScan];
    [self.scanIndicator stopAnimating];
    self.scanButton.enabled = true;
    self.isScanning = false;
}

#pragma mark - Remote control

-(void)updateControlButtons {
    if (self.sdk.deviceConnectionState == RRDeviceConnectionStateConnected) {
        //Activate button visibility with animation
        [UIView animateWithDuration:1.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             //What to animate
                             self.topConstraint.constant = 20;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             //What to do after completion
                         }];
        self.controlView.hidden = false;
    }   else  {
        //Hide control buttons
        [UIView animateWithDuration:1.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             //What to animate
                             self.topConstraint.constant = 250;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             //What to do after completion
                         }];
        self.controlView.hidden = true;
    }
}

- (IBAction)tiltUpButtonPressed:(id)sender {
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    [kubi incrementalMoveWithPanDelta:[NSNumber numberWithDouble:0]
                           atPanSpeed:[NSNumber numberWithDouble:0]
                         andTiltDelta:[NSNumber numberWithDouble:20]
                          atTiltSpeed:[NSNumber numberWithDouble:150]
                                error:nil];
}

- (IBAction)tiltDownButtonPressed:(id)sender {
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    [kubi incrementalMoveWithPanDelta:[NSNumber numberWithDouble:0]
                           atPanSpeed:[NSNumber numberWithDouble:0]
                         andTiltDelta:[NSNumber numberWithDouble:-20]
                          atTiltSpeed:[NSNumber numberWithDouble:150]
                                error:nil];
}

- (IBAction)panLeftButtonPressed:(id)sender {
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    [kubi incrementalMoveWithPanDelta:[NSNumber numberWithDouble:-20]
                           atPanSpeed:[NSNumber numberWithDouble:150]
                         andTiltDelta:[NSNumber numberWithDouble:0]
                          atTiltSpeed:[NSNumber numberWithDouble:0]
                                error:nil];
}

- (IBAction)panRightButtonPressed:(id)sender {
    RRKubi* kubi = (RRKubi*)self.sdk.connectedDevice;
    [kubi incrementalMoveWithPanDelta:[NSNumber numberWithDouble:20]
                           atPanSpeed:[NSNumber numberWithDouble:150]
                         andTiltDelta:[NSNumber numberWithDouble:0]
                          atTiltSpeed:[NSNumber numberWithDouble:0]
                                error:nil];
}


@end
