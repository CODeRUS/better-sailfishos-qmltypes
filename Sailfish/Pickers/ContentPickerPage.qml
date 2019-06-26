/****************************************************************************
**
** Copyright (C) 2013-2017 Jolla Ltd.
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

        delegate: CategoryItem {
            text: categoryModel.category(index)
            iconSource: model.iconSource

            onClicked: {
                var props = {
                    title: contentPicker.title,
                    _lastAppPage: pageStack.previousPage(contentPicker),
                    _animationDuration: contentPicker._animationDuration,
                    _background: contentPicker._background
                }

                // Copy properties from model to the sub-page
                for (var i in model.properties) {
                    props[i] = model.properties[i]
                }

                var obj = pageStack.animatorPush(Qt.resolvedUrl(model.subview), props,
                                                 pageStack._transitionDuration === 0 ? PageStackAction.Immediate
                                                                                     : PageStackAction.Animated);
                obj.pageCompleted.connect(function(subview) {
                    subview.selectedContentChanged.connect(function() {
                        contentPicker._updateSelectedContent(subview.selectedContentProperties, subview.selectedContent)
                    })
                })
            }
        }

        VerticalScrollDecorator {}
    }

    CategoryModel {
        id: categoryModel
    }
}
