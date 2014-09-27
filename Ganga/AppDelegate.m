//
//  AppDelegate.m
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "NetEaseCloudMusicAPI.h"

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

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *url = [[[event paramDescriptorForKeyword:keyDirectObject] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [url rangeOfString:@"id="];
    NSString *songID = [url substringFromIndex:(range.location + range.length)];
    
    [[NetEaseCloudMusicAPI sharedClient] downloadSongByID:songID
                                                  success:^(NSDictionary *songInfo)
    {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = songInfo[@"name"];
        notification.subtitle = songInfo[@"album"];
        notification.deliveryDate = [NSDate date];
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    }
                                                  failure:^(NSError *error)
    {
        
    }];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}
@end
