import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import SofaBasics 1.0
import SofaApplication 1.0
//import SofaSceneListModel 1.0
import SofaViews 1.0

Component {
    Window {
        property var sofaComponent: null
        id: root
        width: 400
        height: 600
        modality: Qt.NonModal
        flags: Qt.Tool | Qt.WindowStaysOnTopHint | Qt.CustomizeWindowHint | Qt.WindowSystemMenuHint |Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinMaxButtonsHint
        visible: true
        color: "lightgrey"

        title: sofaComponent ? ("Messages for component: " + sofaComponent.name()) : "No component to visualize"

        //property var sofaScene: root.sofaScene
        //property var sofaComponent: sofaScene ? sofaScene.selectedComponent : null

        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: MessageView {
                filterByComponent: true
                sofaSelectedComponent: sofaComponent
            }
        }
    }
}
