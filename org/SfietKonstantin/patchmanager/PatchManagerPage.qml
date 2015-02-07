/*
 * Copyright (C) 2014 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * The names of its contributors may not be used to endorse or promote
 *     products derived from this software without specific prior written
 *     permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0
import org.SfietKonstantin.patchmanager 1.0

Page {
    id: container

    onStatusChanged: {
        if (status == PageStatus.Active && container.state == "") {
            listPatchDbusInterface.listPatches()
            checkLipstickDBus.checkLipstick()
        }
    }

    DBusInterface {
        id: listPatchDbusInterface
        destination: "org.SfietKonstantin.patchmanager"
        path: "/org/SfietKonstantin/patchmanager"
        iface: "org.SfietKonstantin.patchmanager"
        busType: DBusInterface.SystemBus
        function listPatches() {
            typedCallWithReturn("listPatches", [], function (patches) {
                for (var i = 0; i < patches.length; i++) {
                    patchModel.append({"patch": patches[i][0],
                                  "name": patches[i][1],
                                  "description": patches[i][2],
                                  "category": patches[i][3],
                                  "categoryCode": patches[i][4],
                                  "available": patches[i][5]})
                }
            })
        }
    }

    DBusInterface {
        id: checkLipstickDBus
        destination: "org.SfietKonstantin.patchmanager"
        path: "/org/SfietKonstantin/patchmanager"
        iface: "org.SfietKonstantin.patchmanager"
        busType: DBusInterface.SystemBus
        function checkLipstick() {
            typedCallWithReturn("checkLipstick", [], function (status) {
                var isOk = status[0]
                var alteredOriginalFiles = status[1]
                var alteredBackupFiles = status[2]

                if (!isOk) {
                    var page = pageStack.push(Qt.resolvedUrl("LipstickWarningDialog.qml"))
                    for (var i = 0; i < alteredOriginalFiles.length; i++) {
                        page.model.append({"section": "Altered original files",
                                           "file": alteredOriginalFiles[i]})
                    }

                    for (i = 0; i < alteredBackupFiles.length; i++) {
                        page.model.append({"section": "Altered backup files",
                                           "file": alteredBackupFiles[i]})
                    }
                }
                container.state = "ready"
            })
        }
    }

    PatchManager {
        id: patchManager
    }


    BusyIndicator {
        id: indicator
        running: visible
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }


    SilicaListView {
        id: view
        visible: false
        anchors.fill: parent
        header: PageHeader {
            title: "patchmanager"
        }
        model: ListModel {
            id: patchModel
        }
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader {
            text: section
        }
        section.property: "category"

        delegate: BackgroundItem {
            id: background
            property bool applied: false
            property bool canApply: true
            property bool applying: !appliedSwitch.enabled
            function doPatch() {
                appliedSwitch.enabled = false
                appliedSwitch.busy = true
                if (!background.applied) {
                    listPatchDbusInterface.typedCallWithReturn("applyPatch",
                                                      [{"type": "s", "value": model.patch}],
                    function (ok) {
                        if (ok) {
                            background.applied = true
                        }
                        appliedSwitch.busy = false
                        patchManager.patchToggleService(model.patch, model.categoryCode)
                        checkApplicability()
                    })
                } else {
                    listPatchDbusInterface.typedCallWithReturn("unapplyPatch",
                                                      [{"type": "s", "value": model.patch}],
                    function (ok) {
                        if (ok) {
                            background.applied = false
                        }
                        appliedSwitch.busy = false
                        patchManager.patchToggleService(model.patch, model.categoryCode)
                        if (!model.available) {
                            patchModel.remove(model.index)
                        } else {
                            checkApplicability()
                        }
                    })
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("PatchPage.qml"),
                               {"name": model.name, "description": model.description,
                                "available": model.available, "delegate": background})
            }

            function checkApplicability() {
                appliedSwitch.enabled = background.canApply
            }

            Component.onCompleted: {
                listPatchDbusInterface.typedCallWithReturn("isPatchApplied",
                                                  [{"type": "s", "value": model.patch}],
                function (applied) {
                    background.applied = applied
                    checkApplicability()
                })
            }

            Switch {
                id: appliedSwitch
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                automaticCheck: false
                checked: background.applied
                onClicked: background.doPatch()
                enabled: false
            }

            Label {
                anchors.left: appliedSwitch.right; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
                color: background.down ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
            }
        }

        PullDownMenu {
            MenuItem {
                text: "About"
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: "Restart preloaded services"
                enabled: patchManager.appsNeedRestart || patchManager.homescreenNeedRestart
                onClicked: pageStack.push(Qt.resolvedUrl("RestartServicesDialog.qml"),
                                                         {"patchManager": patchManager})
            }
        }

        ViewPlaceholder {
            enabled: patchModel.count == 0
            text: qsTr("No patch available")
        }

        VerticalScrollDecorator {}
    }

    states: [
        State {
            name: "ready"
            PropertyChanges {
                target: indicator
                visible: false
            }
            PropertyChanges {
                target: view
                visible: true
            }
        }
    ]
}


