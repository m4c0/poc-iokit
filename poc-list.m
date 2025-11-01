#pragma leco tool

@import Foundation;
@import IOKit.hid;

int main() {
  // VendorID=32905 ProductID=12
  NSDictionary * match = @{
    @kIOHIDVendorIDKey: @0x8089,
  };
  IOHIDManagerRef mgr = IOHIDManagerCreate(kCFAllocatorDefault, 0);
  IOHIDManagerOpen(mgr, 0);
  IOHIDManagerSetDeviceMatching(mgr, (CFDictionaryRef) match);

  for (id dev in (__bridge NSSet *)IOHIDManagerCopyDevices(mgr)) {
    NSLog(@"%@", dev);
  }

  IOHIDManagerClose(mgr, 0);
}
