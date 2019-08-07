# SaveImageToPhotosDemo
Save multiple images to iOS Photos

Five method to save multiple image to iOS Photos

Method 1
    Use UIImageWriteToSavedPhotosAlbum() to save in a for-loop. Some images cannot save success because of write busy.
    
Method 2
    Save image in array, and use UIImageWriteToSavedPhotosAlbum() to save the first image and set the completeSelector and completeHandler. In completeHandler, when save image successed, save next image.
    
Method 3
    Use ALAssetsLibrary framework to write image to Photos. This framework works for iOS7.0 to iOS9.0. Save image in sub-thread.
    
    Relate API:
    - (void)writeImageToSavedPhotosAlbum:(CGImageRef)imageRef metadata:(NSDictionary *)metadata completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock
    
    
Method 4
    Use Photo framework to write image to Photo. This framework works for iOS8.0 and later. Method 4 save image in sub-thread.
    
    Relate API:
    - (void)performChanges:(dispatch_block_t)changeBlock completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;
    
Method 5
    Use Photo framework to write image to Photo. This framework works for iOS8.0 and later. Method 5 save image in main thread.
    
    Relate API:
    - (BOOL)performChangesAndWait:(dispatch_block_t)changeBlock error:(NSError *__autoreleasing *)error;
