//
//  GANDownloadManager.h
//  Ganga
//
//  Created by im61 on 14/9/27.
//  Copyright (c) 2014年 6133Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GANDownloadManager : NSObject

+ (instancetype)sharedManager;
- (void)downloadMusicFromURL:(NSString *)url;
@end
