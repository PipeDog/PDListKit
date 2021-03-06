//
//  ViewController.m
//  PDList
//
//  Created by liang on 2018/3/20.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import <PDListKit.h>
#import "PDFirstSectionController.h"
#import "PDSecondSectionController.h"

@interface ViewController () <PDListAdapterDataSource>

@property (nonatomic, strong) PDListAdapter *listAdapter;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // [self.listAdapter reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.listAdapter.dataSource = self;
    [self.listAdapter reloadData];
}

- (IBAction)didClickLeftItem:(id)sender {
    [self.listAdapter reloadData];
}

- (IBAction)didClickRightItem:(id)sender {
    [self.listAdapter reloadData];
}

#pragma mark - PDListAdapterDataSource Methods
- (NSArray<id<PDListDiffable>> *)objectsForListAdapter:(PDListAdapter *)listAdapter {
    return [self.dataArray copy];
}

- (PDListSectionController *)listAdapter:(PDListAdapter *)listAdapter sectionControllerForObject:(id<PDListDiffable>)object {
    PDListSectionController *sectionController;
//    if (section == 0) {
        sectionController = [[PDFirstSectionController alloc] init];
//    } else {
//        sectionController = [[PDSecondSectionController alloc] init];
//    }
    return sectionController;
}

- (UIView *)emptyViewForListAdapter:(PDListAdapter *)listAdapter {
    UIView *emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
    emptyView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
    return emptyView;
}

#pragma mark - Getter Methods
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.tableHeaderView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (PDListAdapter *)listAdapter {
    if (!_listAdapter) {
        _listAdapter = [[PDListAdapter alloc] initWithTableView:self.tableView];
    }
    return _listAdapter;
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSArray *array0 = @[@"better alternative (see bneely's answer to why this warning is saving you from disaster) is to use method swizzling. By using method swizzling, you can replace an existing method from a category without the uncertainty of who \"wins\", and while preserving the ability to call through to the old method. The secret is to give the override a different method name, then swap them using runtime functions.",
                            @"better alternative (see bneely's answer to why this warning is saving you from disaster) is to use method swizzling. By using method swizzling, you can replace an existing method from a category without the uncertainty of who \"wins\", and while preserving the ability to call through to the old method. The secret is to give the override a different method name, then swap them using runtime functions.better alternative (see bneely's answer to why this warning is saving you from disaster) is to use method swizzling. By using method swizzling, you can replace an existing method from a category without the uncertainty of who \"wins\", and while preserving the ability to call through to the old method. The secret is to give the override a different method name, then swap them using runtime functions.",
                            @"better alternative (see bneely's answer to why this warning is saving you from disaster) is to use method swizzling. By using."];
        
        NSArray *array1 = @[@"One line of code to implement automatic layout. 一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于做最简单易用的AutoLayout库。The most easy way for autoLayout. Based on runtime.",
                            @"One line of code to implement automatic layout. 一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于做最简单易用的AutoLayout库。The most easy way for autoLayout. Based on runtime.One line of code to implement automatic layout. 一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于做最简单易用的AutoLayout库。The most easy way for autoLayout. Based on runtime.",
                            @"One line of code to implement automatic layout. 一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于做最简单易用的AutoLayout库。The most easy way for autoLayout. Based on runtime."];
        _dataArray = @[array0, array1, [array1 copy], [array1 copy]];
    }
    return _dataArray;
}

@end
