//
//  SavePhotoViewController.m
//  SaveImageToPhotosDemo
//
//  Created by Admin on 2019/8/7.
//  Copyright © 2019 com.personal.project. All rights reserved.
//

#import "SavePhotoViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define IMAGE_COUNT     12

@interface SavePhotoViewController ()

@property (nonatomic, retain) NSMutableArray *imageArray;
@property (nonatomic, retain) NSDate *startDate;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel1;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel2;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel3;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel4;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel5;

@end

@implementation SavePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)onMethod1:(id)sender {
    self.startDate = [NSDate date];
    [self method1];
}

- (IBAction)onMethod2:(id)sender {
    [self saveToArray];
    [self method2];
}

- (IBAction)onMethod3:(id)sender {
    [self saveToArray];
    [self method3];
}

- (IBAction)onMethod4:(id)sender {
    [self saveToArray];
    [self method4];
}

- (IBAction)onMethod5:(id)sender {
    [self saveToArray];
    [self method5];
}

- (IBAction)onTestMainThreadLoging:(id)sender {
    NSLog(@"[Main Thread] logging");
}

- (void)saveToArray
{
    [self.indicator startAnimating];
    
    self.startDate = [NSDate date];
    self.imageArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < IMAGE_COUNT; i ++)
    {
        UIImage *image = [UIImage imageNamed:@"cristina.jpg"];
        [self.imageArray addObject:image];
    }
}

- (void)method1
{
    //some image may not saved success. Error is write busy.
    for (NSInteger i = 0; i < IMAGE_COUNT; i ++)
    {
        UIImage *image = [UIImage imageNamed:@"cristina.jpg"];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}

- (void)method2
{
    UIImage *image = [self.imageArray objectAtIndex:0];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)method3
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("com.myApp.saveImagesToPhotos", NULL);
    
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        
        dispatch_async(queue, ^{
            
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            
            [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *writeError) {
                
                if (writeError) {
                    NSLog(@"[ALAssetsLibrary] Save image error!");
                }
                else
                {
                    NSLog(@"[ALAssetsLibrary] Save image success. Is on main thread? %@",[NSThread currentThread].isMainThread ? @"YES" : @"NO");
                    if (image == [self.imageArray lastObject])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.indicator stopAnimating];
                            NSLog(@"[ALAssetsLibrary] All Images Saved!");
                            double deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
                            NSLog(@"[ALAssetsLibrary] Cost time = %.2f ms", deltaTime*1000);
                            self.timeLabel3.text = [NSString stringWithFormat:@"Time cost: %.2f ms",deltaTime*1000];
                        });
                    }
                }
                dispatch_semaphore_signal(sema);
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        });
    }];
    
    [library release];
    dispatch_release(queue);
}

- (void)method4
{
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        if (@available(iOS 8.0, *)) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError *error) {
                if (error)
                    NSLog(@"[PHPhotoLibrary] Save image error");
                else
                {
                    NSLog(@"[PHPhotoLibrary] Save image success. Is on main thread? %@",[NSThread currentThread].isMainThread ? @"YES" : @"NO");
                    if (image == [self.imageArray lastObject])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.indicator stopAnimating];
                            NSLog(@"[PHPhotoLibrary] All Images Saved!");
                            double deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
                            NSLog(@"[PHPhotoLibrary] Cost time = %.2f ms", deltaTime*1000);
                            self.timeLabel4.text = [NSString stringWithFormat:@"Time cost: %.2f ms",deltaTime*1000];
                        });
                    }
                }
            }];
        } else {
            // Fallback on earlier versions, below iOS8.0
        }
    }];
}

- (void)method5
{
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        NSError *error = nil;
        if (@available(iOS 8.0, *)) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } error:&error];
        } else {
            // Fallback on earlier versions, below iOS8.0
        }
        if (error)
            NSLog(@"[PHPhotoLibrary] Save image error");
        else
        {
            NSLog(@"[PHPhotoLibrary] Save image success. Is on main thread? %@",[NSThread currentThread].isMainThread ? @"YES" : @"NO");
            if (image == [self.imageArray lastObject])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.indicator stopAnimating];
                    NSLog(@"[PHPhotoLibrary] All Images Saved!");
                    double deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
                    NSLog(@"[PHPhotoLibrary] Cost time = %.2f ms", deltaTime*1000);
                    self.timeLabel5.text = [NSString stringWithFormat:@"Time cost: %.2f ms",deltaTime*1000];
                });
            }
        }
    }];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        NSLog(@"[Method2 call back] Save image error:%@", error.localizedDescription);
    }
    else
    {
        NSLog(@"[Method2 call back] Save image success! Is on main thread? %@",[NSThread currentThread].isMainThread ? @"YES" : @"NO");
        
        NSInteger count = self.imageArray.count;
        if (count > 0)
        {
            if (count > 1)
            {
                [self.imageArray removeObjectAtIndex:0];
                [self method2];
            }
            else
            {
                NSLog(@"[Method2 call back] All Images Saved!");
                [self.indicator stopAnimating];
                double deltaTime = [[NSDate date] timeIntervalSinceDate:self.startDate];
                NSLog(@"[Method2 call back] Cost time = %.2f ms", deltaTime*1000);
                self.timeLabel2.text = [NSString stringWithFormat:@"Time cost: %.2f ms",deltaTime*1000];
                [self.imageArray removeAllObjects];
                self.imageArray = nil;
            }
        }
    }
}

- (void)dealloc
{
    self.imageArray = nil;
    self.startDate = nil;
    
    NSLog(@"SavePhotoViewController dealloc");
    
    [_indicator release];
    [_timeLabel1 release];
    [_timeLabel2 release];
    [_timeLabel3 release];
    [_timeLabel4 release];
    [_timeLabel5 release];
    [super dealloc];
}

@end
