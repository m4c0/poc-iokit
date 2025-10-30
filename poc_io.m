@import Foundation;
@import IOKit.hid;

static void fn(const void * ptr, void * n) {
  NSLog(@"%@", ptr);
}

int main() {
  NSDictionary * match = @{};

  IOHIDManagerRef mgr = IOHIDManagerCreate(kCFAllocatorDefault, 0);
  IOHIDManagerOpen(mgr, 0);
  IOHIDManagerSetDeviceMatching(mgr, (CFDictionaryRef) match);

  CFSetRef set = IOHIDManagerCopyDevices(mgr);
  CFSetApplyFunction(set, fn, nil);
}

