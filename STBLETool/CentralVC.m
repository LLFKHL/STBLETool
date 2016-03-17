//
//  CentralVC.m
//  STBLETool
//
//  Created by TangJR on 3/16/16.
//  Copyright © 2016 tangjr. All rights reserved.
//

#import "CentralVC.h"
#import "STCentralTool.h"

@interface CentralVC ()

@property (strong, nonatomic) STCentralTool *tool;

@end

@implementation CentralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tool = [STCentralTool shareInstence];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tool startScan];
}

@end