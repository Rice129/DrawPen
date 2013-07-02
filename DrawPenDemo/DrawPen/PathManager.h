//
//  PathManager.h
//  DrawPen
//
//  Created by lingmin on 13-7-1.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathManager : NSObject

+ (PathManager *) sharePathManager;

- (NSString *)namePath: (NSString *)name;

- (BOOL) buildPathForFile:(NSString *)filePath;

- (BOOL) deleteBuildPath:(NSString *)path;

@end
