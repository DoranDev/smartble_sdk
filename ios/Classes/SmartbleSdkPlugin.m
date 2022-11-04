#import "SmartbleSdkPlugin.h"
#if __has_include(<smartble_sdk/smartble_sdk-Swift.h>)
#import <smartble_sdk/smartble_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "smartble_sdk-Swift.h"
#endif

@implementation SmartbleSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmartbleSdkPlugin registerWithRegistrar:registrar];
}
@end
