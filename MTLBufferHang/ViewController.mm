#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
#include <chrono>

#include <sys/types.h>
#include <sys/sysctl.h>

NSString* getDeviceName() {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);

    char *model = (char*) malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);

    NSString *deviceString = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);

    return deviceString;
}

NSString* optionToString(MTLResourceOptions option) {
    if (option == MTLResourceStorageModePrivate) {
        return @"MTLResourceStorageModePrivate";
    }
    if (option == MTLResourceStorageModeShared) {
        return @"MTLResourceStorageModeShared";
    }
    assert(false);
    return @"";
}

@interface ViewController : UIViewController {
    id<MTLDevice> _metalDevice;
    NSMutableArray<id<MTLBuffer>> *_buffers;
    id<MTLHeap> _heap;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _metalDevice = MTLCreateSystemDefaultDevice();

    //[self allocateBuffersOfSize:1024 options:MTLResourceStorageModePrivate];

    // Helpful to determine if the size or storage mode matters.
    [self doBufferAllocationStats];
}

- (void)doBufferAllocationStats {
    printf("device, iOS version, buffer size, buffers allocated before freezing, last allocation freeze time (ms), storage mode\n");

    NSString* iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString* deviceName = getDeviceName();

    for (const auto size : {16, 32, 64, 1024, 2048, 4096}) {
        for (const auto option : {MTLResourceStorageModePrivate, MTLResourceStorageModeShared}) {
            const auto& [buffersAllocatedNormally, hangTime] = [self findBufferHangWithSize:size
                                                                                    options:option];
            NSString* optionString = optionToString(option);
            printf("\"%s\", %s, %d, %lu, %lu, %s\n",
                  [deviceName cStringUsingEncoding:NSUTF8StringEncoding],
                  [iOSVersion cStringUsingEncoding:NSUTF8StringEncoding],
                  size,
                  buffersAllocatedNormally,
                  hangTime,
                  [optionString cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    }
}

- (void)allocateBuffersOfSize:(NSUInteger)size options:(MTLResourceOptions)options {
    NSString* iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString* deviceName = getDeviceName();
    printf("device: %s, iOS version: %s\n",
           [deviceName cStringUsingEncoding:NSUTF8StringEncoding],
           [iOSVersion cStringUsingEncoding:NSUTF8StringEncoding]);

    using namespace std::chrono;
    high_resolution_clock::time_point start, end;

    // Store the buffers in an array to keep them alive.
    NSMutableArray* buffers = [NSMutableArray array];

    constexpr auto MAX_BUFFERS = 100000;    // hard limit to allocate
    for (NSUInteger i = 0; i < MAX_BUFFERS; ++i) {
        start = high_resolution_clock::now();
        id<MTLBuffer> buffer = [_metalDevice newBufferWithLength:size
                                                         options:options];
        end = high_resolution_clock::now();

        duration<double, std::micro> allocationTime = end - start;

        auto microseconds = allocationTime.count();
        auto milliseconds = microseconds / 1000.0;

        printf("Buffer #%ld: Allocated %ld byte id<MTLBuffer> in %f ms\n", i, size, milliseconds);

        [buffers addObject:buffer];
    }
}

/**
 * Attempt to create id<MTLBuffer>s until the time to create one surpases 500 ms. Returns the number of buffers allocated "quickly" (sub 500 ms), and the time it took to allocate the last buffer.
 */
- (std::pair<NSUInteger, NSUInteger>)findBufferHangWithSize:(NSUInteger)size options:(MTLResourceOptions)options {
    using namespace std::chrono;
    high_resolution_clock::time_point start, end;

    // Store the buffers in an array to keep them alive.
    NSMutableArray* buffers = [NSMutableArray array];

    NSUInteger buffersAllocatedNormally = 0;
    NSUInteger lastBufferAllocationTime = 0;
    constexpr auto MAX_BUFFERS = 100000;    // hard limit to allocate
    for (NSUInteger i = 0; i < MAX_BUFFERS; ++i) {
        start = high_resolution_clock::now();
        id<MTLBuffer> buffer = [_metalDevice newBufferWithLength:size
                                                         options:options];
        end = high_resolution_clock::now();

        duration<double, std::micro> allocationTime = end - start;

        // Only log once the allocation time gets above 500 ms
        auto microseconds = allocationTime.count();
        auto milliseconds = microseconds / 1000.0;

        lastBufferAllocationTime = milliseconds;

        if (milliseconds >= 500.0) {
            break;
        }

        buffersAllocatedNormally++;
        [buffers addObject:buffer];
    }

    return {buffersAllocatedNormally, lastBufferAllocationTime};
}

@end
