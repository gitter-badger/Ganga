//
//  NetEaseCloudMusicAPI.m
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import "AFNetworking.h"
#import "NetEaseCloudMusicAPI.h"

static NSString * const kNetEaseCloudMusicBaseURL = @"http://music.163.com";

@interface NetEaseCloudMusicAPI ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;
@end

@implementation NetEaseCloudMusicAPI

+ (instancetype)sharedClient
{
    static NetEaseCloudMusicAPI *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         _sharedClient = [[NetEaseCloudMusicAPI alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:kNetEaseCloudMusicBaseURL];
        self.sessionManager = [AFHTTPSessionManager manager];
        self.sessionManager.session.configuration.HTTPMaximumConnectionsPerHost = 1;
        
        [self initRequestOperationManagerWithBaseURL:baseURL];
    }
    
    return self;
}

- (void)initRequestOperationManagerWithBaseURL:(NSURL *)baseURL
{
    self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    [self.requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self.requestManager.requestSerializer setValue:@"appver=2.0.2" forHTTPHeaderField:@"Cookie"];
    [self.requestManager.requestSerializer setValue:@"http://music.163.com" forHTTPHeaderField:@"Referer"];
    
    NSMutableSet *acceptabeContentTypes = [self.requestManager.responseSerializer.acceptableContentTypes mutableCopy];
    [acceptabeContentTypes addObject:@"text/plain"];
    [self.requestManager.responseSerializer setAcceptableContentTypes:acceptabeContentTypes];
}

- (void)getSongDetailByID:(NSString *)songID
                  success:(void (^)(NSDictionary *songInfo))success
                  failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/api/song/detail?ids=[%@]", songID];
    [self.requestManager GET:path
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *data = (NSDictionary *)responseObject;
        NSDictionary *song = [data[@"songs"] firstObject];
        NSDictionary *album = song[@"album"];
        NSDictionary *artist = [song[@"artists"] firstObject];
        NSString *albumName = album[@"name"];
        NSString *songName = song[@"name"];
        NSString *artistName = artist[@"name"];
        NSString *mp3URL = song[@"mp3Url"];
        
        NSDictionary *songInfo = @{@"name": songName, @"artist": artistName, @"album": albumName, @"url": mp3URL};
        
        if (success) {
            success(songInfo);
        }
    }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
    }];
}

- (void)getAlbumDetailByID:(NSString *)albumID
                   success:(void (^)(NSDictionary *songInfo))success
                   failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/api/album/%@/", albumID];
    
    [self.requestManager GET:path
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *data = (NSDictionary *)responseObject[@"album"];
         NSArray *songs = data[@"songs"];
         
         for (NSDictionary *song in songs) {
             NSDictionary *album = song[@"album"];
             NSDictionary *artist = [song[@"artists"] firstObject];
             NSString *albumName = album[@"name"];
             NSString *songName = song[@"name"];
             NSString *artistName = artist[@"name"];
             NSString *mp3URL = song[@"mp3Url"];
             
             NSDictionary *songInfo = @{@"name": songName, @"artist": artistName, @"album": albumName, @"url": mp3URL};
             
             if (success) {
                 success(songInfo);
             }
         }
     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}

- (void)getPlaylistDetailByID:(NSString *)playlistID
                      success:(void (^)(NSDictionary *songInfo))success
                      failure:(void (^)(NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"/api/playlist/detail?id=%@", playlistID];
    
    [self.requestManager GET:path
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *data = (NSDictionary *)responseObject[@"result"];
         NSArray *songs = data[@"tracks"];
         
         for (NSDictionary *song in songs) {
             NSDictionary *album = song[@"album"];
             NSDictionary *artist = [song[@"artists"] firstObject];
             NSString *albumName = album[@"name"];
             NSString *songName = song[@"name"];
             NSString *artistName = artist[@"name"];
             NSString *mp3URL = song[@"mp3Url"];
             
             NSDictionary *songInfo = @{@"name": songName, @"artist": artistName, @"album": albumName, @"url": mp3URL};
             
             if (success) {
                 success(songInfo);
             }
         }
     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
     }];
}

- (void)downloadSongByID:(NSString *)songID
                 success:(void (^)(NSDictionary *songInfo))success
                 failure:(void (^)(NSError *error))failure
{
    __weak typeof(self) weakSelf = self;
    
    [self getSongDetailByID:songID
                    success:^(NSDictionary *songInfo)
    {
        [weakSelf downloadSongBySongInfo:songInfo success:^(void) {
            if (success) {
                success(songInfo);
            }
        } failure:^(NSError *error) {
            
        }];
    }
                    failure:nil];
}

- (void)downloadSongBySongInfo:(NSDictionary *)songInfo
                       success:(void (^)(void))success
                       failure:(void (^)(NSError *error))failure
{
    NSString *artist = songInfo[@"artist"];
    NSString *album = songInfo[@"album"];
    NSString *name = songInfo[@"name"];
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
    NSString *musicPath = [NSString stringWithFormat:@"%@", directories.lastObject];
    NSString *destinationFolder = [NSString stringWithFormat:@"%@/Music/%@/%@", musicPath, artist, album];
    NSString *destination = [NSString stringWithFormat:@"%@/%@.mp3", destinationFolder, name];
    
    BOOL isDir = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destination isDirectory:&isDir] && !isDir) {
        return;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFolder isDirectory:&isDir] || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    [self downLoadSongByURL:songInfo[@"url"]
                destination:destination
                    success:^
     {
         if (success) {
             success();
         }
     }
                    failure:^(NSError *error)
     {
         
     }];
}

- (void)downloadAlbumByID:(NSString *)albumID
                  success:(void (^)(NSDictionary *songInfo))success
                  failure:(void (^)(NSError *error))failure
{
    __weak typeof(self) weakSelf = self;
    
    [self getAlbumDetailByID:albumID success:^(NSDictionary *songInfo) {
        [weakSelf downloadSongBySongInfo:songInfo success:^{
            if (success) {
                success(songInfo);
            }
        } failure:^(NSError *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)downloadPlaylistByID:(NSString *)playlistID
                     success:(void (^)(NSDictionary *songInfo))success
                     failure:(void (^)(NSError *error))failure
{
    __weak typeof(self) weakSelf = self;
    
    [self getPlaylistDetailByID:playlistID
                        success:^(NSDictionary *songInfo)
    {
        [weakSelf downloadSongBySongInfo:songInfo
                                 success:^
        {
            if (success) {
                success(songInfo);
            }
        }
                                 failure:^(NSError *error)
        {
            
        }];
    }
                        failure:^(NSError *error)
    {
        
    }];
}

- (void)downLoadSongByURL:(NSString *)url
              destination:(NSString *)destination
                  success:(void (^)(void))success
                  failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request
                                                                         progress:nil
                                                                      destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                      {
                                          NSURL *url = [NSURL fileURLWithPath:destination];;
                                          return url;
                                      }
                                                                completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                      {
                                          if (success) {
                                              success();
                                          }
                                      }];
    
    [task resume];
}
@end
