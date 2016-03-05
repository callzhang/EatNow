//
//  LocationCurrentView.swift
//  EatNow
//
//  Created by ishangzuIOS on 16/3/2.
//  Copyright © 2016年 modocache. All rights reserved.
//

import UIKit
protocol LocationCurrentViewDelegate:NSObjectProtocol{
    func selectedCurrentLocation()
}


class LocationCurrentView: UIView {
    
    var addressLabel = UILabel()
    weak var delegate :LocationCurrentViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.whiteColor()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.grayColor().CGColor
        
        addressLabel.backgroundColor = UIColor.clearColor()
        addressLabel.font = UIFont.systemFontOfSize(14)
        self.addSubview(addressLabel)
        
    }

    
    func showAddress(address:String){

        let addressRect = self.getTextRectSize(address, font: UIFont.systemFontOfSize(14), size: CGSizeMake(UIScreen.mainScreen().bounds.width, self.frame.height))
        self.frame = CGRectMake(0, 0, addressRect.width+8, self.frame.height);
        self.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2)
        addressLabel.frame = CGRectMake(4, 0, addressRect.width, self.frame.height)
        addressLabel.text = address
    
    }
    
    
    func setAddressLabelFrame(frame:CGRect){
        
    
    }
    
    
    
    func getTextRectSize(text:NSString,font:UIFont,size:CGSize) -> CGRect {
        
        let attributes = [NSFontAttributeName: font]
        
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        
        let rect:CGRect = text.boundingRectWithSize(size, options: option, attributes: attributes, context: nil)
        
        //        println("rect:\(rect)");
        
        return rect;
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        delegate?.selectedCurrentLocation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */


    
  
    
    
    

}
