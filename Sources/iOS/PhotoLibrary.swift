/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Photos

public struct PhotoLibraryDataSource {
    public private(set) var collection: PHAssetCollection
    public private(set) var assets: [PHAsset]
}

@objc(PhotoLibraryDelegate)
public protocol PhotoLibraryDelegate {
    /**
     A delegation method that is executed when the PhotoLibrary status is updated.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter status: A reference to the AuthorizationStatus.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, status: PHAuthorizationStatus)
    
    /**
     A delegation method that is executed when the PhotoLibrary is authorized.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     */
    @objc
    optional func photoLibrary(authorized photoLibrary: PhotoLibrary)
    
    /**
     A delegation method that is executed when the PhotoLibrary is denied.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     */
    @objc
    optional func photoLibrary(denied photoLibrary: PhotoLibrary)
    
    /**
     A delegation method that is executed when the PhotoLibrary is not determined.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     */
    @objc
    optional func photoLibrary(notDetermined photoLibrary: PhotoLibrary)
    
    /**
     A delegation method that is executed when the PhotoLibrary is restricted.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     */
    @objc
    optional func photoLibrary(restricted photoLibrary: PhotoLibrary)
    
    /**
     A delegation method that is executed when the PhotoLibrary has changes,
     locally or remotely.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter changeInfo: A reference to a PHChange object.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, didChange changeInfo: PHChange)
    
    /**
     A delegation method that is executed when changes are detected.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter beforeChanges: A PHObject before changes.
     - Parameter afterChanges: A PHObject after changes.
     - Parameter assetContentChanged: A Bool that is true if the image or video content for this
     object has changed.
     - Parameter objectWasDeleted: A Bool that is true if the object was deleted.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, beforeChanges: PHObject, afterChanges: PHObject, assetContentChanged: Bool, objectWasDeleted: Bool)
    
    /**
     A delegation method that is executed when there is a change in the
     fetchResult object.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter fetchBeforeChanges: A PHFetchResult<PHObject> before changes.
     - Parameter fetchAfterChanges: A PHFetchResult<PHObject> after changes.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, fetchBeforeChanges: PHFetchResult<PHObject>, fetchAfterChanges: PHFetchResult<PHObject>)
    
    /**
     A delegation method that is executed when there are moved objects.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter removed indexes: An IndexSet of the removed indexes.
     - Parameter for objects: An Array of PHObjects that have been removed.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, removed indexes: IndexSet, for objects: [PHObject])
    
    /**
     A delegation method that is executed when there are newly inserted objects.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter inserted indexes: An IndexSet of the inserted indexes.
     - Parameter for objects: An Array of PHObjects that have been inserted.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, inserted indexes: IndexSet, for objects: [PHObject])
    
    /**
     A delegation method that is executed when there are changed objects.
     - Parameter photoLibrary: A reference to the PhotoLibrary.
     - Parameter removed indexes: An IndexSet of the changed indexes.
     - Parameter for objects: An Array of PHObjects that have been changed.
     */
    @objc
    optional func photoLibrary(photoLibrary: PhotoLibrary, changed indexes: IndexSet, for objects: [PHObject])
}

@objc(PhotoLibrary)
public class PhotoLibrary: NSObject {
    /// A reference to the PHCachingImageManager.
    public private(set) lazy var cachingImageManager = PHCachingImageManager()
    
    /// A reference to the collection PHFetchResult.
    public private(set) var collectionFetchResult: PHFetchResult<PHAssetCollection>?
    
    /// An array of PHFetchResult<PHAsset> types.
    public private(set) var assetFetchResults: [PHFetchResult<PHAsset>]!
    
