//
//  CentralVC.m
//  STBLETool
//
//  Created by TangJR on 3/16/16.
//  Copyright © 2016 tangjr. All rights reserved.
//

#import "CentralVC.h"
#import "STBLETool.h"

@interface CentralVC ()

@property (strong, nonatomic) STBLETool *tool;

@end

@implementation CentralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tool = [STBLETool shareInstence];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tool startScan];
}

@end