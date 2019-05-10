import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.2
import SofaBasics 1.0
import QtQuick.Layouts 1.12
import Qt.labs.folderlistmodel 2.12
import AssetFactory 1.0
import SofaColorScheme 1.0
import SofaWidgets 1.0
import QtQml 2.12
import QtQuick.Window 2.12
//import AssetView 1.0

Item {

    property var sofaApplication: null

    id: root

    anchors.fill : parent

    Item {
        id: self
        property var project: sofaApplication.currentProject
    }

    Rectangle {
        id: background
        anchors.fill : parent
        color: sofaApplication.style.contentBackgroundColor
    }

    ColumnLayout {
        anchors.fill: parent
        Rectangle {
            id: headerID
            Layout.fillWidth: true


            implicitHeight: 25
            color: sofaApplication.style.contentBackgroundColor
            border.color: "#3c3c3c"

            GBRect {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: parent.implicitHeight - 1
                implicitWidth: parent.implicitWidth + 2
                borderWidth: 1
                borderGradient: Gradient {
                    GradientStop { position: 9.0; color: "#5c5c5c" }
                    GradientStop { position: 1.0; color: "#7a7a7a" }
                }
                color: "transparent"

                Label {
                    leftPadding: 10
                    text: folderModel.folder.toString().split("/")[folderModel.folder.toString().split("/").length -1]
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }


        ScrollView {
            id: scrollview

            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: folderView
                anchors.fill: parent
                header: RowLayout{
                    implicitWidth: folderView.width

                    Rectangle {
                        color: sofaApplication.style.contentBackgroundColor
                        Layout.fillWidth: true
                        implicitHeight: 20
                        implicitWidth: folderView.width / 3
                        Rectangle {
                            id: separator1
                            width: 2
                            height: 20
                            color: "#393939"
                            Rectangle {
                                x: 1
                                width: 1
                                height: 20
                                color: "#959595"
                            }
                        }
                        Label {
                            anchors.left: separator1.right
                            leftPadding: 5
                            color: "black"
                            text: "Name"
                        }
                    }

                    Rectangle {
                        color: sofaApplication.style.contentBackgroundColor
                        Layout.fillWidth: true
                        implicitHeight: 20
                        implicitWidth: folderView.width / 3
                        Rectangle {
                            id: separator2
                            width: 2
                            height: 20
                            color: "#393939"
                            Rectangle {
                                x: 1
                                width: 1
                                height: 20
                                color: "#959595"
                            }
                        }
                        Label {
                            anchors.left: separator2.right
                            leftPadding: 5
                            color: "black"
                            text: "Type"
                        }
                    }

                    Rectangle {
                        color: sofaApplication.style.contentBackgroundColor
                        Layout.fillWidth: true
                        implicitHeight: 20
                        implicitWidth: folderView.width / 3
                        Rectangle {
                            id: separator3
                            width: 2
                            height: 20
                            color: "#393939"
                            Rectangle {
                                x: 1
                                width: 1
                                height: 20
                                color: "#959595"
                            }
                        }
                        Label {
                            anchors.left: separator3.right
                            leftPadding: 5
                            color: "black"
                            text: "Size"
                        }
                    }
                }

                FolderListModel {
                    id: folderModel

                    property var projectDir: sofaApplication.projectSettings.recentProjects.split(";")[0]
                    onProjectDirChanged: {

                        self.project.rootDir = projectDir
                        folderModel.rootFolder = self.project.rootDir
                        folderModel.folder = self.project.rootDir
                    }

                    showDirs: true
                    showDotAndDotDot: true
                    showDirsFirst: true
                    showFiles: true
                    caseSensitive: true
                    folder: ""
                    nameFilters: ["*"]
                }

                delegate: Component {
                    id: fileDelegate
                    Rectangle {
                        id: wrapper
                        width: root.width
                        height: 20
                        color: index % 2 ? "#4c4c4c" : "#454545"
                        property string highlightColor: ListView.isCurrentItem ? "#82878c" : "transparent"
                        Rectangle {
                            anchors.fill: parent
                            color: wrapper.highlightColor
                            radius: 4
                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillWidth: true
                                    Image {
                                        id: iconId
                                        x: 5
                                        width: 15
                                        height: 15
                                        fillMode: Image.PreserveAspectFit
                                        source: fileIsDir ? "qrc:/icon/ICON_FILE_FOLDER.png" : self.project.assetFactory.getIcon(fileSuffix)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width
                                        leftPadding: 5
                                        text: fileName
                                        clip: true
                                        elide: Text.ElideRight
                                        color: "#efefef"
                                        anchors.left: iconId.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Text {
                                        width: parent.width
                                        leftPadding: 10
                                        text: fileIsDir ? "Folder" : self.project.assetFactory.getTypeString(fileSuffix)
                                        color: "#efefef"
                                        clip: true
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    Text {
                                        width: parent.width
                                        leftPadding: 10
                                        text: fileIsDir ? self.project.getFileCount(fileURL) :
                                                          (fileSize > 1e9) ? (fileSize / 1e9).toFixed(1) + " G" :
                                                                             (fileSize > 1e6) ? (fileSize / 1e6).toFixed(1) + " M" :
                                                                                                (fileSize > 1e3) ? (fileSize / 1e3).toFixed(1) + " k" :
                                                                                                                   fileSize + " bytes"
                                        color: "#efefef"
                                        clip: true
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                        SofaAssetMenu {
                            id: assetMenu
                            model: self.project.getAssetMetaInfo(folderModel.get(index, "fileURL"))
                            visible: false
                        }
                        Menu {
                            id: projectMenu
                            visible: false

                            MenuItem {
                                text: "Show Containing Folder"
                                onTriggered: {
                                    projectMenu.visible = false
                                    console.error(folderModel.get(index, "filePath"))
                                    sofaApplication.openInExplorer(folderModel.get(index, "filePath"))
                                }
                            }
                            MenuItem {
                                id: openTerminal
                                text: "Open Terminal Here"
                                onTriggered: {
                                    projectMenu.visible = false
                                    sofaApplication.openInTerminal(folderModel.get(index, "filePath"))
                                }
                            }

                            MenuItem {
                                id: newFolder
                                text: "New Folder"

                                onTriggered: {
                                    projectMenu.visible = false
                                    sofaApplication.createFolderIn(folderModel.get(index, "filePath"))
                                }
                            }

                            MenuItem {
                                id: importAsset
                                text: "Import asset..."

                                onTriggered: {
                                    var o = windowComponent.createObject(sofaApplication, {
                                                                     "source": "qrc:///SofaViews/WebBrowserView.qml",
                                                                     "title" : "Sofa Asset Repository"
                                                                 });
                                    o.scroll.webview.source = "http://www.google.fr"
                                }

                                Component {
                                    id: windowComponent

                                    Window {
                                        property url source

                                        id: window
                                        width: 600
                                        height: 400
                                        modality: Qt.NonModal
                                        flags: Qt.Tool | Qt.WindowStaysOnTopHint | Qt.CustomizeWindowHint | Qt.WindowSystemMenuHint |Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinMaxButtonsHint
                                        visible: true
                                        color: sofaApplication.style.contentBackgroundColor

                                        Loader {
                                            id: loader
                                            anchors.fill: parent
                                            source: window.source
                                        }
                                    }
                                }
                            }

                            Component {
                                id: fileSpecificEntries
                                MenuItem {
                                    id: openInEditor
                                    text: "Open In Editor"
                                    onTriggered: {
                                        projectMenu.visible = false
                                        sofaApplication.openInEditor(folderModel.get(index, "filePath"))
                                    }
                                }
                            }
                            Component {
                                id: folderSpecificEntries
                                MenuItem {
                                    id: openAsProject
                                    text: "Open Folder As Project"

                                    onTriggered: {
                                        projectMenu.visible = false
                                        sofaApplication.projectSettings.addRecent(folderModel.get(index, "filePath"))
                                    }
                                }
                            }

                            Component {
                                id: sceneSpecificEntries
                                MenuItem {
                                    id: projectFromScene
                                    text: "Load Scene"
                                    onTriggered: {
                                        projectMenu.visible = false
                                        sofaApplication.sofaScene.source = folderModel.get(index, "filePath")
                                    }
                                }
                            }

                            Loader {
                                sourceComponent: folderModel.isFolder(index) ? folderSpecificEntries: fileSpecificEntries
                            }

                            Loader {
                                sourceComponent: {
                                    for (var m in assetMenu.model) {
                                        console.error(assetMenu.model[m].name)
                                        if (assetMenu.model[m].name === "createScene")
                                            return sceneSpecificEntries
                                    }
                                    return null
                                }
                            }
                        }

                        MouseArea {
                            id: mouseRegion
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {
                                if (containsMouse) {
                                    folderView.currentIndex = index;
                                }
                            }
                            onDoubleClicked: {
                                if (folderModel.isFolder(index)) {
                                    folderModel.folder = folderModel.get(index, "fileURL")
                                } else {
                                    var rootNode = sofaApplication.sofaScene.root()

                                    insertAsset(index, rootNode)
                                }

                            }
                            onClicked: {
                                if (Qt.RightButton === mouse.button)
                                {
                                    projectMenu.visible = true
                                    //                                    // Let's load detailed info if available
                                    //                                    if (!folderModel.isFolder(index))
                                    //                                    {
                                    //                                        assetMenu.visible = true
                                    //                                    }
                                }
                            }

                            drag.target: draggedData



                            drag.onActiveChanged: {
                                if (drag.active) {
                                    draggedData.ctxMenu = assetMenu
                                    draggedData.url = folderModel.get(index, "fileURL")
                                    console.log("SETTING THE DATA URL TO: " + draggedData.url)

                                } else {
                                    console.error("Drag Finished")

                                }

                                //                                    if (parent.Drag.target !== null) {
                                //                                        var target = parent.Drag.target.node
                                //                                        if (target !== "invalid") {
                                //                                            insertAsset(index, sofaApplication.sofaScene.node(target))
                                //                                        }
                                //                                    }
                            }
                            function insertAsset(index, rootNode) {
                                var component = self.project.getAsset(folderModel.get(index, "fileURL"))
                                console.error("Parent node for asset is " + rootNode)
                                rootNode.addChild(component)
                            }

                            Item {
                                id: draggedData
                                Drag.active: mouseRegion.drag.active
                                Drag.dragType: Drag.Automatic
                                Drag.supportedActions: Qt.CopyAction
                                Drag.mimeData: {
                                    "text/plain": "Copied text"
                                }
                                property bool accepted: false
                                property point beginDrag
                                property var node
                                property var ctxMenu
                                property var url

                                function getAsset(assetName) {
                                    return self.project.getAsset(folderModel.get(index, "fileURL"), assetName)
                                }
                            }
                        }
                    }
                }

                model: folderModel
                highlight: Rectangle { color: "#82878c"; radius: 5 }
                focus: true
            }
        }


        //        GroupBox {
        //            id: previewGroupID
        //            Layout.fillWidth: true
        //            implicitHeight: contentHeight ? contentHeight : 200
        //            height: implicitHeight

        //            title: "Preview"

        //            AssetView {
        //                id: assetView
        //                anchors.fill: parent
        //                drawFrame: false
        //            }

        //        }
    }


}