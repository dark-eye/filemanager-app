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
 * Authored by: Michael Spencer <sonrisesoftware@gmail.com>
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Dialog {
    id: root

    title: i18n.tr("Go To Location")

    text: i18n.tr("Enter a location to go to:")

    TextField {
        id: locationField

        inputMethodHints: Qt.ImhNoAutoUppercase

        property bool valid: pathExists(text)

        text: fileView.path

        placeholderText: i18n.tr("Location...")

        onAccepted: goButton.clicked()
    }

    Button {
        id: goButton
        objectName: "goButton"

        text: i18n.tr("Go")
        enabled: locationField.acceptableInput && locationField.valid

        onClicked: {
            print("User switched to:", locationField.text)
            goTo(locationField.text)
            PopupUtils.close(root)
        }
    }

    Button {
        objectName: "cancelButton"
        text: i18n.tr("Cancel")

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "gray"
            }

            GradientStop {
                position: 1
                color: "lightgray"
            }
        }

        onClicked: {
            PopupUtils.close(root)
        }
    }
}