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

    forwardNavigation: _selectedCount > 0
    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? categoryList : __silica_applicationwindow_instance.contentItem
        targetPage: contentPickerDialog
    }

    SilicaListView {
        id: categoryList

        anchors.fill: parent
        header: Loader {
            id: headerLoader
            width: parent.width

            sourceComponent: _selectedCount > 0 ? dialogHeader : pageHeader

            Component {
                id: pageHeader
                PageHeader {
                    title: contentPickerDialog.title
                }
            }

            Component {
                id: dialogHeader
                PickerDialogHeader {
                    showBack: !_clearOnBackstep
                    selectedCount: _selectedCount
                    _glassOnly: _background
                }
            }
        }

        model: categoryModel

        delegate: CategoryItem {
            text: categoryModel.category(index)
            iconSource: model.iconSource

            onClicked: {
                var props = {
                    acceptDestinationAction: PageStackAction.Pop,
                    _selectedModel: contentPickerDialog._selectedModel,
                    _animationDuration: contentPickerDialog._animationDuration,
                    _background: contentPickerDialog._background
                }


                // Copy properties from model to the sub-page
                for (var i in model.properties) {
                    props[i] = model.properties[i]
                }

                // Accept destination cannot be set, if forward navigation is not enabled
                if (model.acceptDestination) {
                    props["acceptDestination"] = pageStack.previousPage(contentPickerDialog)
                } else {
                    props["_maskedAcceptDestination"] = pageStack.previousPage(contentPickerDialog)
                }

                var obj = pageStack.animatorPush(Qt.resolvedUrl(model.subview), props,
                                                 pageStack._transitionDuration === 0 ? PageStackAction.Immediate
                                                                                     : PageStackAction.Animated);
                obj.pageCompleted.connect(function(subview) {
                    subview.accepted.connect(function() {
                        contentPickerDialog._dialogDone(DialogResult.Accepted)
                    })
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
