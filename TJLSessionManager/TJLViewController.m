//
//  TJLViewController.m
//  TJLSessionManager
//
//  Created by Terry Lewis II on 12/7/13.
//  Copyright (c) 2013 Terry Lewis. All rights reserved.
//

#import "TJLViewController.h"
#import "TJLSessionManager.h"
@interface TJLViewController ()<UITableViewDataSource>
@property(strong, nonatomic) TJLSessionManager *sessionManager;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *datasource;
@end

@implementation TJLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datasource = [NSMutableArray new];
    self.sessionManager = [[TJLSessionManager alloc]initWithDisplayName:@"Terry"];
    
    __weak typeof (self) weakSelf = self;
    [self.sessionManager receiveDataOnMainQueue:YES block:^(NSData *data, MCPeerID *peer) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        NSString *string = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [strongSelf.datasource addObject:@[string, peer.displayName]];
        
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
    
    return cell;
}
@end
