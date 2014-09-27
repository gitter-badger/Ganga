//
//  NetEaseCloudMusicAPI.h
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetEaseCloudMusicAPI : NSObject
+ (instancetype)sharedClient;

- (void)downloadSongByID:(NSString *)songID
                 success:(void (^)(NSDictionary *songInfo))success
                 failure:(void (^)(NSError *error))failure;
@end
