import Sailfish.FileManager 1.0

FileItem {
    fileName: model.fileName
    mimeType: model.mimeType
    size: model.size
    isDir: model.isDir
    created: model.created
    modified: model.modified
}
