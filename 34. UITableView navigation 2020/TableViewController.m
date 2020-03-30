//
//  TableViewController.m
//  34. UITableView navigation 2020
//
//  Created by Dmitry Marchenko on 3/29/20.
//  Copyright © 2020 Dmitry Marchenko. All rights reserved.
//

#import "TableViewController.h"

typedef enum {
    ItemTypeFolder,
    ItemTypeFile
} ItemType;

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *content;

@end


@implementation TableViewController

#pragma mark - Setters

- (void)setPath:(NSString *)path {
    
    _path = path;
    
    NSError *error = nil;
    
    self.content = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error]];
    self.content = [self arrayByRemovingHiddenFilesAndFolders:self.content];
    
    error ? NSLog(@"%@", [error localizedDescription]) : 0;
    
    self.navigationItem.title = [self.path lastPathComponent];
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(addBarButtonItemAction:)];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(editBarButtonItemAction:)];
    
    UIBarButtonItem *sortBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                                       target:self
                                                                                       action:@selector(sortBarButtonItemAction:)];
    
    self.navigationItem.rightBarButtonItems = @[addBarButtonItem, editBarButtonItem, sortBarButtonItem];
    
    [self.tableView reloadData];
}


#pragma mark - Actions

- (void)sortBarButtonItemAction:(UIBarButtonItem *)sender {
    
    NSArray *oldContent = [NSArray arrayWithArray:self.content];
    
    NSMutableArray *files = [NSMutableArray array];
    NSMutableArray *folders = [NSMutableArray array];
    
    for (NSString *itemName in self.content) {
        
        NSString *currentPath = [self.path stringByAppendingPathComponent:itemName];
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:currentPath isDirectory:&isDirectory];
        
        isDirectory ? [folders addObject:itemName] : [files addObject:itemName];
    }
    
    [files sortUsingSelector:@selector(compare:)];
    [folders sortUsingSelector:@selector(compare:)];
    [folders addObjectsFromArray:files];
    
    self.content = folders;
    
    [self.tableView performBatchUpdates:^{
        
        for (NSString *currentContentItem in self.content) {
            
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[oldContent indexOfObject:currentContentItem] inSection:0];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.content indexOfObject:currentContentItem] inSection:0];
            
            [self.tableView moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
        }
        
    } completion:^(BOOL finished) {
    }];
}

- (void)addBarButtonItemAction:(UIBarButtonItem *)sender {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose option"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* addDirectoryAction = [UIAlertAction actionWithTitle:@"Add directory"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   
                                                                   [self enterNameActionWithItem:ItemTypeFolder];
                                                               }];
    
    UIAlertAction* addFileAction = [UIAlertAction actionWithTitle:@"Add file"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              [self enterNameActionWithItem:ItemTypeFile];
                                                          }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:addDirectoryAction];
    [alert addAction:addFileAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editBarButtonItemAction:(UIBarButtonItem *)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    UIBarButtonItem *editDoneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(editBarButtonItemAction:)];
    
    NSMutableArray *newRightBarButtonItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    [newRightBarButtonItems replaceObjectAtIndex:1 withObject:editDoneBarButtonItem];
    
    self.navigationItem.rightBarButtonItems = newRightBarButtonItems;
}

- (void)enterNameActionWithItem:(ItemType)itemType {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:itemType == ItemTypeFolder ? @"New folder" : @"New file"
                                                                             message: itemType == ItemTypeFolder ? @"Enter folder name" : @"Enter file name"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = [NSString stringWithFormat:@"%@", itemType == ItemTypeFolder ? @"Folder name" : @"File name"];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self addBarButtonItemAction:nil];
                                                         }];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             [self addNewItemWithName:alertController.textFields[0].text
                                                                          andItemType:itemType];
                                                         }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UIView lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (!self.path) {
        self.path = @"/Users/dmitrymarchenko/Desktop/test";
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
        cell.detailTextLabel.text = [self fileSizeForIndexPath:indexPath];
        
        return cell;
    } else {
    
        NSString *folderCell = @"folderCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderCell forIndexPath:indexPath];
    
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:folderCell];
        }
    
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.content objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text = [self folderSizeForIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
        NSError *error = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:[self pathByAddingSelectedPathComponentForIndexPath:indexPath] error:&error];
        [self.content removeObjectAtIndex:indexPath.row];
        
        error ? NSLog(@"%@", [error localizedDescription]) : 0;
        
        [tableView performBatchUpdates:^{
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } completion:^(BOOL finished) {
        }];
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

- (void)addNewItemWithName:(NSString *)name andItemType:(ItemType)type {
    
    NSString *pathWithNewItemName = [self.path stringByAppendingPathComponent:name];
    
    if (type == ItemTypeFile) {
        [[NSFileManager defaultManager] createFileAtPath:pathWithNewItemName
                                                contents:nil
                                              attributes:nil];
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathWithNewItemName
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    self.content = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:nil]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.content indexOfObject:name] inSection:0];
    
    [self.tableView performBatchUpdates:^{
        
//        if ([self.tableView numberOfRowsInSection:0] >= indexPath.row && [self.tableView numberOfRowsInSection:0] != 0) {
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//        }
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } completion:^(BOOL finished) {
    }];
}

- (NSString *)fileSizeForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *itemPath = [self.path stringByAppendingPathComponent:[self.content objectAtIndex:indexPath.row]];
    
    unsigned long long size = [[[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil] fileSize];
    
    NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
    
    return displayFileSize;
}

- (NSString *)folderSizeForIndexPath:(NSIndexPath *)indexPath {
    
    unsigned long long folderSize = 0;
    
    NSString *folderPath = [self.path stringByAppendingPathComponent:[self.content objectAtIndex:indexPath.row]];
    NSArray *filesArrayOfFolder = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArrayOfFolder objectEnumerator];
    NSString *fileName;

    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        folderSize += [fileDictionary fileSize];
    }
    
    NSString *displayFileSize = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    
    return displayFileSize;
}


#pragma mark - Other

- (NSMutableArray *)arrayByRemovingHiddenFilesAndFolders:(NSArray *)array {
    
    NSMutableArray *newContent = [NSMutableArray arrayWithArray:array];
    
    for (NSString *currentContentItem in array) {
        
        if ([[currentContentItem substringToIndex:1] isEqualToString:@"."]) {
            [newContent removeObject:currentContentItem];
        }
    }
    
    return newContent;
}

@end
