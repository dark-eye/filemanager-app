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

ListView {
    id: root

    property FolderListModel folderListModel
    property string path: folderListModel.path
    model: folderListModel

    Component {
        id: confirmSingleDeleteDialog
        ConfirmDialog {
            property string filePath
            property string fileName
            title: i18n.tr("Delete?")
            text: i18n.tr("Are you sure you want to permanently delete") + " '" + fileName + "'?"

            onAccepted: {
                console.log("Delete accepted for filePath, fileName", filePath, fileName)

                PopupUtils.open(Qt.resolvedUrl("FileOperationProgressDialog.qml"),
                                root,
                                {
                                    title: i18n.tr("Deleting files"),
                                    // descriptionPrepend: i18n.tr("Operation in progress"),
                                    folderListModel: folderListModel
                                 }
                                )

                console.log("Doing delete")
                folderListModel.rm(filePath)
            }
        }
    }

    Component {
        id: confirmRenameDialog
        ConfirmDialogWithInput {
            // IMPROVE: this does not seem good: the backend excepts row and new name.
            // But what if new files are added/deleted in the background while user is
            // entering the new name? The indices change and wrong file is renamed.
            // Perhaps the backend should take as parameters the "old name" and "new name"?
            // This is not currently a problem since the backend does not poll changes in
            // the filesystem, but may be a problem in the future.
            property int modelRow

            title: i18n.tr("Rename?")
            text: i18n.tr("Enter a new name")

            onAccepted: {
                console.log("Rename accepted", inputText)
                if (inputText !== '') {
                    console.log("Rename commensed, modelRow/inputText", modelRow, inputText)
                    if (pageModel.rename(modelRow, inputText) === false) {
                        PopupUtils.open(Qt.resolvedUrl("NotifyDialog.qml"), delegate,
                                        {
                                            title: i18n.tr("Could not rename"),
                                            text: i18n.tr("Insufficient permissions or name already exists?")
                                         })

                    }
                } else {
                    console.log("Empty new name given, ignored")
                }
            }
        }
    }

    ActionSelectionPopover {
        id: actionSelectionPopover
        property var model
        actions: ActionList {
            Action {
                text: i18n.tr("Add as bookmark")
                // TODO
                onTriggered: print(text)
            }
            Action {
                text: i18n.tr("Show details")
                onTriggered: {
                    print(text)
                    PopupUtils.open(Qt.resolvedUrl("FileDetailsPopover.qml"),
                                    actionSelectionPopover.caller,
                                        { "model": actionSelectionPopover.model
                                        }
                                    )
                }
            }
            Action {
                text: i18n.tr("Delete")
                onTriggered: {
                    print(text)
                    PopupUtils.open(confirmSingleDeleteDialog, actionSelectionPopover.caller,
                                    { "filePath" : actionSelectionPopover.model.filePath,
                                      "fileName" : actionSelectionPopover.model.fileName }
                                    )
                }
            }            
            Action {
                text: i18n.tr("Rename")
                onTriggered: {
                    print(text)
                    PopupUtils.open(confirmRenameDialog, actionSelectionPopover.caller,
                                    { "modelRow"  : actionSelectionPopover.model.index,
                                      "inputText" : actionSelectionPopover.model.fileName
                                    })
                }
            }

        }
        // TODO: problem: clicking outside popup makes the click go through to the
        // folder listview, so for example you'd change directory while only trying
        // to dismiss the popup. Maybe SDK bug, if not have to do workarounds.
        // grabDismissAreaEvents seemed promising, but at least with onPressAndHold
        // makes background view scroll when moving mouse as if mouse button was still down.
        // grabDismissAreaEvents: false
        // Without this the popover jumps up at the start of the application. SDK bug?
        // Bug report has been made of these https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1152270
        visible: false
    }

    delegate: FolderListDelegate {
        id: delegate
        onClicked: {
            if (model.isDir) {
                if (model.isReadable && model.isExecutable) {
                    console.log("Changing to dir", model.filePath)
                    folderListModel.path = model.filePath
                } else {
                    PopupUtils.open(Qt.resolvedUrl("NotifyDialog.qml"), delegate,
                                    {
                                        title: i18n.tr("Folder not accessible"),
                                        text: i18n.tr("Can not access ") + model.fileName

                                     })
                }
            } else {
                console.log("Non dir clicked")
                PopupUtils.open(Qt.resolvedUrl("FileActionDialog.qml"), delegate,
                                {
                                    fileName: model.fileName,
                                    filePath: model.filePath

                                 })
            }
        }

        onPressAndHold: {
            console.log("FolderListDelegate onPressAndHold")
            actionSelectionPopover.caller = delegate
            actionSelectionPopover.model = model
            actionSelectionPopover.show();
        }
    }

    Scrollbar {
        flickableItem: root
        align: Qt.AlignTrailing
    }
}