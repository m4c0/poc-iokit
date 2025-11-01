#pragma leco tool

@import Foundation;
@import IOKit.hid;

static inline void chk(IOReturn r) {
  switch (r) {
    case kIOReturnSuccess: return;
    case kIOReturnNotOpen: NSLog(@"Error: not open"); abort();
    case kIOReturnNotPermitted: NSLog(@"Error: not permitted"); abort();
  }
  NSLog(@"Error: %x %s", r, mach_error_string(r));
  abort();
}

int main() {
  // VendorID=32905 ProductID=12
  NSDictionary * match = @{
    @kIOHIDVendorIDKey: @0x8089,
    @kIOHIDPrimaryUsagePageKey: @0xFF00, // Vendor-specific
  };
  IOHIDManagerRef mgr = IOHIDManagerCreate(kCFAllocatorDefault, 0);
  IOHIDManagerOpen(mgr, 0);
  IOHIDManagerSetDeviceMatching(mgr, (CFDictionaryRef) match);

  IOHIDDeviceRef dev = (__bridge IOHIDDeviceRef) [(__bridge NSSet *)IOHIDManagerCopyDevices(mgr) anyObject];
  if (!dev) {
    NSLog(@"Could not find a suitable device");
    abort();
  }

  IOHIDManagerClose(mgr, 0);

  chk(IOHIDDeviceOpen(dev, kIOHIDOptionsTypeNone));

  NSLog(@"Report Desc: %@", IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDReportDescriptorKey)));
  NSLog(@"Usage Page: %@", IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDDeviceUsagePageKey)));
  NSLog(@"Usage: %@", IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDDeviceUsageKey)));
  NSLog(@"Usage Pairs: %@", IOHIDDeviceGetProperty(dev, CFSTR(kIOHIDDeviceUsagePairsKey)));

  IOHIDDeviceClose(dev, 0);
}
