import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

Item {
    id: gameBoard

    // public properties
    property url path
    property int elapsed
    property int countdown: 10
    property int countdownFinished: 10
    property int boardWidth
    property int boardHeight

    property Card firstCard
    property Card secondCard
    property int remaining

    anchors.centerIn: parent
    width: childrenRect.width
    height: childrenRect.height
    scale: Math.min(parent.width / width, parent.height / height)
    state: "ready"

    FolderListModel {
        id: fileList
        folder: path
        nameFilters: [ "*.png", "*.jpg" ]
    }

    Grid {
        id: grid
        rows: 0
        columns: 0
        spacing: 20

        Repeater {
            id: repeater
            model: parent.rows * parent.columns
            Card {
                onSelected: cardSelected(index)
                onAnimationFinished: cardAnimationFinished()
            }
        }
    }

    Timer {
        running: gameBoard.state === "running"
        repeat: true
        onTriggered: {
            elapsed--;                  // count down
            if(elapsed == 0){
                state = "timeout";
                timer.visible = false;

            }

        }
    }

    Timer{
        id:timerToCloseDialogStart
        repeat: true
        running:  gameBoard.state === "ready"
        onTriggered: {
                    countdown--; // Decrement the timer
                    if (countdown == 0) {
                        timerToCloseDialogStart.stop();
                        close();
                    }
                    if(countdown == 100){
                        timerToCloseDialogStart.stop();
                        timerToClose.visible = false;
                    }
                }
    }

    Timer{
        id:timerToCloseDialogFinished
        repeat: true
        running: gameBoard.state === "finished"
        onTriggered: {
            countdownFinished--;
            if(countdownFinished == 0){
                timerToCloseDialogFinished.stop();
                close();
            }
            if(countdownFinished == 100){
                timerToCloseDialogFinished.stop();
            }
        }
    }




    function initializeCards() {
        var numbers = [];

        for (var number = 0; number < (grid.rows * grid.columns) / 2; ++number) {
            numbers.push(number);
            numbers.push(number);
        }

        numbers.sort(function() {
            return 0.5 - Math.random();
        });

        var card;
        for (var i in numbers) {
            card = repeater.itemAt(i);
            card.pairID = numbers[i] % fileList.count;
            card.frontImage = fileList.folder + "/" + fileList.get(card.pairID, "fileName");
        }
    }

    function cardSelected(index) {
        var card = repeater.itemAt(index);

        if (firstCard === null) {
            firstCard = card;
            card.state = "active";
        }
        else {
            secondCard = card;
            card.state = "active";
        }

        enabled = false;
    }


    function cardAnimationFinished() {
        if (firstCard && secondCard) {
            // match
            if (firstCard.pairID === secondCard.pairID) {
                firstCard.state = "removed";
                secondCard.state = "removed";
                remaining -= 2;
            }

            // mismatch
            else {
                firstCard.state = "inactive";
                secondCard.state = "inactive";
            }

            // clean
            firstCard = null;
            secondCard = null;
            return;
        }

        enabled = true;
        if (remaining === 0) {
            state = "finished";
            timer.visible = false;
        }
    }


    states: [
        State {
            name: "ready"
        },

        State {
            name: "finished"
        },
        State {
            name: "timeout"
        },

        State {
            name: "running"
            PropertyChanges {
                target: grid
                rows: 0
                columns: 0
            }
            PropertyChanges {
                target: gameBoard
                firstCard: null
                secondCard: null
                enabled: true
                remaining: grid.rows * grid.columns
            }
            StateChangeScript {
                script: {
                    elapsed = 35;        // set timer default
                    grid.rows = boardHeight;
                    grid.columns = boardWidth;
                    initializeCards();
                }
            }
        }
    ]
}
