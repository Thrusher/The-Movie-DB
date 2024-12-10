//
//  UICollectionViewLayoutExtension.swift
//  The Movie DB
//
//  Created by Patryk Drozd on 10/12/2024.
//

import UIKit

extension UICollectionViewLayout {
    static func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, environment -> NSCollectionLayoutSection? in
            let maxCellWidth: CGFloat = 180 // Maximum width for a cell
            let spacing: CGFloat = 16 // Desired spacing between cells

            // Calculate number of columns dynamically
            let availableWidth = environment.container.effectiveContentSize.width - (spacing * 2)
            let numberOfColumns = floor(availableWidth / maxCellWidth)
            let cellWidth = (availableWidth - (spacing * (numberOfColumns - 1))) / numberOfColumns
            let cellHeight = cellWidth * 1.5 // Maintain aspect ratio

            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(cellWidth),
                heightDimension: .absolute(cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(spacing)

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
            section.interGroupSpacing = spacing

            return section
        }
    }
}
