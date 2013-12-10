//
//  TJLViewController.m
//  TJLSessionManager
//
//  Created by Terry Lewis II on 12/7/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import "TJLViewController.h"
#import "TJLSessionManager.h"
@interface TJLViewController ()<UITableViewDataSource, UIAlertViewDelegate>
@property(strong, nonatomic) TJLSessionManager *sessionManager;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *datasource;
@property(nonatomic,copy) BOOL(^invitationBlock)(MCPeerID *peer, NSData *context);
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
    
    self.tableView.dataSource = self;
}

- (IBAction)advertise:(UIBarButtonItem *)sender {
    [self.sessionManager advertiseForBrowserViewController];
}

- (IBAction)browse:(UIBarButtonItem *)sender {
    [self.sessionManager browserWithControllerInViewController:self connected:^{
        NSLog(@"connected");
    } canceled:^{
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
   NSString *path = [[NSBundle mainBundle]pathForResource:@"301-alien-ship@2x" ofType:@"png"];
    NSURL *url = [NSURL fileURLWithPath:path];
  NSProgress *progress = [self.sessionManager sendResourceWithName:@"SweetPic" atURL:url toPeer:self.sessionManager.firstPeer complete:^(NSError *error) {
      if(!error) {
          NSLog(@"finished sending resource");
      }
      else {
          NSLog(@"%@", error);
      }
   }];
    NSLog(@"%@", @(progress.fractionCompleted));
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSArray *array = self.datasource[indexPath.row];
    cell.textLabel.text = array.firstObject;
    cell.detailTextLabel.text = array.lastObject;
    if(array.count == 3)
        cell.imageView.image = array[1];
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.sessionManager connectToPeer:buttonIndex == 1];
}
@end
