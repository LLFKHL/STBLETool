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

@end

@implementation CentralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    STBLETool *tool = [STBLETool shareInstence];
    [tool startScan];
}

@end