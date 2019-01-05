

/**
 不用用户Token即可访问的接口
 */

#import "Catalog.h"
#import "AuthManager.h"
#import "Resource.h"
#import "Song.h"
#import "NSURLRequest+CreateURLRequest.h"

@interface Catalog()
//@property(nonatomic, strong)NSString *root;
@end

static Catalog* _instance;
@implementation Catalog

- (instancetype)init{
    if (self =[super init]) {
        _catalogPath = [self.rootPath stringByAppendingPathComponent:@"catalog"];
        NSString *storeFront = [AuthManager shareManager].storefront;
        _catalogPath= [_catalogPath stringByAppendingPathComponent:storeFront];
    }
    return self;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}

- (void)resources:(NSArray<NSString *> *)ids byType:(ResourceType)catalog callBack:(RequestCallBack)handle {
    NSString *component = [self pathComponentForType:catalog];
    NSString *path = [self.catalogPath stringByAppendingPathComponent:component];
    //拼接方式
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:ids.lastObject];
    }else{
        path = [path stringByAppendingString:@"?ids="];
        for (NSString* identifier in ids) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
        }
    }

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

- (void)relationship:(NSString *)identifier byType:(ResourceType)catalog forName:(NSString *)name callBack:(RequestCallBack)handle {
    NSString *component = [self pathComponentForType:catalog];
    NSString *path = [self.catalogPath stringByAppendingPathComponent:component];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

- (void)musicVideosByISRC:(NSArray<NSString *> *)ISRCs callBack:(RequestCallBack)handle {
    NSString *subPath = [self pathComponentForType:CatalogMusicVideos];
    NSString *path = [self.catalogPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}
- (void)songsByISRC:(NSArray<NSString *> *)ISRCs callBack:(RequestCallBack)handle {
    NSString *subPath = [self pathComponentForType:CatalogSongs];
    NSString *path = [self.catalogPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

- (void)chartsByType:(ChartsType)type callBack:(RequestCallBack)handle {
    NSString *path = [self.catalogPath stringByAppendingPathComponent:@"charts?types="];
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

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}


#pragma mark - helper
//不同的类型,返回不同的子路径
- (NSString*)pathComponentForType:(ResourceType)catalog {
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

- (void)songListWithResource:(Resource *)resource completion:(RequestCallBack)handle{
    NSURLRequest *request = [NSURLRequest createRequestWithHref:resource.href];
    [self dataTaskWithRequest:request handler:handle];
}

@end
