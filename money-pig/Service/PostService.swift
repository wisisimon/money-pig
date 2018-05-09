//
//  PostService.swift
//  money-pig
//
//  Created by Mac on 2018/5/5.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import Foundation
import Firebase

final class PostService {
    
    // MARK: - Properties
    
    static let shared: PostService = PostService()
    
    private init() { }
    
    // MARK: - Firebase Database References
    
    let BASE_DB_REF: DatabaseReference = Database.database().reference()
    
    let POST_DB_REF: DatabaseReference = Database.database().reference().child("posts")
    
    // MARK: - Firebase Storage Reference
    
    let PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child("photos")
    
    // MARK: - Firebase 上傳與下載方法
    
    func uploadImage(image: UIImage, completionHandler: @escaping () -> Void) {
        
        //產生一個唯一的貼文 ID 並準備貼文資料庫的參照
        let postDatabaseRef = POST_DB_REF.childByAutoId()
        
        // 使用這唯一的 key 作為圖片名稱並準備 Storage 參照
        let imageStorageRef = PHOTO_STORAGE_REF.child("\(postDatabaseRef.key).jpg")
        
        // 調整圖片大小
        let scaledImage = image.scale(newWidth: 640.0)
        
        guard let imageData = UIImageJPEGRepresentation(scaledImage, 0.9) else {
            return
        }
        
        // 建立檔案的元資料
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        // 上傳任務準備
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)
        
        // 觀察上傳狀態
        uploadTask.observe(.success) { (snapshot) in
            
            guard let displayName = Auth.auth().currentUser?.displayName else {
                return
            }
            // 藉由storage參照callback回來的URL在資料庫加入一個ref
            imageStorageRef.downloadURL(completion: { (url, error) in
                let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
                if let downloadUrl = url {
                    let post: [String : Any] = [Post.PostInfoKey.imageFileURL : downloadUrl.absoluteString,
                                                Post.PostInfoKey.votes : Int(0),
                                                Post.PostInfoKey.user : displayName,
                                                Post.PostInfoKey.timestamp : timestamp]

                    postDatabaseRef.setValue(post)
                }
            })
            
            completionHandler()
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Uploading... \(percentComplete)% complete")
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
        }
    }
    
    func getRecentPosts(start timestamp: Int? = nil, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        var postQuery = POST_DB_REF.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            // If the timestamp is specified, we will get the posts with timestamp newer than the given value
            postQuery = postQuery.queryStarting(atValue: latestPostTimestamp + 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        } else {
            // Otherwise, we will just get the most recent posts
            postQuery = postQuery.queryLimited(toLast: limit)
        }
        
        // Call Firebase API to retrieve the latest records
        postQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            if newPosts.count > 0 {
                // Order in descending order (i.e. the latest post becomes the first post)
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            
            completionHandler(newPosts)
            
        })
        
    }
    
    func getOldPosts(start timestamp: Int, limit: UInt, completionHandler: @escaping ([Post]) -> Void) {
        
        let postOrderedQuery = POST_DB_REF.queryOrdered(byChild: Post.PostInfoKey.timestamp)
        let postLimitedQuery = postOrderedQuery.queryEnding(atValue: timestamp - 1, childKey: Post.PostInfoKey.timestamp).queryLimited(toLast: limit)
        
        postLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var newPosts: [Post] = []
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                print("Post key: \(item.key)")
                let postInfo = item.value as? [String: Any] ?? [:]
                
                if let post = Post(postId: item.key, postInfo: postInfo) {
                    newPosts.append(post)
                }
            }
            
            // Order in descending order (i.e. the latest post becomes the first post)
            newPosts.sort(by: { $0.timestamp > $1.timestamp })
            
            completionHandler(newPosts)
            
        })
        
    }
}
