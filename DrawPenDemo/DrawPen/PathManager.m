//
//  PathManager.m
//  DrawPen
//
//  Created by lingmin on 13-7-1.
//  Copyright (c) 2013年 lingmin. All rights reserved.
//

#import "PathManager.h"

@interface PathManager ()

@property (nonatomic, retain) NSString * appDocumentRootPath;
@property (nonatomic, retain) NSString * filePath;

@end

@implementation PathManager

- (id)init{
    self = [super init];
    if (self) {
        self.appDocumentRootPath = nil;
        self.filePath = nil;
    }
    return self;
}

#pragma mark - saveFileInterface

+ (BOOL)buildPath:(NSString *)path
{
    return [[NSFileManager defaultManager]createDirectoryAtPath:path
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:NULL];
}

+ (BOOL)buildPathForFile:(NSString *)filePath
{
    return [PathManager buildPath:[filePath stringByDeletingLastPathComponent]];
}

+ (BOOL) deleteBuildPath:(NSString *)path
{
	return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (BOOL) buildPath:(NSString *)path
{
	return [PathManager buildPath:path];
}

- (BOOL) buildPathForFile:(NSString *)filePath
{
	return [PathManager buildPathForFile:filePath];
}

- (BOOL) deleteBuildPath:(NSString *)path
{
	return [PathManager deleteBuildPath:path];
}

#pragma mark - saveFilePath

+ (PathManager *) sharePathManager
{
    static PathManager * sharePathManager = nil;
    if(sharePathManager == nil){
        sharePathManager = [[PathManager alloc]init];
    }
    return sharePathManager;
}

- (NSString *) appDocumentRootPath
{
	if (_appDocumentRootPath == nil) {
		NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_appDocumentRootPath = ([paths count] > 0 ? [paths objectAtIndex:0] : nil) ;
	}
	return _appDocumentRootPath;
}

- (NSString *)filePath{
    if (_filePath == nil) {
        _filePath = [self.appDocumentRootPath stringByAppendingPathComponent:@"saveImage"];
    }
    return _filePath;
}

- (NSString *)namePath: (NSString *)name{
    NSString * attachment = nil;
	attachment = name;
    return [[self.filePath stringByAppendingPathComponent:@"cache"] stringByAppendingPathComponent:attachment];
}

@end