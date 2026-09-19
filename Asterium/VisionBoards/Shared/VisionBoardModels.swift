//
//  VisionBoardModels.swift
//  Sterium
//
//  Shared between the main Sterium app and the SteriumShare extension.
//  Both targets compile these identical @Model types so they can open the
//  same App Group-backed SwiftData store.
//

import Foundation
import SwiftData

@Model
final class VisionBoard {
    var id: UUID = UUID()
    var name: String = ""
    var boardDescription: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // CloudKit-safe: optional to-many with inverse; cascade so a deleted board
    // removes its images.
    @Relationship(deleteRule: .cascade, inverse: \VisionBoardImage.board)
    var images: [VisionBoardImage]? = []

    // Folders that live inside this board. Cascade so deleting a board also
    // removes its folders (the board's images are cascade-removed above).
    @Relationship(deleteRule: .cascade, inverse: \VisionBoardFolder.board)
    var folders: [VisionBoardFolder]? = []

    init(id: UUID = UUID(), name: String, boardDescription: String = "") {
        self.id = id
        self.name = name
        self.boardDescription = boardDescription
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var imageCount: Int { images?.count ?? 0 }

    var sortedImages: [VisionBoardImage] {
        (images ?? []).sorted { $0.importedAt > $1.importedAt }
    }

    /// Images that sit at the root of the board (not inside any folder).
    var rootImages: [VisionBoardImage] {
        (images ?? []).filter { $0.folder == nil }.sorted { $0.importedAt > $1.importedAt }
    }

    var sortedFolders: [VisionBoardFolder] {
        (folders ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }
}

@Model
final class VisionBoardFolder {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // The board this folder lives inside. Inverse declared on VisionBoard.folders.
    var board: VisionBoard?

    // Images inside this folder. Nullify (NOT cascade) so deleting a folder
    // returns its images to the board root instead of destroying them.
    @Relationship(deleteRule: .nullify, inverse: \VisionBoardImage.folder)
    var images: [VisionBoardImage]? = []

    init(id: UUID = UUID(), name: String, board: VisionBoard? = nil) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.board = board
    }

    var imageCount: Int { images?.count ?? 0 }

    var sortedImages: [VisionBoardImage] {
        (images ?? []).sorted { $0.importedAt > $1.importedAt }
    }
}

@Model
final class VisionBoardImage {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var importedAt: Date = Date()

    // The actual imported image bytes. External storage keeps large blobs out of
    // the primary SQLite row and syncs to CloudKit as a CKAsset.
    @Attribute(.externalStorage) var imageData: Data = Data()

    var width: Double = 0
    var height: Double = 0
    var originalFilename: String?
    var contentType: String?
    var sourceApp: String?
    var sourceURLString: String?

    // CloudKit-safe optional inverse relationship to the owning board.
    var board: VisionBoard?

    // Optional folder within the board. nil means the image sits at the board
    // root. The board relationship stays populated even when folder is set.
    var folder: VisionBoardFolder?

    init(
        id: UUID = UUID(),
        imageData: Data,
        width: Double,
        height: Double,
        originalFilename: String? = nil,
        contentType: String? = nil,
        sourceApp: String? = nil,
        sourceURLString: String? = nil,
        board: VisionBoard? = nil,
        folder: VisionBoardFolder? = nil
    ) {
        self.id = id
        self.createdAt = Date()
        self.importedAt = Date()
        self.imageData = imageData
        self.width = width
        self.height = height
        self.originalFilename = originalFilename
        self.contentType = contentType
        self.sourceApp = sourceApp
        self.sourceURLString = sourceURLString
        self.board = board
        self.folder = folder
    }

    var aspectRatio: Double {
        guard width > 0, height > 0 else { return 1 }
        return width / height
    }
}
