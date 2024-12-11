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
            let maxCellWidth: CGFloat = 180
            let spacing: CGFloat = 16
            let minimumColumns: CGFloat = 2

            let availableWidth = environment.container.effectiveContentSize.width - (spacing * 2)
            let calculatedColumns = floor(availableWidth / maxCellWidth)
            let numberOfColumns = max(minimumColumns, calculatedColumns)
            let cellWidth = (availableWidth - (spacing * (numberOfColumns - 1))) / numberOfColumns
            let cellHeight = cellWidth * 1.5

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(cellWidth),
                heightDimension: .absolute(cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
            section.interGroupSpacing = spacing

            return section
        }
    }
}
