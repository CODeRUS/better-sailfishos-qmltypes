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

PickerDialog {
    id: contentPickerDialog

    property string title

    // We are single selection, so don't show the forward navigation indicator
    forwardNavigation: false

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? categoryList : __silica_applicationwindow_instance.contentItem
        targetPage: contentPickerDialog
    }

    SilicaListView {
        id: categoryList

        anchors.fill: parent
        header: PageHeader {
            id: dialogHeader
            title: contentPickerDialog.title
        }

        model: categoryModel

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
                    acceptDestination: pageStack.previousPage(contentPickerDialog),
                    acceptDestinationAction: PageStackAction.Pop,
                    _selectedModel: contentPickerDialog._selectedModel,
                    _animationDuration: contentPickerDialog._animationDuration,
                    _background: contentPickerDialog._background
                }, pageStack._transitionDuration === 0 ? PageStackAction.Immediate : PageStackAction.Animated);

                subview.accepted.connect(function() {
                    contentPickerDialog._dialogDone(DialogResult.Accepted)
                })
            }
        }

        VerticalScrollDecorator {}
    }


    CategoryModel {
        id: categoryModel
        multiPicker: true
    }
}
