//
//  TJLViewController.m
//  TJLSessionManager
//
//  Created by Terry Lewis II on 12/7/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import "TJLViewController.h"
#import "TJLSessionManager.h"

@interface TJLViewController () <UITableViewDataSource, UIAlertViewDelegate, NSStreamDelegate, UIActionSheetDelegate>
@property(strong, nonatomic) TJLSessionManager *sessionManager;
@property(weak, nonatomic) IBOutlet UITextField *textField;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *datasource;
@property(strong, nonatomic) NSMutableData *streamData;
@property(strong, nonatomic) NSOutputStream *outputStream;
@property(strong, nonatomic) NSInputStream *inputStream;
@property(weak, nonatomic) IBOutlet UIImageView *alienImageView;
@end

@implementation TJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof (self) weakSelf = self;
    self.datasource = [NSMutableArray new];
    self.sessionManager = [[TJLSessionManager alloc]initWithDisplayName:[NSString stringWithFormat:@"Terry %@", @(arc4random_uniform(100))]];

    [self.sessionManager didReceiveInvitationFromPeer:^void(MCPeerID *peer, NSData *context) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Accept Connection?" message:[NSString stringWithFormat:@"Can %@%@", peer.displayName, @" Connect?"] delegate:strongSelf cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }];

    [self.sessionManager peerConnectionStatusOnMainQueue:YES block:^(MCPeerID *peer, MCSessionState state) {
        if(state == MCSessionStateConnected) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Connected!" message:[NSString stringWithFormat:@"Now connected with %@", peer.displayName] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];

    [self.sessionManager receiveDataOnMainQueue:YES block:^(NSData *data, MCPeerID *peer) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSString *string = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [strongSelf.datasource addObject:@[string, peer.displayName]];

        [strongSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    [self.sessionManager receiveFinalResourceOnMainQueue:YES complete:^(NSString *name, MCPeerID *peer, NSURL *url, NSError *error) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSData *data = [NSData dataWithContentsOfURL:url];
        [strongSelf.datasource addObject:@[name, [UIImage imageWithData:data], peer.displayName]];

        [strongSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datasource.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];

    [self.sessionManager didReceiveStreamFromPeer:^(NSInputStream *stream, MCPeerID *peer, NSString *streamName) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        strongSelf.inputStream = stream;
        strongSelf.inputStream.delegate = self;
        [strongSelf.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [strongSelf.inputStream open];

    }];
    self.tableView.dataSource = self;
}

- (IBAction)advertise:(UIBarButtonItem *)sender {
    [self.sessionManager advertiseForBrowserViewController];
}

- (IBAction)browse:(UIBarButtonItem *)sender {
    [self.sessionManager browserWithControllerInViewController:self connected:^{
        NSLog(@"connected");
    }                                                 canceled:^{
        NSLog(@"cancelled");
    }];
}

- (IBAction)sendData:(UIButton *)sender {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.textField.text];
    NSError *error = [self.sessionManager sendDataToAllPeers:data];
    if(!error) {
        //there was no error.
    }
    else {
        NSLog(@"%@", error);
    }
}

- (IBAction)sendResource:(UIButton *)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send as Resource", @"Send as Stream", nil];
    [sheet showInView:self.view];
}

- (void)sendAsStream {
    NSError *err;
    self.outputStream = [self.sessionManager streamWithName:@"super stream" toPeer:self.sessionManager.firstPeer error:&err];
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    if(err || !self.outputStream) {
        NSLog(@"%@", err);
    }
    else {
        [self.outputStream open];
    }
}

- (void)sendAsResource {
    NSProgress *progress = [self.sessionManager sendResourceWithName:@"SweetPic" atURL:[self imageURL] toPeer:self.sessionManager.firstPeer complete:^(NSError *error) {
        if(!error) {
            NSLog(@"finished sending resource");
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    NSLog(@"%@", @(progress.fractionCompleted));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *array = self.datasource[(NSUInteger)indexPath.row];
    cell.textLabel.text = array.firstObject;
    cell.detailTextLabel.text = array.lastObject;
    if(array.count == 3)
        cell.imageView.image = array[1];

    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.sessionManager connectToPeer:buttonIndex == 1];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0:
            [self sendAsResource];
            break;
        case 1:
            [self sendAsStream];
            break;
        default:
            break;
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if(eventCode == NSStreamEventHasBytesAvailable) {
        NSInputStream *input = (NSInputStream *)aStream;
        uint8_t buffer[1024];
        NSInteger length = [input read:buffer maxLength:1024];
        [self.streamData appendBytes:(const void *)buffer length:(NSUInteger)lesngth];
        NSLog(@"received");
    }
    else if(eventCode == NSStreamEventHasSpaceAvailable) {
        NSData *data = [self imageData];
        NSOutputStream *output = (NSOutputStream *)aStream;
        [output write:data.bytes maxLength:data.length];

        [output close];
    }
    if(eventCode == NSStreamEventEndEncountered) {
        [aStream close];
        [aStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        if([aStream isKindOfClass:[NSInputStream class]]) {
            self.alienImageView.image = [UIImage imageWithData:self.streamData];
            self.streamData = nil;
        }

    }
    if(eventCode == NSStreamEventErrorOccurred) {
        NSLog(@"error");
    }
}

- (NSMutableData *)streamData {
    if(!_streamData) {
        _streamData = [NSMutableData data];
    }
    return _streamData;
}

- (NSData *)imageData {
    return [NSData dataWithContentsOfURL:[self imageURL]];
}

- (NSURL *)imageURL {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"301-alien-ship@2x" ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}

@end
