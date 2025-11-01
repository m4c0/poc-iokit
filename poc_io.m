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

static void callback(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength) {
  NSLog(@"Report ID %u -- %hhx %hhx %hhx %hhx %hhx %hhx %hhx %hhx"
      " %hhx %hhx %hhx %hhx %hhx %hhx %hhx %hhx"
      " %hhx %hhx %hhx %hhx %hhx %hhx %hhx %hhx"
      " %hhx %hhx %hhx %hhx %hhx %hhx %hhx %hhx", reportID,
      report[0], report[1], report[2], report[3], report[4], report[5], report[6], report[7],
      report[8], report[9], report[10], report[11], report[12], report[13], report[14], report[15],
      report[16], report[17], report[18], report[19], report[20], report[21], report[22], report[23],
      report[24], report[25], report[26], report[27], report[28], report[29], report[30], report[31]
      );
}

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

  IOHIDDeviceScheduleWithRunLoop(dev, CFRunLoopGetMain(), kCFRunLoopDefaultMode);

  chk(IOHIDDeviceOpen(dev, kIOHIDOptionsTypeNone));

  unsigned char buf[2048];
  IOHIDDeviceRegisterInputReportCallback(dev, buf, 2048, callback, nil);

  unsigned char d1[64] = { 1, 0x81, 0, 0x82 };
  //chk(IOHIDDeviceSetReport(dev, kIOHIDReportTypeOutput, 1, d1, sizeof(d1)));

  CFRunLoopRunInMode(kCFRunLoopDefaultMode, 4, false);

  //unsigned char d2[2048] = { 0 };
  //CFIndex d2s = sizeof(d2);
  //chk(IOHIDDeviceGetReport(dev, kIOHIDReportTypeOutput, 33, d2, &d2s));

  //for (int i = 0; i < 64; i++) {
  //  NSLog(@"%02x", d2[i]);
  //}

  //chk(IOHIDDeviceClose(dev, 0));
}

