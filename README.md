# GoogleMapsExtension

GoogleMapsExtension is a framework writting in Objective-C to provide extended functionality for the GoogleMaps iOS SDK. The provides an interface for performing [Text Search](https://developers.google.com/maps/documentation/javascript/places#TextSearchRequests) requests which aren't supported by the GoogleMaps iOS SDK. However, [Nearby Search](https://developers.google.com/maps/documentation/javascript/places#place_search_requests), and [Radar Search](https://developers.google.com/maps/documentation/javascript/places#radar_search_requests) will be added if interest is shown.

## Usage

The only dependency is the Google Maps iOS SDK. This can be added using the existing cocoapods Podfile by navigating to the project root directory and typing: 
```
pod install
```

In order to use the text search functionality an API key must be provided. This can be done by adding the following to the AppDelegate:
```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [GMEServices provideAPIKey:GoogleMapsExtensionAPIKey];
}
```
**Note:**
**In order to create your API key navigate to the [Credentials](https://console.developers.google.com/apis/credentials) section of the [Google API Managager](https://console.developers.google.com/) and create a new Browser key.** _**An iOS key will NOT work.**_ **The [Google Places API Web Service](https://console.developers.google.com/apis/api/places_backend/) must also be enabled from the Google API Manager.**

```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [GMEServices provideAPIKey:GoogleMapsExtensionAPIKey];
}
```

Once the API key has been provided GMETextSearchFetcher can be used:

```Objective-C
@interface SearchController : NSObject <GMETextSearchFetcherDelegate>
@property (nonatomic, strong) GMETextSearchFetcher *fetcher;
@end

...

@implementation SearchController

- (id)init {
    if (self = [super init]) {
        // For documentation on filtering GMETextSearchFetcher see GMETextSearchFilter.h
        self.fetcher = [[GMETextSearchFetcher alloc] initWithFilter:nil];
        self.fetcher.delegate = self;
    }
    return self;
}

- (void)_textDidChange:(NSString *)text {
    [self.fetcher sourceTextHasChanged:text];
}

- (void)didSearchWithPlaces:(NSArray <GMSPlace *>*)places {
    // Search found places
}

- (void)didFailSearchWithError:(NSError *)error {
    // Search failed
}

@end
```

## Motivation

This project was created due to lack of functionality of the GoogleMaps iOS SDK. The GoogleMaps Javascript API has signficantly more functionality which should be available on iOS but isn't. This framework is designed to reduce the gap between the iOS and Javascript APIs.

## API Reference
Documentation can be found in public header files.

## License

This project is available for use under the MIT License (MIT) which can be viewed in its entirety in the LICENCE file.
