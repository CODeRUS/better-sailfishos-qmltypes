import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import Sailfish.Ambience 1.0

Dialog {
    id: root

    property bool _colorSelected
    property color _highlightColor: _colorSelected ? Theme.highlightColor : wizardManager.defaultHighlightColor()

    // allow picker to be accepted if colours are not available
    canAccept: _colorSelected || picker.colorCount == 0

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        Column {
            id: contentColumn            
            width: parent.width

            DialogHeader {
                id: header
                dialog: root
                _backgroundVisible: false
                //: Heading for page that allows the user to change the current ambience colors
                //% "Ambience"
                title: qsTrId("startupwizard-he-ambience")
            }

            Label {
                x: Theme.paddingLarge
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                color: root._highlightColor

                //% "Choose your favorite color"
                text: qsTrId("startupwizard-la-choose_color")
            }

            AmbienceColorPicker {
                id: picker

                onColorChanged: {
                    root._colorSelected = true
                    root.accept()
                }
            }
        }
    }

    StartupWizardManager {
        id: wizardManager
    }
}