    /// The assets used in the album.
    public private(set) var collections: [PhotoLibraryDataSource]! {
        willSet {
            guard .authorized == authorizationStatus else {
                return
            }
            
            cachingImageManager.stopCachingImagesForAllAssets()
        }
        
        didSet {
            guard .authorized == authorizationStatus else {
                return
            }
            
            for dataSource in collections {
                cachingImageManager.startCachingImages(for: dataSource.assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
            }
        }
    }
    
    /// A reference to a PhotoLibraryDelegate.
    public weak var delegate: PhotoLibraryDelegate?
    
    /// The current PHAuthorizationStatus.
    public var authorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    /// Deinitializer that unregisters itself from watching changes in the PHPhotoLibrary.
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    /// An initializer that prepares the PhotoLibrary.
    public override init() {
        super.init()
        prepare()
    }
    
    /**
     A method to request authorization from the user to enable photo library access. In order
     for this to work, set the "Privacy - Photo Library Usage Description" value in the
     application's info.plist.
     - Parameter _ completion: A completion block that passes in a PHAuthorizationStatus
     enum that describes the response for the authorization request.
     */
    public func requestAuthorization(_ completion: ((PHAuthorizationStatus) -> Void)? = nil) {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            guard let s = self else {
                return
            }
            
            switch status {
            case .authorized:
                s.delegate?.photoLibrary?(photoLibrary: s, status: .authorized)
                s.delegate?.photoLibrary?(authorized: s)
                completion?(.authorized)
                
            case .denied:
                s.delegate?.photoLibrary?(photoLibrary: s, status: .denied)
                s.delegate?.photoLibrary?(denied: s)
                completion?(.denied)
                
            case .notDetermined:
                s.delegate?.photoLibrary?(photoLibrary: s, status: .notDetermined)
                s.delegate?.photoLibrary?(notDetermined: s)
                completion?(.notDetermined)
                
            case .restricted:
                s.delegate?.photoLibrary?(photoLibrary: s, status: .restricted)
                s.delegate?.photoLibrary?(restricted: s)
                completion?(.restricted)
            }
        }
    }
    
    /**
     Fetch different PHAssetCollections asynchronously based on different types and subtypes
     with an optional completion block.
     - Parameter type: A PHAssetCollectionType.
     - Parameter subtype: A PHAssetCollectionSubtype.
     - Parameter completion: An optional completion block.
     */
    public func fetch(type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, completion: ([PhotoLibraryDataSource]) -> Void) {
        DispatchQueue.global(qos: .default).async { [weak self, type = type, subtype = subtype, completion = completion] in
            guard let s = self else {
                return
            }
            
            defer {
                DispatchQueue.main.async { [weak self] in
                    completion(s.collections)
                }
            }
            
            let options = PHFetchOptions()
            options.includeHiddenAssets = true
            options.includeAllBurstAssets = true
            options.wantsIncrementalChangeDetails = true
            
            s.collectionFetchResult = PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: options)
            
            s.collectionFetchResult?.enumerateObjects(options: [.concurrent]) { [weak self] (collection, _, _) in
                guard let s = self else {
                    return
                }
                
                let options = PHFetchOptions()
                let descriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                options.sortDescriptors = [descriptor]
                options.includeHiddenAssets = true
                options.includeAllBurstAssets = true
                options.wantsIncrementalChangeDetails = true
                
                var assets = [PHAsset]()
                let result = PHAsset.fetchAssets(in: collection, options: options)
                result.enumerateObjects(options: []) { (asset, _, _) in
                    assets.append(asset)
                }
                s.assetFetchResults.append(result)
                
                s.collections.append(PhotoLibraryDataSource(collection: collection, assets: assets))
            }
        }
    }
    
    /// A method used to prepare the instance object.
    private func prepare() {
        prepareAssetFetchResults()
        prepareCollections()
        prepareChangeObservers()
    }
    
    /// Prepares the collectionFetchResult.
    private func prepareAssetFetchResults() {
        assetFetchResults = [PHFetchResult<PHAsset>]()
    }
    
    /// Prepares the collections.
    private func prepareCollections() {
        collections = [PhotoLibraryDataSource]()
    }
    
    /// A method used to enable change observation.
    private func prepareChangeObservers() {
        PHPhotoLibrary.shared().register(self)
    }
    
