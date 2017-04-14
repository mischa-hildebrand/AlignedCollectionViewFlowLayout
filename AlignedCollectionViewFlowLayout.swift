//
//  AlignedCollectionViewFlowLayout.swift
//
//  Created by Mischa Hildebrand on 12/04/2017.
//  Copyright © 2017 Mischa Hildebrand.
//
//  Licensed under the terms of the MIT license:
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// A collection view layout that aligns the cells left or right
/// just like left- or right-aligned text, depending on the `cellAlignment`.
class AlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - 🦆 Type definitions
    
    /// Defines an alignment for UI elements.
    enum HorizontalAlignment {
        case left
        case right
    }
    
    /// Describes an axis with respect to which items can be horizontally aligned.
    struct HorizontalAlignmentAxis {
        
        /// Determines if items are aligned left or right of the axis.
        let alignment: HorizontalAlignment
        
        /// Defines the horizontal position of the axis.
        let xPosition: CGFloat
    }
    
    
    // MARK: - 🔶 Properties
    
    /// Determines if cells are left- or right-aligned in a row.
    ///
    /// - Note: The default is `.left`.
    var cellAlignment: HorizontalAlignment = .left
    
    /// The vertical axis with respect to which the cells are aligned.
    private var alignmentAxis: HorizontalAlignmentAxis? {
        switch cellAlignment {
        case .left:
            return HorizontalAlignmentAxis(alignment: .left, xPosition: sectionInset.left)
        case .right:
            guard let collectionViewWidth = collectionView?.frame.size.width else {
                return nil
            }
            return HorizontalAlignmentAxis(alignment: .right, xPosition: collectionViewWidth - sectionInset.right)
        }
    }
    
    
    // MARK: - 🅾️ Overrides
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        // 💡 IDEA:
        // The approach for computing a cell's frame is to create a rectangle that covers the current line.
        // Then we check if the previous cell's frame intersects with this rectangle.
        // If it does, the current item is not the first item in the line. Otherwise it is.
        // (Respectively for right-aligned cells.)
        //
        // +---------+----------------------------------------------------------------+---------+
        // |         |                                                                |         |
        // |         |     +------------+                                             |         |
        // |         |     |            |                                             |         |
        // | section |- - -|- - - - - - |- - - - +---------------------+ - - - - - - -| section |
        // |  inset  |     |intersection|        |                     |   line rect  |  inset  |
        // |         |- - -|- - - - - - |- - - - +---------------------+ - - - - - - -|         |
        // | (left)  |     |            |             current item                    | (right) |
        // |         |     +------------+                                             |         |
        // |         |     previous item                                              |         |
        // +---------+----------------------------------------------------------------+---------+
        //
        // ℹ️ We need this rather complicated approach because the first item in a line
        //    is not always left-aligned and the last item in a line is not always right-aligned:
        //    If there is only one item in a line UICollectionViewFlowLayout will center it.
        
        // We may not change the original layout attributes or UICollectionViewFlowLayout might complain.
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
            let alignmentAxis = alignmentAxis else {
                return nil
        }
        
        if layoutAttributes.representsClosestItemToAlignmentAxis(collectionViewLayout: self) {
            layoutAttributes.alignToAlignmentAxis(alignmentAxis)
        }
        else {
            layoutAttributes.alignToAdjacentItem(collectionViewLayout: self)
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // We may not change the original layout attributes or UICollectionViewFlowLayout might complain.
        let layoutAttributesObjects = copy(super.layoutAttributesForElements(in: rect))
        layoutAttributesObjects?.forEach({ (layoutAttributes) in
            setFrame(forLayoutAttributes: layoutAttributes)
        })
        return layoutAttributesObjects
    }
    
    
    // MARK: - 👷 Private layout helpers
    
    /// Sets the frame for the passed layout attributes object by calling the `layoutAttributesForItem(at:)` function.
    private func setFrame(forLayoutAttributes layoutAttributes: UICollectionViewLayoutAttributes) {
        if layoutAttributes.representedElementCategory == .cell { // Do not modify header views etc.
            let indexPath = layoutAttributes.indexPath
            if let newFrame = layoutAttributesForItem(at: indexPath)?.frame {
                layoutAttributes.frame = newFrame
            }
        }
    }
    
    /// The layout attributes object preceding the layout attributes object passed as a parameter.
    fileprivate func layoutAttributesForItem(beforeItemWithLayoutAttributes attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        
        let currentIndexPath = attributes.indexPath
        
        if currentIndexPath.item > 0 {
            let previousIndexPath = IndexPath(item: currentIndexPath.item - 1, section: currentIndexPath.section)
            return layoutAttributesForItem(at: previousIndexPath)
        }
        
        return nil
    }
    
    /// The layout attributes object following the layout attributes object passed as a parameter.
    fileprivate func layoutAttributesForItem(afterItemWithLayoutAttributes attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes? {
        
        let currentIndexPath = attributes.indexPath
        guard let itemCount = collectionView?.numberOfItems(inSection: currentIndexPath.section) else {
            return nil
        }
        
        if currentIndexPath.item < itemCount - 1 {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            return layoutAttributesForItem(at: nextIndexPath)
        }
        
        return nil
    }
    
    /// Determines if the `firstItemAttributes`' frame is in the same line
    ///  as the `secondItemAttributes`' frame.
    ///
    /// - Parameters:
    ///   - firstItemAttributes: The first layout attributes item to check.
    ///   - secondItemAttributes: The second layout attributes item to check.
    /// - Returns: `true` if the frames of the two layout attributes are in the same line, else `false`.
    ///            `false` is also returned when the layout's `collectionView` property is `nil`.
    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool {
        guard let collectionViewWidth = collectionView?.frame.size.width else {
            return false
        }
        let lineWidth = collectionViewWidth - sectionInset.left - sectionInset.right
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(x: sectionInset.left,
                               y: firstItemFrame.origin.y,
                               width: lineWidth,
                               height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }
    
    /// Creates a deep copy of the passed array by copying all its items.
    ///
    /// - Parameter layoutAttributesArray: The array to be copied.
    /// - Returns: A deep copy of the passed array.
    private func copy(_ layoutAttributesArray: [UICollectionViewLayoutAttributes]?) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArray?.map{ $0.copy() } as? [UICollectionViewLayoutAttributes]
    }
    
}


