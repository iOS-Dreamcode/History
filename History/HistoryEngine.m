//
//  HistoryEngine.m
//  History
//
//  Created by Srikanth Sombhatla on 22/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define OFFLINE_TEST

#import "DCRSSParser.h"
#import "DCXMLElement.h"
#import "DCRSSManager.h"
#import "HistoryEngine.h"
#import "HistoryConstants.h"

NSString* const kHistoryTag = @"com.dc.history";
NSString* const HistoryEngineUpdateAvailableNotification = @"com.dc.history.todayinfoavailable";

@interface HistoryEngine() {
    NSDictionary* _info;
    DCRSSManager* _rssMgr;
    BOOL _invalidateFavsCache;
} 

- (void)handleUpdateAvailable:(NSNotification*) notification;
- (NSString*) fileNameForTitle:(NSString*)title;
- (NSString*) favoritesPath;
- (NSArray*) favFileNames;

@property (nonatomic,readwrite,retain) NSMutableArray* favs;
@property (nonatomic,readwrite,retain) NSArray* favFileNames;
@end

@implementation HistoryEngine

@synthesize favFileNames = _favFileNames;
@synthesize favs;
// pimpl

- (void)handleUpdateAvailable:(NSNotification*) notification {
    if(_info) {
        [_info release];
        _info = nil;
    }
    NSDictionary* respUserInfo = notification.userInfo;
    NSDictionary* userInfo = nil;
    // Handle error if any
    if([respUserInfo objectForKey:DCRSSManagerErrorKey]) {
        NSError* err = (NSError*)[respUserInfo objectForKey:DCRSSManagerErrorKey];
        NSLog(@"%s failed with error %@",__PRETTY_FUNCTION__, err.localizedDescription);
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:err.localizedDescription,HISTORY_ERRORSTRING, nil];
    } else {
        DCRSSParser* parser = (DCRSSParser*)[respUserInfo objectForKey:DCRSSManagerParserKey];
        if(!parser) {
            NSLog(@"%s nil parser",__PRETTY_FUNCTION__);
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to load", nil),
                                                                  HISTORY_ERRORSTRING,nil];
        }
        
        NSString* title = [parser itemContentWithName:@"title" atIndex:0];
        NSString* description = [parser itemContentWithName:@"description" atIndex:0];
        _info = [[NSDictionary dictionaryWithObjectsAndKeys:
                 title,HISTORY_TITLE,
                 description,HISTORY_DESCRIPTION,
                 nil] retain];
        userInfo = _info;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HistoryEngineUpdateAvailableNotification
                                                        object:nil userInfo:userInfo];
}

- (NSString*) fileNameForTitle:(NSString*)title {
    return [NSString stringWithFormat:@"%u.xml",[title hash]];
}

- (NSString*) favoritesPath {
    NSString* favsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    favsPath = [favsPath stringByAppendingPathComponent:HISTORY_FAVORITES_FOLDER];
    return favsPath;
}

- (NSArray*) favFileNames {
    if(_invalidateFavsCache) {
        NSFileManager* fm = [NSFileManager defaultManager];
        self.favFileNames = [fm contentsOfDirectoryAtPath:[self favoritesPath] error:nil];
    }
    return _favFileNames;
}

// pimpl

+ (id) sharedEngine {
    static HistoryEngine *e = nil;
    
    @synchronized(self) {
        if (e == nil)
            e = [[HistoryEngine alloc] init];
    }
    return e;
}

- (id) init {
    self = [super init];
    if(self) {
        _info = nil;
        _invalidateFavsCache = true;
        _rssMgr = [[DCRSSManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdateAvailable:) 
                                                     name:DCRSSManagerUpdateAvailableNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DCRSSManagerUpdateAvailableNotification object:nil];
    [_rssMgr release];
    self.favs = nil;
    self.favFileNames = nil;
    [super dealloc];
}

- (void)fetchTodayInfo {
#ifdef OFFLINE_TEST
    NSString* path = [[NSBundle mainBundle] pathForResource:@"testrss" ofType:@"xml"];
    NSData* offlinedata = [NSData dataWithContentsOfFile:path];
    [_rssMgr fetchAsync:offlinedata withTag:kHistoryTag];
#else
    [_rssMgr fetchAsync:[NSURL URLWithString:@"http://www.history.com/this-day-in-history/rss!"] withTag:kHistoryTag];
#endif
}

- (BOOL)saveAsFavorite:(NSDictionary*)info {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    BOOL status = true;
    NSString* favsPath = [self favoritesPath];
    // Check if favorites folder exits
    NSError* err = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSLog(@"%s %@",__PRETTY_FUNCTION__,[fm currentDirectoryPath]);
    if(![fm fileExistsAtPath:favsPath]) {
        [fm createDirectoryAtPath:favsPath withIntermediateDirectories:NO attributes:nil error:&err];
        if(err) {
            NSLog(@"%s Cannot create folder at path %@",__PRETTY_FUNCTION__,favsPath);
            status = false;
        }
    }
    
    if(!err) {
        NSString* name = [self fileNameForTitle:[info objectForKey:HISTORY_TITLE]];
        NSString* filePath = [favsPath stringByAppendingPathComponent:name];
        if(![fm fileExistsAtPath:filePath]) {
            status = [_info writeToFile:filePath atomically:YES];
            _invalidateFavsCache = true;
        }
    }
    
    return status;
}

- (NSArray*) favoriteTitles {
    NSMutableArray* titles = [NSMutableArray array];
    for(NSDictionary* info in [self favorites])
        [titles addObject:[info objectForKey:HISTORY_TITLE]];
    return titles;
}

- (NSInteger) favoritesCount {
    NSLog(@"%s %d",__PRETTY_FUNCTION__, [[self favorites] count]);
    return [[self favorites] count];
}

- (NSArray*) favorites {
    if(_invalidateFavsCache) {
        NSArray* favFiles = [self favFileNames];
        if(favFiles) {
            self.favs = [[[NSMutableArray alloc] init] autorelease];
            for(NSString* favFile in favFiles) {
                NSString* filePath = [[self favoritesPath] stringByAppendingPathComponent:favFile];
                NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:filePath];
                [self.favs addObject:[info retain]];
                [info release];
            }
            _invalidateFavsCache = false;
        }
    }
    return self.favs;
}

- (NSDictionary*)favoriteAtIndex:(NSInteger)index {
    if((index >=0) && (index < [self favoritesCount])) {
        NSDictionary* info = [[self favorites] objectAtIndex:index];
        return info;
    } else {
        return nil;
    }
}

- (BOOL)removeFavoriteAtIndex:(NSInteger)index {
    if((index >=0) && (index < [self favoritesCount])) {
        NSString* path = [self favoritesPath];
        path = [path stringByAppendingPathComponent:[self.favFileNames objectAtIndex:index]];
        NSFileManager* fm = [NSFileManager defaultManager];
        if([fm removeItemAtPath:path error:nil]) {
            [self.favs removeObjectAtIndex:index];
            _invalidateFavsCache = true;
            return true;
        } else {
            NSLog(@"%s unable to remove file at index %d %@",__PRETTY_FUNCTION__,index,path);
            return false;
        }
    } else {
        return false;
    }
}

- (BOOL)removeAllFavorites {
    BOOL result = true;
    for(int i=0;i<[self favoritesCount];++i) {
        if(![self removeFavoriteAtIndex:i]) {
            result = false;
            break;
        }
    }
    return result;
}
@end
