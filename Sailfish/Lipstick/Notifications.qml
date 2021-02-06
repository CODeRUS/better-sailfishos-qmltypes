pragma Singleton
import QtQml 2.2

QtObject {
    function iconSource(identifier, themeColor) {
        if (identifier === undefined || identifier === "") {
            return ""
        } else if (identifier.indexOf("data:image") === 0) {
            return identifier
        } else if (identifier.indexOf("/") === 0) {
            return "image://nemoThumbnail/" + identifier
        } else if (identifier.indexOf("file://") === 0) {
            return "image://nemoThumbnail/" + identifier.substring(7)
        } else {
            var themeValue
            if (identifier.indexOf("image://theme/") === 0) {
                themeValue = identifier
            } else {
                themeValue = "image://theme/" + identifier
            }

            return themeValue + (!!themeColor ? ("?" + themeColor + "&grayscale_only") : "")
        }
    }
}
