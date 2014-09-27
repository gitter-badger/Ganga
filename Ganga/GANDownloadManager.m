//
//  GANDownloadManager.m
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import "GANDownloadManager.h"
#import "NetEaseCloudMusicAPI.h"

typedef NS_ENUM(NSUInteger, GANDownloadType) {
    GANDownloadTypeUnknow = 0,
    GANDownloadTypeSong,
    GANDownloadTypeAlbum,
    GANDownloadTypePlaylist
};

@implementation GANDownloadManager

+ (instancetype)sharedManager
{
    static GANDownloadManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[GANDownloadManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)downloadMusicFromURL:(NSString *)url
{
    GANDownloadType downloadType = [self downloadTypeFromURL:url];
    
    switch (downloadType) {
        case GANDownloadTypeSong:
            [self downloadSongFromURL:url];
            break;
        case GANDownloadTypeAlbum:
            [self downloadAlbumFromURL:url];
            break;
        case GANDownloadTypePlaylist:
            [self downloadPlaylistFromURL:url];
            break;
        default:
            break;
    }
}

- (NSString *)getIDFromURL:(NSString *)url
{
    NSRange range = [url rangeOfString:@"id="];
    NSString *idFromURL = [url substringFromIndex:(range.location + range.length)];
    
    return idFromURL;
}

- (GANDownloadType)downloadTypeFromURL:(NSString *)url
{
    if ([url rangeOfString:@"song?id="].location != NSNotFound) {
        return GANDownloadTypeSong;
    } else if ([url rangeOfString:@"album?id"].location != NSNotFound) {
        return GANDownloadTypeAlbum;
    } else if ([url rangeOfString:@"playlist?id"].location != NSNotFound) {
        return GANDownloadTypePlaylist;
    }
    
    return GANDownloadTypeUnknow;
}

- (void)downloadSongFromURL:(NSString *)url
{
    __weak typeof(self) weakSelf = self;
    NSString *songID = [self getIDFromURL:url];
    
    [[NetEaseCloudMusicAPI sharedClient] downloadSongByID:songID
                                                  success:^(NSDictionary *songInfo)
     {
         [weakSelf deliverUserNotificationForSong:songInfo];
     }
                                                  failure:^(NSError *error)
     {
         
     }];
}

- (void)downloadAlbumFromURL:(NSString *)url
{
    __weak typeof(self) weakSelf = self;
    NSString *albumID = [self getIDFromURL:url];
    
    [[NetEaseCloudMusicAPI sharedClient] downloadAlbumByID:albumID
                                                   success:^(NSDictionary *songInfo)
    {
        [weakSelf deliverUserNotificationForSong:songInfo];
    }
                                                   failure:^(NSError *error)
    {
        
    }];
}

- (void)downloadPlaylistFromURL:(NSString *)url
{
    __weak typeof(self) weakSelf = self;
    NSString *playListID = [self getIDFromURL:url];
    
    [[NetEaseCloudMusicAPI sharedClient] downloadPlaylistByID:playListID
                                                      success:^(NSDictionary *songInfo)
    {
        [weakSelf deliverUserNotificationForSong:songInfo];
    }
                                                      failure:^(NSError *error)
    {
        
    }];
}

- (void)deliverUserNotificationForSong:(NSDictionary *)songInfo
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = songInfo[@"name"];
    notification.subtitle = songInfo[@"album"];
    notification.deliveryDate = [NSDate date];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
}
@end
