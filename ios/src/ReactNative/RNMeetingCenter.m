//
//  JoinMeetingUtils.m
//  MobileRTCSample
//
//  Created by Phu on 9/14/20.
//  Copyright © 2020 Zoom Video Communications, Inc. All rights reserved.
//

#import "RNMeetingCenter.h"
#import <MobileRTC/MobileRTC.h>
#import "SDKStartJoinMeetingPresenter.h"
#import "RNZoomView.h"
#import "SDKAuthPresenter.h"
#import "SDKInitPresenter.h"
#import "SDKAudioPresenter.h"
#import "SDKVideoPresenter.h"
#import "SDKActionPresenter.h"

@interface RNMeetingCenter()

@property (strong, nonatomic) SDKInitPresenter             *setUpPresenter;
@property (strong, nonatomic) SDKAuthPresenter             *authPresenter;
@property (strong, nonatomic) SDKStartJoinMeetingPresenter *presenter;
@property (strong, nonatomic) SDKAudioPresenter            *audioPresenter;
@property (strong, nonatomic) SDKVideoPresenter            *videoPresenter;
@property (strong, nonatomic) SDKActionPresenter           *actionPresenter;

@property (retain, nonatomic) NSString *pendingJoinMeetingNumber;
@property (retain, nonatomic) NSString *pendingJoinMeetingPassword;

@end

@implementation RNMeetingCenter

+ (instancetype)shared
{
    static RNMeetingCenter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RNMeetingCenter alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
- (void) setClientInfo:(NSDictionary *) clientInfo {
    if (!self.zoomClientInfo) {
        self.zoomClientInfo = [[NSDictionary alloc] initWithDictionary:clientInfo];
        NSString *domain = self.zoomClientInfo[@"domain"] ?: @"";
        NSString *clientKey = self.zoomClientInfo[@"clientKey"] ?: @"";
        NSString *clientSecret = self.zoomClientInfo[@"clientSecret"] ?: @"";
        
        [self.setUpPresenter SDKInit:domain];
        [self.authPresenter SDKAuthWithClientKey:clientKey clientSecret:clientSecret];
    }
}
- (BOOL) isEnableRNMeetingView {
    return YES;
}
- (SDKInitPresenter *)setUpPresenter
{
    if (!_setUpPresenter)
    {
        _setUpPresenter = [[SDKInitPresenter alloc] init];
    }
    
    return _setUpPresenter;
}
- (SDKAuthPresenter *)authPresenter
{
    if (!_authPresenter)
    {
        _authPresenter = [[SDKAuthPresenter alloc] init];
    }
    
    return _authPresenter;
}
- (SDKStartJoinMeetingPresenter *)presenter
{
    if (!_presenter)
    {
        _presenter = [[SDKStartJoinMeetingPresenter alloc] init];
    }
    
    return _presenter;
}
- (SDKAudioPresenter *)audioPresenter
{
    if (!_audioPresenter)
    {
        _audioPresenter = [[SDKAudioPresenter alloc] init];
    }
    
    return _audioPresenter;
}

- (SDKVideoPresenter *)videoPresenter
{
    if (!_videoPresenter)
    {
        _videoPresenter = [[SDKVideoPresenter alloc] init];
    }
    
    return _videoPresenter;
}

- (SDKActionPresenter *)actionPresenter
{
    if (!_actionPresenter)
    {
        _actionPresenter = [[SDKActionPresenter alloc] init];
    }
    
    return _actionPresenter;
}

- (void) joinMeeting:(NSDictionary *) meetingInfo {
    if (self.currentZoomView) {
        [self.currentZoomView setZoomInfo:meetingInfo];
    }
}
- (void)joinMeeting:(NSString*)meetingNo withPassword:(NSString*)pwd rnZoomView:(id)rnZoomView
{
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        // Phunv: Bat tinh nang enableCustomMeeting
        [[MobileRTC sharedRTC] getMeetingSettings].enableCustomMeeting = YES;
        self.pendingJoinMeetingNumber = nil;
        self.pendingJoinMeetingPassword = nil;
        [self.presenter joinMeeting:meetingNo withPassword:pwd rnZoomView:rnZoomView];
    }
    else {
        // Phunv: Trong TH chua khoi tao xong meeting service => Luu vao bien pending de cho khoi tao xong
        self.pendingJoinMeetingNumber = meetingNo;
        self.pendingJoinMeetingPassword = pwd;
        self.presenter.rnZoomView = rnZoomView;
    }
}
- (void) checkPendingJoinMeetingAfterAuth {
    if (self.pendingJoinMeetingNumber) {
        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            // Phunv: Bat tinh nang enableCustomMeeting
            [[MobileRTC sharedRTC] getMeetingSettings].enableCustomMeeting = YES;
            [self.presenter joinMeeting:self.pendingJoinMeetingNumber withPassword:self.pendingJoinMeetingPassword rnZoomView:self.presenter.rnZoomView];
            self.pendingJoinMeetingNumber = nil;
            self.pendingJoinMeetingPassword = nil;
        }
    }
}
- (void) leaveCurrentMeeting {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (!ms) return;
    [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
}
- (void) onOffMyAudio {
    [self.audioPresenter muteMyAudio];
}
- (void) onOffMyVideo {
    [self.videoPresenter muteMyVideo];
}
- (void) switchMyCamera {
    [self.videoPresenter switchMyCamera];
}
- (NSArray *) getParticipants {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    return [ms getInMeetingUserList];
}
@end


