
//
//  NewsFeedCell.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/4/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

class NewsFeedCell: UITableViewCell {
    
    // @IBOutlet weak var jodelTextView: UITextView!
    @IBOutlet weak var jodelTextView: UITextView!

    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var uploadedImage: UIImageView!
    
    var onLikeButtonTapped : (() -> Void)? = nil
    
    var onchatButtonTapped : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        
        if let onLikeButtonTapped = self.onLikeButtonTapped {
            onLikeButtonTapped()
        }
    }
    
    @IBAction func chatButtonPressed(sender: AnyObject) {
        
        if let onchatButtonTapped = self.onchatButtonTapped {
            onchatButtonTapped()
        }
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}