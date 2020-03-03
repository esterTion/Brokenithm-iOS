//
//  SocketDelegate.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/29.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "SocketDelegate.h"

@interface SocketDelegate ()
@end

@implementation SocketDelegate

- (id)init {
    server = [[GCDAsyncSocket alloc] initWithDelegate:(id)self delegateQueue:dispatch_get_main_queue()];
    [self acceptConnection];
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(becomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    return [super init];
}
- (void)acceptConnection {
    NSError *error = nil;
    if (![server acceptOnPort:24864 error:&error]) {
        NSLog(@"error creating server: %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }
    NSLog(@"got connection");
    NSString *initResponse = @"\x03WEL";
    NSData *initResp = [initResponse dataUsingEncoding:NSASCIIStringEncoding];
    [newSocket writeData:initResp withTimeout:-1 tag:0];
    [newSocket readDataToLength:1 withTimeout:5 tag:0];
    [self.parentVc connected];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    switch (tag) {
        case 0: {
            // length
            [sock readDataToLength:((uint8_t*)data.bytes)[0] withTimeout:1 tag:1];
            break;
        }
        case 1: {
            // data
            if (data.length < 3) {
                [sock disconnect];
                return;
            }
            NSData *msgData = [data subdataWithRange:NSMakeRange(0, 3)];
            NSString *message = [[NSString alloc] initWithData:msgData encoding:NSASCIIStringEncoding];
            if ([message isEqualToString:@"LED"] && data.length >= 99) {
                NSData *led = [data subdataWithRange:NSMakeRange(3, 96)];
                [self.parentVc updateLed:led];
            }
            
            [sock readDataToLength:1 withTimeout:5 tag:0];
        }
    }
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (sock != server)
    {
        NSLog(@"connection ended");
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
        }
        [self.parentVc disconnected];
    }
}

- (void)updateIO:(NSData*)io {
    for (GCDAsyncSocket* sock in connectedSockets) {
        [sock writeData:io withTimeout:-1 tag:0];
    }
}

- (void)becomeInactive {
    server.IPv4Enabled = NO;
    server.IPv6Enabled = NO;
    for (GCDAsyncSocket* sock in connectedSockets) {
        [sock disconnect];
        [connectedSockets removeObject:sock];
    }
    [server disconnect];
}
- (void)becomeActive {
    server.IPv4Enabled = YES;
    server.IPv6Enabled = YES;
    [self acceptConnection];
}

@end

