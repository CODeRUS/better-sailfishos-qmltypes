import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.FileManager 1.0
import Nemo.FileManager 1.0

BusyView {
    id: root

    property alias model: archiveModel
    property alias path: archiveModel.path
    property alias archiveFile: archiveModel.archiveFile
    property alias fileName: archiveModel.fileName
    property string baseExtractionDirectory: StandardPaths.download

    signal archiveExtracted(string containingFolder)
    signal showInfo(string info)

    function extractAllFiles(targetPath) {
        var target = _buildExtractionDirectory(false, true, model.baseName)
        return archiveModel.extractAllFiles(target)
    }

    function extractFile(fileName, isDir) {
        var targetDir = _buildExtractionDirectory(isDir, false, fileName)
        return archiveModel.extractFile(fileName, targetDir)
    }

    function appendPath(fileName) {
        return archiveModel.appendPath(fileName)
    }

    function _buildExtractionDirectory(isDir, isArchive, dirName) {
        if (isArchive || isDir) {
            return baseExtractionDirectory + "/" + dirName
        } else {
            return baseExtractionDirectory
        }
    }

    // Grace timer
    Timer {
        id: graceTimer
        interval: 500
        running: model.extracting
    }

    busy: model.extracting && !graceTimer.running
    enabled: busy
    //% "Extracting"
    text: qsTrId("filemanager-la-extracting")

    ArchiveModel {
        id: archiveModel
        autoRename: true
        onErrorStateChanged: {
            switch (errorState) {
            case ArchiveModel.ErrorUnsupportedArchiveFormat:
                //% "Unsupported archive format"
                showInfo(qsTrId("filemanager-la-unsupported_archive_format"))
                break
            case ArchiveModel.ErrorArchiveNotFound:
                //% "Archive file is not found"
                showInfo(qsTrId("filemanager-la-archive_not_found"))
                break
            case ArchiveModel.ErrorArchiveOpenFailed:
                //% "Opening archive failed"
                showInfo(qsTrId("filemanager-la-opening_archive_failed"))
                break
            case ArchiveModel.ErrorArchiveExtractFailed:
                //% "Extract failed"
                showInfo(qsTrId("filemanager-la-extract_failed"))
                break
            case ArchiveModel.ErrorExtractingInProgress:
                //% "Extracting in progress"
                showInfo(qsTrId("filemanager-la-extracting_in_progress"))
                break
            }
        }

        onFilesExtracted: {
            if (isDir) {
                //% "Directory %1 extracted"
                showInfo(qsTrId("filemanager-la-directory_extracted").arg(entryName))
            } else if (entries && entries.length == 1) {
                //% "Extracted %1"
                showInfo(qsTrId("filemanager-la-file_extracted").arg(entryName))
            } else {
                //% "%1 extracted"
                showInfo(qsTrId("filemanager-la-archive_extracted").arg(fileName))
                root.archiveExtracted(path)
            }
        }
    }
}
