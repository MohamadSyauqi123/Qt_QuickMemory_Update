import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

ApplicationWindow {
    id: mainWindow

    property bool initialized: false
    property int sizeIndex: 0   // small
    property int themeIndex: 1  // cars
    property int elapsed : 10

    visible: true
    width: 640
    height: 480
    minimumHeight: 180
    minimumWidth: 150
    title: "MemoryGame"

    onAfterSynchronizing: {
        if (!initialized) {
            initialized = true;
            gameBoard.state = "ready";
        }
    }

//    MessageDialog {
//        title: "Winner!"
//        text: "Time: " + gameBoard.elapsed + " seconds"
//        visible: gameBoard.state === "finished"?
//        onAccepted: close()
//        onVisibleChanged: visible ? undefined : close()
//    }

    Image {
        fillMode: Image.Tile
        anchors.fill: parent
        source: "qrc:/generic/background.png"
    }

    SettingsWindow {
        id: settingsWindow
        themeModel: settings.themeModel
        sizeModel: settings.sizeModel
        onSettingsChanged: {
            mainWindow.sizeIndex = newSizeIndex;
            mainWindow.themeIndex = newThemeIndex;
        }
    }

    Settings {
        id: settings
    }

//    header: ToolBar {
//        id: toolBar
//        opacity: 1
//        RowLayout {
//            width: mainWindow.width

//            ToolButton {
//                id: newGameButton
//                text: "New game"
//                anchors.leftMargin: 0
//                onClicked: {
////                    gameBoard.state = "ready";
//                    gameBoard.state = "running";
//                }
//            }

//            ToolButton {

//                text: "Settings"
//                anchors.left: newGameButton.right
//                onClicked: {
//                    // trigger changes
//                    settingsWindow.themeIndex = -1;
//                    settingsWindow.sizeIndex = -1;
//                    settingsWindow.themeIndex = themeIndex;
//                    settingsWindow.sizeIndex = sizeIndex;
//                    settingsWindow.show()
//                }
//            }

//            Label {
//                text: gameBoard.elapsed + "s"
//                anchors.right: parent.right
//                anchors.rightMargin: 5
//                visible: gameBoard.state === "running"
//            }
//        }
//    }


    // start exit button main
    RowLayout {
        id:startexitbutton
        anchors.centerIn:parent
        Button {
            text: "Start"
            onClicked: {
                gameBoard.visible = true;
                gameBoard.state = "ready";
                gameBoard.state = "running";
                startexitbutton.visible = false;
                timer.visible = true;
                gameBoard.countdown = 1;
                timerToClose.visible = false;//


            }

        }
        spacing: 50
        Button {
            text: "Cancel"
            onClicked: close()
        }
    }

    // start exit button after finish
    RowLayout {
        visible: false
        id:finishedstartexit
        anchors.centerIn:parent
        Button {
            text: "Start"
            onClicked: {
                startexitbutton.visible =true;
                timerToCloseDialog.stop();
            }

        }
        spacing: 50
        Button {
            text: "Exit"
            onClicked: close()
        }
    }

    // display timer
    Label{
        visible: gameBoard.visible === "running"
        id:timer
        anchors.right: parent.right
        anchors.rightMargin: 5
        text: gameBoard.elapsed + "s"
        color: 'white'
    }

    // display timer to close dialog start
    Label{
        visible: true
        id:timerToClose
        anchors.right: parent.right
        anchors.rightMargin: 5
        text: "Closing in "+gameBoard.countdown + "s"
        color: 'white'
    }

    // finish message and new game button
    GridLayout{
        rows:2
        columns:1
        rowSpacing: 50
        columnSpacing: 30
        anchors.centerIn: parent
        visible: gameBoard.state === "finished"
        Text{
            text: "You a winner !!!"
            Layout.alignment: Qt.AlignHCenter
            color: 'white'
        }
        Button{
            text: "Close"

            onClicked: {
                close();
            }

        }
    }

    // display timer to close dialog finish
    Label{
        visible: gameBoard.state === "finished"
        id:timerToCloseDialogFinish
        anchors.right: parent.right
        anchors.rightMargin: 5
        text: "Closing in "+gameBoard.countdownFinished + "s"
        color: 'white'
    }

    GridLayout {
        rows: 3
        columns: 2
        rowSpacing: 50
        columnSpacing: 30
        anchors.centerIn: parent
        visible: gameBoard.state === "timeout"

        // Message Text
        Text {
            text: "You lose the game. Your time is up."
            color: 'white'
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter
        }


        // Try Again Button
        Button {
            text: "Try Again"
            onClicked: {
                gameBoard.state = "ready";
                gameBoard.state = "running";
                timer.visible = true;
                inactivityTimer.stop(); // Stop the auto-close timer
            }
        }

        // Close Button
        Button {
            text: "Close"
            onClicked: {
                inactivityTimer.stop(); // Stop the auto-close timer
                close();
            }
        }

    }

    // Timeout message and try again button
    GridLayout{
        rows:2
        columns:2
        rowSpacing: 50
        columnSpacing: 30
        anchors.centerIn: parent
        visible: gameBoard.state === "timeout"
        Text{
            text: "You lose the game. Your time is up."
            color: 'white'
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignHCenter
        }

        Button{
            text: "Try Again"

            onClicked: {
                gameBoard.state = "ready";
                gameBoard.state = "running";
                timer.visible = true;
                if(mainWindow.elapsed == 0){
                    mainWindow.close();
                }
            }
        }
        Button{
            text: "Close"

            onClicked: {
                close();
            }

        }
    }

    GameBoard {
        id: gameBoard
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        path: settings.getThemePath(themeIndex)
        boardWidth: settings.getWidth(sizeIndex)
        boardHeight: settings.getHeight(sizeIndex)

    }
}
