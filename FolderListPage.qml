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
    anchors.fill: parent

    title: folderName(folder)

    property variant fileView: root

    property bool showHiddenFiles: false

    onShowHiddenFilesChanged: {
        pageModel.showHiddenFiles = root.showHiddenFiles
    }

    property string sortingMethod: "Name"

    onSortingMethodChanged: {
        console.log("Sorting by: " + sortingMethod)
        if (sortingMethod === "Name") {
            pageModel.sortBy = FolderListModel.SortByName
        } else if (sortingMethod === "Date") {
            pageModel.sortBy = FolderListModel.SortByDate
        } else {
            // Something fatal happened!
            console.log("ERROR: Invalid sort type:", sortingMethod)
        }
    }

    property bool sortAccending: true

    onSortAccendingChanged: {
        console.log("Sorting accending: " + sortAccending)

        if (sortAccending) {
            pageModel.sortOrder = FolderListModel.SortAscending
        } else {
            pageModel.sortOrder = FolderListModel.SortDescending
        }
    }

    // This stores the location using ~ to represent home
    property string folder
    property string homeFolder: "~"

    // This replaces ~ with the actual home folder, since the
    // plugin doesn't recognize the ~
    property string path: folder.replace("~", pageModel.homePath())

    function goHome() {
        goTo(root.homeFolder)
    }

    function goTo(location) {
        // Since the FolderListModel returns paths using the actual
        // home folder, this replaces with ~ before actually going
        // to the specified folder
        while (location !== '/' && location.substring(location.lastIndexOf('/')+1) === "") {
            location = location.substring(0, location.length - 1)
        }

        root.folder = location.replace(pageModel.homePath(), "~")
        refresh()
    }

    function refresh() {
        pageModel.refresh()
    }

    // FIXME: hard coded path for icon, assumes Ubuntu desktop icon available.
    // Nemo mobile has icon provider. Have to figure out what's the proper way
    // to get "system wide" icons in Ubuntu Touch, or if we have to use
    // icons packaged into the application. Both folder and individual
    // files will need an icon.
    // TODO: Remove isDir parameter and use new model functions
    function fileIcon(file, isDir) {
        file = file.replace(pageModel.homePath(), "~")
        if (file === "~") {
            return "/usr/share/icons/ubuntu-mono-dark/places/48/folder-home.svg"
        } else if (file === i18n.tr("~/Desktop")) {
            return "/usr/share/icons/Humanity/places/48/user-desktop.svg"
        } else if (file === i18n.tr("~/Documents")) {
            return "/usr/share/icons/Humanity/places/48/folder-documents.svg"
        } else if (file === i18n.tr("~/Downloads")) {
            return "/usr/share/icons/Humanity/places/48/folder-downloads.svg"
        } else if (file === i18n.tr("~/Music")) {
            return "/usr/share/icons/Humanity/places/48/folder-music.svg"
        } else if (file === i18n.tr("~/Pictures")) {
            return "/usr/share/icons/Humanity/places/48/folder-pictures.svg"
        } else if (file === i18n.tr("~/Videos")) {
            return "/usr/share/icons/Humanity/places/48/folder-videos.svg"
        } else if (file === "/") {
            return "/usr/share/icons/Humanity/devices/48/drive-harddisk.svg"
        }

        if (isDir) {
            return "/usr/share/icons/Humanity/places/48/folder.svg"
        } else {
            return "/usr/share/icons/Humanity/mimes/48/empty.svg"
        }
    }

    function folderName(folder) {
        folder = folder.replace(pageModel.homePath(), "~")

        if (folder === root.homeFolder) {
            return i18n.tr("Home")
        } else if (folder === "/") {
            return i18n.tr("File System")
        } else {
            return folder.substr(folder.lastIndexOf('/') + 1)
        }
    }

    function pathName(folder) {
        if (folder === "/") {
            return "/"
        } else {
            return folder.substr(folder.lastIndexOf('/') + 1)
        }
    }

    function pathExists(path) {
        path = path.replace("~", pageModel.homePath())

        if (path === '/')
            return true

        if(path.charAt(0) === '/') {
            console.log("Directory: " + path.substring(0, path.lastIndexOf('/')+1))
            repeaterModel.path = path.substring(0, path.lastIndexOf('/')+1)
            console.log("Sub dir: " + path.substring(path.lastIndexOf('/')+1))
            if (path.substring(path.lastIndexOf('/')+1) !== "" && !repeaterModel.cdIntoPath(path.substring(path.lastIndexOf('/')+1))) {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }

    property bool loading: pageModel.awaitingResults

    FolderListModel {
        id: pageModel

        path: root.path

        // Properties to emulate a model entry for use by FileDetailsPopover
        property bool isDir: true
        property string fileName: pathName(pageModel.path)
        property string fileSize: (folderListView.count === 1
                                   ? i18n.tr("1 file")
                                   : i18n.tr("%1 files").arg(folderListView.count))
        property date creationDate: pageModel.pathCreatedDate
        property date modifiedDate: pageModel.pathModifiedDate
        property bool isWriteable: pageModel.pathIsWriteable
        property bool isReadable: true
        property bool isExecutable: true
    }

    FolderListModel {
        id: repeaterModel
        path: root.folder

        onPathChanged: {
            console.log("Path: " + repeaterModel.path)
        }
    }

    ActionSelectionPopover {
        id: folderActionsPopover
        objectName: "folderActionsPopover"

        actions: ActionList {
            Action {
                text: i18n.tr("Create New Folder")
                onTriggered: {
                    print(text)

                    PopupUtils.open(createFolderDialog, root)
                }
            }

            // TODO: Disabled until backend supports creating files
//            Action {
//                text: i18n.tr("Create New File")
//                onTriggered: {
//                    print(text)

//                    PopupUtils.open(createFileDialog, root)
//                }
//            }

            Action {
                text: pageModel.clipboardUrlsCounter === 0
                      ? i18n.tr("Paste")
                      : pageModel.clipboardUrlsCounter === 1
                        ? i18n.tr("Paste %1 File").arg(pageModel.clipboardUrlsCounter)
                        : i18n.tr("Paste %1 Files").arg(pageModel.clipboardUrlsCounter)
                onTriggered: {
                    console.log("Pasting to current folder items of count " + pageModel.clipboardUrlsCounter)
                    PopupUtils.open(Qt.resolvedUrl("FileOperationProgressDialog.qml"),
                                    root,
                                    {
                                        title: i18n.tr("Paste files"),
                                        folderListModel: pageModel
                                     }
                                    )


                    pageModel.paste()
                }

                // FIXME: This property is depreciated and doesn't seem to work!
                //visible: pageModel.clipboardUrlsCounter > 0

                enabled: pageModel.clipboardUrlsCounter > 0
            }

            Action {
                text: i18n.tr("Properties")
                onTriggered: {
                    print(text)
                    PopupUtils.open(Qt.resolvedUrl("FileDetailsPopover.qml"),
                                    root,
                                        { "model": pageModel
                                        }
                                    )
                }
            }
        }

        // Without this the popover jumps up at the start of the application. SDK bug?
        // Bug report has been made of these https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1152270
        visible: false
    }

    Component {
        id: createFolderDialog
        ConfirmDialogWithInput {
            title: i18n.tr("Create folder")
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

    Component {
        id: createFileDialog
        ConfirmDialogWithInput {
            title: i18n.tr("Create file")
            text: i18n.tr("Enter name for new file")

            onAccepted: {
                console.log("Create file accepted", inputText)
                if (inputText !== '') {
                    //FIXME: Actually create a new file!
                } else {
                    console.log("Empty file name, ignored")
                }
            }
        }
    }



    tools: ToolbarItems {
        id: toolbar
        locked: true
        opened: true

        back: ToolbarButton {
            text: "Up"
            iconSource: "/usr/share/icons/ubuntu-mobile/actions/scalable/keyboard-caps.svg"
            visible: folder != "/"
            onTriggered: {
                goTo(pageModel.parentPath)
            }
        }

        ToolbarButton {
            text: i18n.tr("Actions")
            iconSource: "/usr/share/icons/ubuntu-mobile/actions/scalable/edit.svg"

            onTriggered: {
                print(text)
                folderActionsPopover.caller = caller
                folderActionsPopover.show();
            }
        }

        ToolbarButton {
            text: i18n.tr("Settings")
            iconSource: "/usr/share/icons/ubuntu-mobile/actions/scalable/settings.svg"

            onTriggered: {
                print(text)

                PopupUtils.open(Qt.resolvedUrl("SettingsPopover.qml"), caller)
            }
        }

        ToolbarButton {
            text: i18n.tr("Places")
            iconSource: "/usr/share/icons/ubuntu-mobile/actions/scalable/location.svg"
            onTriggered: {
                print(text)

                PopupUtils.open(Qt.resolvedUrl("PlacesPopover.qml"), caller)
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

        clip: true

        folderListModel: pageModel
        anchors.fill: parent
        // IMPROVE: this should work (?), but it doesn't. Height is undefined. Anyway in previous
        // SDK version the parent size was properly initialized. Now the size of toolbar is not taken into
        // account and apparently you can't even query toolbar's height.
     // anchors.bottomMargin: toolbar.height
        // So hard-code it. Not nice at all:
        anchors.bottomMargin: units.gu(8)
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
