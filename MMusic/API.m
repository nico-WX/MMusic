

/**
 不用用户Token即可访问的接口
 */

#import "API.h"
#import "AuthorizationManager.h"

@interface API()
//@property(nonatomic, strong)NSString *root;
@end

static API* _instance;
@implementation API

-(instancetype)init{
    if (self =[super init]) {
        _library = [[Library alloc] init];

        self.rootPath = [self.rootPath stringByAppendingPathComponent:@"catalog"];
        NSString *storeFront = [AuthorizationManager shareManager].storefront;
        self.rootPath = [self.rootPath stringByAppendingPathComponent:storeFront];
    }
    return self;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}


-(void)resources:(NSArray<NSString *> *)ids byType:(Catalog)catalog callBack:(RequestCallBack)handle{
    NSString *subPath = [self subPathForType:catalog];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:ids.lastObject];
    }else{
        path = [path stringByAppendingString:@"?ids="];
        for (NSString* identifier in ids) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
        }
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)relationship:(NSString *)identifier byType:(Catalog)catalog forName:(NSString *)name callBack:(RequestCallBack)handle{
    NSString *subPath = [self subPathForType:catalog];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)musicVideosByISRC:(NSArray<NSString *> *)ISRCs callBack:(RequestCallBack)handle{
    NSString *subPath = [self subPathForType:CatalogMusicVideos];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)songsByISRC:(NSArray<NSString *> *)ISRCs callBack:(RequestCallBack)handle{
    NSString *subPath = [self subPathForType:CatalogSongs];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)chartsByType:(ChartsType)type callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"charts?types="];
    switch (type) {
        case ChartsAlbums:
            path = [path stringByAppendingString:@"albums"];
            break;
        case ChartsPlaylists:
            path = [path stringByAppendingString:@"playlists"];
            break;
        case ChartsSongs:
            path = [path stringByAppendingString:@"songs"];
            break;
        case ChartsMusicVideos:
            path = [path stringByAppendingString:@"music-videos"];
            break;
        case ChartsAll:
            path = [path stringByAppendingString:@"songs,albums,playlists,music-videos"];
            break;
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)searchForTerm:(NSString *)term callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:term];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)searchHintsForTerm:(NSString *)term callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search"];
    path = [path stringByAppendingPathComponent:@"hints?term="];
    path = [path stringByAppendingString:term];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];


}


#pragma mark - helper
//不同的类型,返回不同的子路径
-(NSString*)subPathForType:(Catalog) catalog{
    NSString *subPath = @"";
    switch (catalog) {
        case CatalogAlbums:
            subPath = @"albums";
            break;
        case CatalogArtists:
            subPath = @"artists";
            break;
        case CatalogActivities:
            subPath = @"activities";
            break;
        case CatalogAppleCurators:
            subPath = @"apple-curators";
            break;
        case CatalogCurators:
            subPath = @"curators";
            break;
        case CatalogPlaylists:
            subPath = @"playlists";
            break;
        case CatalogMusicVideos:
            subPath = @"music-videos";
            break;
        case CatalogSongs:
            subPath = @"songs";
            break;
        case CatalogStations:
            subPath = @"stations";
            break;
    }
    return subPath;
}



@end
