#import "RawGnssPlugin.h"
#if __has_include(<raw_gnss/raw_gnss-Swift.h>)
#import <raw_gnss/raw_gnss-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "raw_gnss-Swift.h"
#endif

@implementation RawGnssPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRawGnssPlugin registerWithRegistrar:registrar];
}
@end
