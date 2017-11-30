/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import "private"

PickerPage {
    id: contentPicker

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

        delegate: BackgroundItem {
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
                    contentPicker._updateSelectedContent(subview.selectedContentProperties, subview.selectedContent)
                })
            }
        }

        VerticalScrollDecorator {}
    }

    CategoryModel {
        id: categoryModel
    }
}
