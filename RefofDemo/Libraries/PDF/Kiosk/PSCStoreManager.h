//
//  PSPDFStoreManager.h
//  PSPDFCatalog
//
//  Copyright 2011-2013 PSPDFKit GmbH. All rights reserved.
//
//  The PSPDFKit Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

/// Enable to make the view plain, no folders supported.
#define PSPDFStoreManagerPlain YES

/// Notification emitted when magazines were successfully loaded form disk.
extern NSString *const kPSPDFStoreDiskLoadFinishedNotification;

@class PSCMagazine, PSCMagazineFolder, PSCDownload;

@protocol PSCStoreManagerDelegate <NSObject>

- (void)magazineStoreBeginUpdate;
- (void)magazineStoreEndUpdate;

// folder
- (void)magazineStoreFolderDeleted:(PSCMagazineFolder *)magazineFolder;
- (void)magazineStoreFolderAdded:(PSCMagazineFolder *)magazineFolder;
- (void)magazineStoreFolderModified:(PSCMagazineFolder *)magazineFolder;

// magazine
- (void)magazineStoreMagazineDeleted:(PSCMagazine *)magazine;
- (void)magazineStoreMagazineAdded:(PSCMagazine *)magazine;
- (void)magazineStoreMagazineModified:(PSCMagazine *)magazine;

- (void)openMagazine:(PSCMagazine *)magazine;

@end

/// Store manager, keeps magazines and folders.
@interface PSCStoreManager : NSObject

/// Shared Instance.
+ (PSCStoreManager *)sharedStoreManager;

/// Single delegate.
@property (nonatomic, strong) id<PSCStoreManagerDelegate> delegate;

/// Storage path currently used. (depends on iOS version)
+ (NSString *)storagePath;

/// Clears all magazineFolders. Will not send delegate events.
- (void)clearCache;

/// Reload all magazines from disk.
- (void)loadMagazinesFromDisk;

// Add multiple magazines.
- (void)addMagazinesToStore:(NSArray *)magazines;

// Delete a magazine.
- (void)deleteMagazine:(PSCMagazine *)magazine;

// Delete a magazine folder.
- (void)deleteMagazineFolder:(PSCMagazineFolder *)magazineFolder;

// All available magazine folders.
@property (nonatomic, strong, readonly) NSArray *magazineFolders;

// Are we loading disk files?
@property (nonatomic, assign, getter=isDiskDataLoaded, readonly) BOOL diskDataLoaded;

// @name Download management

// Start downloading a magazine.
- (void)downloadMagazine:(PSCMagazine *)magazine;

// Cancels a magazine download.
- (BOOL)cancelDownloadForMagazine:(PSCMagazine *)magazine;

// Gets the current download progress object, if one is available.
- (PSCDownload *)downloadObjectForMagazine:(PSCMagazine *)magazine;

// Running downloads (PSCDownload) are saved here.
@property (nonatomic, strong, readonly) NSArray *downloadQueue;

@end
