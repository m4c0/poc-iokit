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

static void callback(void * context, IOReturn result, void * sender, IOHIDReportType type, uint32_t report_id, uint8_t * r, CFIndex report_len) {
  if (report_len != 64) abort();

  uint8_t rid = r[0];
  uint8_t echo = r[1];
  uint16_t checksum = *(uint16_t *)(r + 2); 
  uint16_t len = *(uint16_t *)(r + 4); 
  uint8_t cmd = r[6];
  uint8_t idx = r[7];

  char buf[256] = {0};
  for (int i = 0; i < len - 4; i++) {
    sprintf(buf + i * 3, "%02x ", r[i + 8]);
  }

  NSLog(@"rid=%d echo=%x chk=%x len=%d cmd=%d idx=%d %s", rid, echo, checksum, len, cmd, idx, buf);
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

  IOHIDDeviceScheduleWithRunLoop(dev, CFRunLoopGetMain(), kCFRunLoopDefaultMode);

  chk(IOHIDDeviceOpen(dev, kIOHIDOptionsTypeNone));

  unsigned char buf[2048];
  IOHIDDeviceRegisterInputReportCallback(dev, buf, 2048, callback, nil);

  CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, false);

  IOHIDDeviceClose(dev, 0);
}
