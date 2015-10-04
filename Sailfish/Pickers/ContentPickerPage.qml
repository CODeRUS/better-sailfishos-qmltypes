import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

PickerPage {
    id: contentPicker

    // ContentType.Image, ContentType.Video, ContentType.Music
    // ContentType.Document, ContentType.Person
    property int selectedContentType

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? categoryList : __silica_applicationwindow_instance.contentItem
        targetPage: contentPicker
    }

    SilicaListView {
        id: categoryList

        anchors.fill: parent
        model: categoryModel

        header: PageHeader {
            id: pageHeader
            title: contentPicker.title
        }

        delegate: ListItem {
            Label {
                id: categoryName

                text: categoryList.model.category(index)
                color: down ? Theme.highlightColor : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
            }

            onClicked: {
                var subview = pageStack.push(Qt.resolvedUrl(model.subview), {
                    title: contentPicker.title,
                    _lastAppPage: pageStack.previousPage(contentPicker),
                    _animationDuration: contentPicker._animationDuration,
                    _background: contentPicker._background
                }, pageStack._transitionDuration === 0 ? PageStackAction.Immediate : PageStackAction.Animated);

                subview.selectedContentChanged.connect(function() {
                    contentPicker.selectedContentProperties = subview.selectedContentProperties
                    contentPicker.selectedContent = subview.selectedContent
                    contentPicker.selectedContentType = model.contentType
                })
            }
        }

        VerticalScrollDecorator {}
    }

    CategoryModel {
        id: categoryModel
    }
}
