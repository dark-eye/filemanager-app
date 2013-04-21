/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Arto Jalkanen <ajalkane@gmail.com>
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import org.nemomobile.folderlistmodel 1.0

Page {
    id: root
    anchors.margins: units.gu(2)

    FolderListModel {
        id: pageModel
        path: homePath()
    }

    Component {
        id: createFolderDialog
        ConfirmDialogWithInput {
            title: i18n.tr("Create folder?")
            text: i18n.tr("Enter name for new folder")

            onAccepted: {
                console.log("Create folder accepted", inputText)
                if (inputText !== '') {
                    pageModel.mkdir(inputText)
                } else {
                    console.log("Empty directory name, ignored")
                }
            }
        }
    }

    tools: ToolbarActions {
        lock: true
        active: true

        back: Action {
            text: i18n.tr("Up")
            onTriggered: {
                pageModel.path = pageModel.parentPath
                console.log("Up triggered")
            }
            visible: pageModel.path != "/"
        }

        // IMPROVE: would rather have this as more hidden, in a separate menu that has
        // file manipulation operations
        Action {
            text: i18n.tr("Create folder")
            onTriggered: {
                print(text)
                PopupUtils.open(createFolderDialog)
            }
        }

        Action {
            text: i18n.tr("Home")
            onTriggered: {
                pageModel.path = pageModel.homePath()
                console.log("Home triggered")
            }
        }
    }

    Column {
        anchors.centerIn: root
        Label {
            text: i18n.tr("No files")
            fontSize: "large"
            visible: folderListView.count == 0 && !pageModel.awaitingResults
        }
        ActivityIndicator {
            running: pageModel.awaitingResults
            width: units.gu(8)
            height: units.gu(8)
        }
    }

    FolderListView {
        id: folderListView

        folderListModel: pageModel
        anchors.fill: parent        
    }

    // Errors from model
    Connections {
        target: pageModel
        onError: {
            console.log("FolderListModel Error Title/Description", errorTitle, errorMessage)
            PopupUtils.open(Qt.resolvedUrl("NotifyDialog.qml"), root,
                            {
                                // Unfortunately title can not handle too long texts. TODO: bug report
                                // title: i18n.tr(errorTitle),
                                title: i18n.tr("File operation error"),
                                text: errorTitle + ": " + errorMessage
                            })
        }
    }
}