import QtQuick 2.0
import QtSystemInfo 5.0

StorageInfo {
    id: storages
    function removableDrives() {
        var res = [], i, path;
        for (i = 0; i < allLogicalDrives.length; ++i) {
            path = allLogicalDrives[i];
            if (driveType(path) === StorageInfo.RemovableDrive)
                res.push({path: path
                          , available: availableDiskSpace(path)
                          , total: totalDiskSpace(path)});
        }
        return res;
    }
}

