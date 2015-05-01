/***********************************************************************/


import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    width: 640
    height: 480

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
    }

    Repeater {
        model: screenModel
        Background {
            x: geometry.x; y: geometry.y; width: geometry.width; height:geometry.height
            property real ratio: geometry.width / geometry.height
            source: {
                if (ratio == 16.0 / 9.0) {
                    source = "background_169.png"
                }
                else if (ratio == 16.0 / 10.0) {
                    source = "background_1610.png"
                }
                else if (ratio == 4.0 / 3.0) {
                    source = "background_43.png"
                }
                else {
                    source = "background.png"
                }
            }
            fillMode: Image.PreserveAspectFit
            onStatusChanged: {
                if (status == Image.Error && source != config.defaultBackground) {
                    source = config.defaultBackground
                }
            }
        }
    }

    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        property real scale: geometry.width / 1920
        color: "transparent"
        transformOrigin: Item.Top

        Image {
            id: welcome
            width: 824
            height: 48
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 24 - parent.height /2
            anchors.horizontalCenterOffset: 0
            fillMode: Image.PreserveAspectFit
            transformOrigin: Item.Center
            source: "welcome-time-shadowed.png"
        }

        Text {
            font.pixelSize: 14
            width: 375
            height: text.implicitHeight
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 16 - parent.height /2
            anchors.horizontalCenterOffset: 0 - 375/2
            color: "lightgrey"
            text: textConstants.welcomeText.arg(sddm.hostName)
            horizontalAlignment: Text.AlignHLeft
        }

        Text {
            font.pixelSize: 14
            width: 375
            height: text.implicitHeight
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 16 - parent.height /2
            anchors.horizontalCenterOffset: 375/2
            color: "lightgrey"
            text: new Date().toLocaleDateString()
            horizontalAlignment: Text.AlignRight
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: 162
            anchors.verticalCenterOffset: parent.height / 4
            color: "#20FFFFFF"

            Image {
                id: pictpassword
                width: 100
                height: 100
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 0
                anchors.horizontalCenterOffset: 75 - parent.width / 2
                fillMode: Image.PreserveAspectFit
                transformOrigin: Item.Center
                source: "password.png"
            }

            Column {
                id: mainColumn
                height: 116
                width: 300
                spacing: 4
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 9
                anchors.horizontalCenterOffset: 300 - parent.width / 2

                Row {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        width: parent.width * 0.30; height: 30
                        color: "white"
                        text: textConstants.userName
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: 12
                    }

                    TextBox {
                        id: name
                        width: parent.width * 0.7; height: 30
                        text: userModel.lastUser
                        font.pixelSize: 14

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing : 4
                    Text {
                        id: lblPassword
                        width: parent.width * 0.3; height: 30
                        color: "white"
                        text: textConstants.password
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: 12
                    }

                    PasswordBox {
                        id: password
                        width: parent.width * 0.7; height: 30
                        font.pixelSize: 14
                        tooltipBG: "lightgrey"

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 4

                    Text {
                        id: lblSession
                        width: parent.width * 0.3; height: 30
                        color: "white"
                        text: textConstants.session
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pixelSize: 12
                    }

                    ComboBox {
                        id: session
                        width: parent.width * 0.7; height: 30

                        arrowIcon: "angle-down.png"

                        model: sessionModel
                        index: sessionModel.lastIndex

                        KeyNavigation.backtab: password; KeyNavigation.tab: loginButton
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        color: "white"
                        font.pixelSize: 12
                    }
                }
            }
            Column {
                spacing: 4
                property int btnWidth: Math.max(loginButton.implicitWidth,
                                                shutdownButton.implicitWidth,
                                                rebootButton.implicitWidth, 80) + 8
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 0
                anchors.horizontalCenterOffset: parent.width / 2 - btnWidth

                Button {
                    id: loginButton
                    text: textConstants.login
                    width: parent.btnWidth
                    color: "#1793d1"

                    onClicked: sddm.login(name.text, password.text, session.index)

                    KeyNavigation.backtab: loginButton; KeyNavigation.tab: shutdownButton
                }

                Button {
                    id: shutdownButton
                    text: textConstants.shutdown
                    width: parent.btnWidth
                    color: "#1793d1"

                    onClicked: sddm.powerOff()

                    KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                }

                Button {
                    id: rebootButton
                    text: textConstants.reboot
                    width: parent.btnWidth
                    color: "#1793d1"

                    onClicked: sddm.reboot()

                    KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
