import QtQuick
import QtQuick.Controls

import "../windows"

Button {
    text: "Align"
    onClicked: {
        alignMenu.open()
    }

    property Item item;
    property OutputWindow window;

    Menu {
        id: alignMenu
        MenuItem {
            text: "Left - Top"
            onClicked: window.setPosition(item, Qt.AlignLeft, Qt.AlignTop)
        }
        MenuItem {
            text: "Middle - Top"
            onClicked: window.setPosition(item, Qt.AlignCenter, Qt.AlignTop)
        }
        MenuItem {
            text: "Right - Top"
            onClicked: window.setPosition(item, Qt.AlignRight, Qt.AlignTop)
        }
        MenuItem {
            text: "Left - Middle"
            onClicked: window.setPosition(item, Qt.AlignLeft, Qt.AlignCenter)
        }
        MenuItem {
            text: "Middle - Middle"
            onClicked: window.setPosition(item, Qt.AlignCenter, Qt.AlignCenter)
        }
        MenuItem {
            text: "Right - Middle"
            onClicked: window.setPosition(item, Qt.AlignRight, Qt.AlignCenter)
        }
        MenuItem {
            text: "Left - Bottom"
            onClicked: window.setPosition(item, Qt.AlignLeft, Qt.AlignBottom)
        }
        MenuItem {
            text: "Middle - Bottom"
            onClicked: window.setPosition(item, Qt.AlignCenter, Qt.AlignBottom)
        }
        MenuItem {
            text: "Right - Bottom"
            onClicked: window.setPosition(item, Qt.AlignRight, Qt.AlignBottom)
        }
    }
}
