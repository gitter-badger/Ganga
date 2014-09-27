//
//  AppDelegate.m
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "GANDownloadManager.h"

@interface AppDelegate () <NSUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[GANDownloadManager sharedManager] downloadMusicFromURL:url];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}
@end
