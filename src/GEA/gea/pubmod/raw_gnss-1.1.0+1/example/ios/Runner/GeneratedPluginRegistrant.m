//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<raw_gnss/RawGnssPlugin.h>)
#import <raw_gnss/RawGnssPlugin.h>
#else
@import raw_gnss;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [RawGnssPlugin registerWithRegistrar:[registry registrarForPlugin:@"RawGnssPlugin"]];
}

@end
