//
//  CustomDismissAnimationController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/28/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class CustomDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
        let containerView = transitionContext.containerView()
        toViewController.view.frame = finalFrameForVC
        toViewController.view.alpha = 0.5
        containerView!.addSubview(toViewController.view)
        containerView!.sendSubviewToBack(toViewController.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            fromViewController.view.frame = CGRectInset(fromViewController.view.frame, fromViewController.view.frame.size.width / 2, fromViewController.view.frame.size.height / 2)
            toViewController.view.alpha = 1.0
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
    }

}
