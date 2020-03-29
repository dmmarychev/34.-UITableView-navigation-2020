//
//  TableViewController.m
//  34. UITableView navigation 2020
//
//  Created by Dmitry Marchenko on 3/29/20.
//  Copyright © 2020 Dmitry Marchenko. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *content;

@end


@implementation TableViewController

#pragma mark - Setters

- (void)setPath:(NSString *)path {
    
    _path = path;
    
    NSError *error = nil;
    
    self.content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    
    error ? NSLog(@"%@", [error localizedDescription]) : 0;
    
    self.navigationItem.title = [self.path lastPathComponent];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(editBarButtonItemAction:)];
    [self.tableView reloadData];
}


#pragma mark - Actions

- (void)editBarButtonItemAction:(UIBarButtonItem *)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit
                                                  target:self
                                                  action:@selector(editBarButtonItemAction:)];
}

#pragma mark - UIView lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!self.path) {
        self.path = @"/Users/dmmarychev/Desktop/test for lesson 34";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.content count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self isDirectoryForIndexPath:indexPath]) {
        
        NSString *fileCell = @"fileCell";
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCell forIndexPath:indexPath];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:fileCell];
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.content objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
    
        NSString *folderCell = @"folderCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderCell forIndexPath:indexPath];
    
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:folderCell];
        }
    
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.content objectAtIndex:indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isDirectoryForIndexPath:indexPath]) {
        
        NSError *error = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:self.path error:&error];
    
        error ? NSLog(@"%@", [error localizedDescription]) : 0;
        
        [self.tableView]
        
    } else {
    
    
    }

}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryForIndexPath:indexPath]) {
    
        TableViewController *newTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
        newTableViewController.path = [self pathByAddingSelectedPathComponentForIndexPath:indexPath];
        [self.navigationController pushViewController:newTableViewController animated:YES];
    }
    
}

#pragma mark - NSFileManager

- (BOOL)isDirectoryForIndexPath:(NSIndexPath *)indexPath {

    BOOL isDirectory;
    
    NSString *pathByAddingSelectedPathComponent = [self pathByAddingSelectedPathComponentForIndexPath:indexPath];
    
    [[NSFileManager defaultManager] fileExistsAtPath:pathByAddingSelectedPathComponent
                                         isDirectory:&isDirectory];

    return isDirectory;
}

- (NSString *)pathByAddingSelectedPathComponentForIndexPath:(NSIndexPath *)indexPath {

    return [self.path stringByAppendingPathComponent:[self.content objectAtIndex:indexPath.row]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
