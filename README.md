# MTLBuffer Hang Demo

This iOS app demonstrates a behavior observed during allocation of `MTLBuffer`s on various iPhone
models. Specifically, after allocating just shy of 60000 `MTLBuffer`s, the allocation process
causes a significant hang, exceeding 16 seconds, seemingly independent of the iPhone model,
`MTLResourceStorageMode`, or buffer size.

Questions we have:
- What's the reason for this behavior?
- Is there any way we can predict it?

Example logs:

```
device: iPhone15,2 (iPhone 14 Pro), iOS version: 17.4
...
Buffer #59531: Allocated 1024 byte id<MTLBuffer> in 0.013291 ms
Buffer #59532: Allocated 1024 byte id<MTLBuffer> in 0.013875 ms
Buffer #59533: Allocated 1024 byte id<MTLBuffer> in 0.033583 ms
Buffer #59534: Allocated 1024 byte id<MTLBuffer> in 16001.135833 ms
Buffer #59535: Allocated 1024 byte id<MTLBuffer> in 16001.070833 ms
Buffer #59536: Allocated 1024 byte id<MTLBuffer> in 16001.185250 ms
```

```
device: iPhone10,1 (iPhone 8), iOS version: 15.5
...
Buffer #59532: Allocated 1024 byte id<MTLBuffer> in 0.008041 ms
Buffer #59533: Allocated 1024 byte id<MTLBuffer> in 0.007875 ms
Buffer #59534: Allocated 1024 byte id<MTLBuffer> in 0.022500 ms
Buffer #59535: Allocated 1024 byte id<MTLBuffer> in 16001.355792 ms
Buffer #59536: Allocated 1024 byte id<MTLBuffer> in 16001.310500 ms
Buffer #59537: Allocated 1024 byte id<MTLBuffer> in 16001.325958 ms
```

## Data Collection

This table summarizes the data collected from a couple of iPhone models during the experiment. The
hang happens regardless of device, buffer size, or storage mode.

|     device | iOS version | buffer size | buffers allocated before freezing | last allocation freeze time (ms) | storage mode                  |
|-----------:|------------:|------------:|----------------------------------:|---------------------------------:|-------------------------------|
| iPhone10,1 |        15.5 |          16 |                             59884 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |          16 |                             59884 |                            16001 | MTLResourceStorageModeShared  |
| iPhone10,1 |        15.5 |          32 |                             59884 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |          32 |                             59884 |                            16001 | MTLResourceStorageModeShared  |
| iPhone10,1 |        15.5 |          64 |                             59884 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |          64 |                             59884 |                            16001 | MTLResourceStorageModeShared  |
| iPhone10,1 |        15.5 |        1024 |                             59535 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |        1024 |                             59535 |                            16001 | MTLResourceStorageModeShared  |
| iPhone10,1 |        15.5 |        2048 |                             59077 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |        2048 |                             59077 |                            16001 | MTLResourceStorageModeShared  |
| iPhone10,1 |        15.5 |        4096 |                             58977 |                            16001 | MTLResourceStorageModePrivate |
| iPhone10,1 |        15.5 |        4096 |                             58977 |                            16001 | MTLResourceStorageModeShared  |
| iPhone15,2 |        17.4 |          16 |                             59883 |                            16001 | MTLResourceStorageModePrivate |
| iPhone15,2 |        17.4 |          16 |                             59883 |                            16001 | MTLResourceStorageModeShared  |
| iPhone15,2 |        17.4 |          32 |                             59883 |                            16001 | MTLResourceStorageModePrivate |
| iPhone15,2 |        17.4 |          32 |                             59883 |                            16001 | MTLResourceStorageModeShared  |
| iPhone15,2 |        17.4 |          64 |                             59883 |                            16001 | MTLResourceStorageModePrivate |
| iPhone15,2 |        17.4 |          64 |                             59883 |                            16001 | MTLResourceStorageModeShared  |
| iPhone15,2 |        17.4 |        1024 |                             59534 |                            16001 | MTLResourceStorageModePrivate |
| iPhone15,2 |        17.4 |        1024 |                             59534 |                            16001 | MTLResourceStorageModeShared  |
| iPhone15,2 |        17.4 |        2048 |                             59076 |                            16001 | MTLResourceStorageModePrivate |
| iPhone15,2 |        17.4 |        2048 |                             59076 |                            16001 | MTLResourceStorageModeShared  |