// MARK: - 👷 Layout attributes helpers

extension UICollectionViewLayoutAttributes {
    
    /// Checks if the cell represented by this attributes object
    /// is the one closest to the alignment axis in this line.
    ///
    /// - Parameter collectionViewLayout: The collection view layout that defines the cell alignment etc.
    /// - Returns: `true` if there is no other cell between the layout axis
    ///            and the cell represented by this attribute, else `false`.
    fileprivate func representsClosestItemToAlignmentAxis(collectionViewLayout: AlignedCollectionViewFlowLayout) -> Bool {
        
        // The layout attributes for the item that's the left or right neighbor of the item represented by self,
        // depending on the cell alignment.
        var neighborItemAttributes: UICollectionViewLayoutAttributes?
        
        switch collectionViewLayout.cellAlignment {
            
        case .left:
            neighborItemAttributes = collectionViewLayout.layoutAttributesForItem(beforeItemWithLayoutAttributes: self)
            
        case .right:
            neighborItemAttributes = collectionViewLayout.layoutAttributesForItem(afterItemWithLayoutAttributes: self)
            
        }
        
        if let neighborItemAttributes = neighborItemAttributes {
            // If the neighbor cell is not in the same line as the cell represented by self,
            // then the cell represented by self is the one closest to the alignment axis.
            return !collectionViewLayout.isFrame(for: self, inSameLineAsFrameFor: neighborItemAttributes)
        }
        else {
            // There is no neighbor item, so this is the only item in this line.
            return true
        }
    }
    
    /// Moves the layout attributes object's frame next to the alignment axis.
    fileprivate func alignToAlignmentAxis(_ alignmentAxis: AlignedCollectionViewFlowLayout.HorizontalAlignmentAxis) {
        switch alignmentAxis.alignment {
        case .left:
            frame.origin.x = alignmentAxis.xPosition
        case .right:
            frame.origin.x = alignmentAxis.xPosition - frame.size.width
        }
    }
    
    /// Moves the layout attributes object's frame next to the neighbor cell's frame,
    /// leaving a spacing defined by `minimumInteritemSpacing`.
    fileprivate func alignToAdjacentItem(collectionViewLayout: AlignedCollectionViewFlowLayout) {
        let itemSpacing = collectionViewLayout.minimumInteritemSpacing
        switch collectionViewLayout.cellAlignment {
        case .left:
            if let leftAdjacentItemAttributes = collectionViewLayout.layoutAttributesForItem(beforeItemWithLayoutAttributes: self) {
                frame.origin.x = leftAdjacentItemAttributes.frame.maxX + itemSpacing
            }
        case .right:
            if let rightAdjacentItemAttributes = collectionViewLayout.layoutAttributesForItem(afterItemWithLayoutAttributes: self) {
                frame.origin.x = rightAdjacentItemAttributes.frame.minX - itemSpacing - frame.size.width
            }
        }
    }
    
}
