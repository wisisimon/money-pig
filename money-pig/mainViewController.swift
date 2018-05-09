//
//  mainViewController.swift
//  money-pig
//
//  Created by Mac on 2018/5/7.
//  Copyright © 2018年 simonkira. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker

class mainViewController : UITableViewController {
    var postfeed: [Post] = []
    fileprivate var isLoadingPost = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 設定下拉更新
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.white
        refreshControl?.addTarget(self, action: #selector(loadRecentPosts), for: UIControlEvents.valueChanged)
        
        // 讀取最近posts
        loadRecentPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - 管理Post下載和display
    @objc fileprivate func loadRecentPosts() {
        
        isLoadingPost = true
        PostService.shared.getRecentPosts(start: postfeed.first?.timestamp, limit: 10) { (newPosts) in
            
            if newPosts.count > 0 {
                // 增加array到postfeed array
                self.postfeed.insert(contentsOf: newPosts, at: 0)
            }
            
            self.isLoadingPost = false
            
            if let _ = self.refreshControl?.isRefreshing {
                // 延遲0.5秒是為了讓動畫看起來更好
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self.refreshControl?.endRefreshing()
                    self.displayNewPosts(newPosts: newPosts)
                })
            } else {
                self.displayNewPosts(newPosts: newPosts)
            }
            
        }
    }
    
    private func displayNewPosts(newPosts posts: [Post]) {
        // 確認有得到新的posts去display
        guard posts.count > 0 else {
            return
        }
        
        // display posts插入到tableView
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for num in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: num, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
    
    @IBAction func openCamera(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: ImagePicker Delegate
extension mainViewController: ImagePickerDelegate {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        // 取得第一張圖片
        guard let image = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // 上傳照片到雲端
        PostService.shared.uploadImage(image: image) {
            self.dismiss(animated: true, completion: nil)
            self.loadRecentPosts()
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource Methods
extension mainViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        let currentPost = postfeed[indexPath.row]
        cell.configure(post: currentPost)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postfeed.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // We want to trigger the loading when the user reaches the last two rows
        guard !isLoadingPost, postfeed.count - indexPath.row == 2 else {
            return
        }
        
        isLoadingPost = true
        
        guard let lastPostTimestamp = postfeed.last?.timestamp else {
            isLoadingPost = false
            return
        }
        
        PostService.shared.getOldPosts(start: lastPostTimestamp, limit: 3) { (newPosts) in
            // Add new posts to existing arrays and table view
            var indexPaths:[IndexPath] = []
            self.tableView.beginUpdates()
            for newPost in newPosts {
                self.postfeed.append(newPost)
                let indexPath = IndexPath(row: self.postfeed.count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            self.tableView.insertRows(at: indexPaths, with: .fade)
            self.tableView.endUpdates()
            
            self.isLoadingPost = false
        }
    }
}
