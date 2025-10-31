@import Foundation;
@import IOKit.hid;

int main() {
  // VendorID=32905 ProductID=12
  NSDictionary * match = @{
    @kIOHIDVendorIDKey: @32905,
    @kIOHIDPrimaryUsagePageKey: @0xFF00, // Vendor-specific
  };

  IOHIDManagerRef mgr = IOHIDManagerCreate(kCFAllocatorDefault, 0);
  IOHIDManagerOpen(mgr, 0);
  IOHIDManagerSetDeviceMatching(mgr, (CFDictionaryRef) match);

  IOHIDDeviceRef dev = (__bridge IOHIDDeviceRef) [(__bridge NSSet *)IOHIDManagerCopyDevices(mgr) anyObject];
  if (!dev) {
    NSLog(@"Could not find a suitable device");
    return 1;
  }
  NSLog(@"%@", dev);

  unsigned char d1[64] = { 0x03 };
  IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 0, d1, sizeof(d1));
  NSLog(@"done");
}

