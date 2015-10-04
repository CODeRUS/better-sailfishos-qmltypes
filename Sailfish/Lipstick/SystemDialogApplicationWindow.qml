import QtQuick 2.0
import Sailfish.Silica 1.0

// This declares an ApplicationWindow with an empty page for SystemDialog, it is not declared in
// SystemDialog as __silica_applicationwindow_instance cannot be resolved by Page if
// ApplicationWindow is not the root item.

ApplicationWindow {
    initialPage: Component { Page {
        allowedOrientations: Orientation.All
    } }
}