//    public func moments(in momentList: PHCollectionList, options: PHFetchOptions?) -> [PHAssetCollection] {
//        var v = [PHAssetCollection]()
//        PHAssetCollection.fetchMoments(inMomentList: momentList, options: options).enumerateObjects(options: [.concurrent]) { (collection, _, _) in
//            v.append(collection)
//        }
//        return v
//    }
//    
//    public func fetch(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions?) -> PHFetchResult<PHAssetCollection> {
//        let result = PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: options)
//        return result
//    }
//    
    
    /**
     Performes an asynchronous change to the PHPhotoLibrary database.
     - Parameter _ block: A transactional block that ensures that
     all changes to the PHPhotoLibrary are atomic. 
     - Parameter completion: A completion block that is executed once the
     transaction has been completed.
     */
    public func performChanges(_ block: () -> Void, completion: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges(block, completionHandler: completion)
    }
    
    /**
     Retrieves an optional UIImage for a given PHAsset that allows for a targetSize
     and contentMode. 
     - Parameter for asset: A PHAsset.
     - Parameter targetSize: A CGSize.
     - Parameter contentMode: A PHImageContentMode.
     - Parameter options: A PHImageRequestOptions.
     - Parameter completion: A completion block.
     - Returns: A PHImageRequestID.
     */
    public func image(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?, completion: (UIImage?, [NSObject: AnyObject]?) -> Void) -> PHImageRequestID {
        return PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: completion)
    }
    
    /**
     Retrieves an optional Data object for a given PHAsset.
     - Parameter for asset: A PHAsset.
     - Parameter options: A PHImageRequestOptions.
     - Parameter completion: A completion block.
     - Returns: A PHImageRequestID.
     */
    public func data(for asset: PHAsset, options: PHImageRequestOptions?, completion: (Data?, String?, UIImageOrientation, [NSObject: AnyObject]?) -> Void) -> PHImageRequestID {
        return PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: completion)
    }

    /**
     Cance;s an image request for a given PHImageRequestID.
     - Parameter for requestID: A PHImageRequestID.
     */
    public func cancel(for requestID: PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(requestID)
    }
}

/// PHPhotoLibraryChangeObserver extension.
extension PhotoLibrary: PHPhotoLibraryChangeObserver {
    /**
     A delegation method that is fired when changes are made in the photo library.
     - Parameter _ changeInstance: A PHChange obejct describing the changes in the
     photo library.
     */
    public func photoLibraryDidChange(_ changeInfo: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let s = self else {
                return
            }
            
            // Notify about the general change.
            s.delegate?.photoLibrary?(photoLibrary: s, didChange: changeInfo)
            
            // Notifiy about specific changes.
            s.collectionFetchResult?.enumerateObjects(options: .concurrent) { [weak self, changeInfo = changeInfo] (collection, _, _) in
                guard let s = self else {
                    return
                }
                
                guard let details = changeInfo.changeDetails(for: collection) else {
                    return
                }
                
                guard let afterChanges = details.objectAfterChanges else {
                    return
                }
                
                s.delegate?.photoLibrary?(photoLibrary: s, beforeChanges: details.objectBeforeChanges, afterChanges: afterChanges, assetContentChanged: details.assetContentChanged, objectWasDeleted: details.objectWasDeleted)
            }
            
            s.assetFetchResults.forEach { [weak self] (result) in
                guard let s = self else {
                    return
                }
                
                if let details = changeInfo.changeDetails(for: result as! PHFetchResult<AnyObject>) {
                    s.delegate?.photoLibrary?(photoLibrary: s, fetchBeforeChanges: details.fetchResultBeforeChanges, fetchAfterChanges: details.fetchResultAfterChanges)
                    
                    guard details.hasIncrementalChanges else {
                        return
                    }
                    
                    if let removedIndexes = details.removedIndexes {
                        s.delegate?.photoLibrary?(photoLibrary: s, removed: removedIndexes, for: details.removedObjects)
                    }
                    
                    if let insertedIndexes = details.insertedIndexes {
                        s.delegate?.photoLibrary?(photoLibrary: s, inserted: insertedIndexes, for: details.insertedObjects)
                    }
                    
                    if let changedIndexes = details.changedIndexes {
                        s.delegate?.photoLibrary?(photoLibrary: s, changed: changedIndexes, for: details.changedObjects)
                    }
                }
            }
        }
    }
}
