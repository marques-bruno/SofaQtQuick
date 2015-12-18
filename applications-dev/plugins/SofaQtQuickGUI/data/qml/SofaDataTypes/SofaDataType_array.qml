/*
Copyright 2015, Anatoscope

This file is part of sofaqtquick.

sofaqtquick is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

sofaqtquick is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sofaqtquick. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0

Loader {
    id: root

    property var dataObject

    sourceComponent: {
        if(dataObject.properties.static) {
            if((!dataObject.properties.innerStatic && dataObject.value.length <= 7) ||
               (dataObject.properties.innerStatic && 1 === dataObject.value.length && dataObject.properties.cols <= 7))
                return staticSmallArrayView;
            else if(dataObject.properties.innerStatic && dataObject.properties.cols <= 7)
                return staticInStaticTableView;
            else
                return staticArrayView;
        }
        else {
            if(dataObject.properties.innerStatic) {
                if(dataObject.properties.cols <= 7 || dataObject.properties.cols === 12) // Case of Affine type
                    return staticInDynamicTableView;
                else
                    return dynamicArrayView;
            }
        }

        return dynamicArrayView;
    }

    Component {
        id: staticInStaticTableView
        TableView {
            id: tableView

            Component {
                id: columnComponent
                TableViewColumn {
                    movable: false
                    resizable: false
                    horizontalAlignment: Text.AlignHCenter
                    width: (tableView.width - 58) / (tableView.columnCount - 1)
                }
            }

            Component {
                id: columnLines
                TableViewColumn {
                    movable: false
                    resizable: false
                    horizontalAlignment: Text.AlignHCenter
                    width: 58
                }
            }

            Component.onCompleted: {
                addColumn(columnLines.createObject(tableView, {"title": "", "role": "printLinesNumber"}));
                for(var i = 0; i < dataObject.properties.cols; ++i)
                    addColumn(columnComponent.createObject(tableView, {"title": i.toString(), "role": "c" + i.toString()}));
            }

            Connections {
                target: dataObject
                onValueChanged: {
                    listModel.update();

                    dataObject.modified = false;
                }
            }

            model: ListModel {
                id: listModel

                Component.onCompleted: populate();

                property int previousCount: 0

                function populate() {
                    var newCount = dataObject.value.length;
                    if(previousCount < newCount)
                        for(var j = previousCount; j < newCount; ++j) {
                            var values = {};
                            for(var i = previousCount; i < dataObject.properties.cols; ++i)
                                values["c" + i.toString()] = dataObject.value[j][i];

                            append(values);
                        }
                    else if(previousCount > newCount)
                        remove(newCount, previousCount - newCount);

                    previousCount = count;
                }

                function update() {
                    if(count !== dataObject.value.length)
                        populate();

                    for(var j = 0; j < count; ++j) {
                        var values = {};
                        for(var i = previousCount; i < dataObject.properties.cols; ++i)
                            values["c" + i.toString()] = dataObject.value[j][i];

                        set(j, values);
                    }
                }
            }

            function populate() {
                listModel.populate();
            }

            function update() {
                listModel.update();
            }

            itemDelegate: TextInput {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                clip: true
                readOnly: -1 === styleData.row || dataObject.readOnly || 0 === styleData.column
                color: styleData.textColor
                horizontalAlignment: TextEdit.AlignHCenter
                text: {
                    if (styleData.column === 0)
                        return styleData.row;
                    else if(-1 !== styleData.row && styleData.column !== 0) {
                        return dataObject.value[styleData.row][styleData.column - 1];
                    }

                    return "";
                }
                property int previousRow: -1
                onTextChanged: {
                    if(-1 === styleData.row || dataObject.readOnly || 0 === styleData.column)
                        return;

                    if(previousRow !== styleData.row) {
                        previousRow = styleData.row;
                        return;
                    }

                    if(styleData.column !== 0) {
                        var oldValue = dataObject.value[styleData.row][styleData.column - 1];

                        var value = text;
                        if(value !== oldValue) {
                            dataObject.value[styleData.row][styleData.column - 1] = value;
                            dataObject.modified = true;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: staticSmallArrayView
        RowLayout {
            id: rowLayout
            width: parent.width
            spacing: 0
            enabled: !dataObject.readOnly

            property var fields: []
            property bool innerArray: false

            Component.onCompleted: populate();

            function populate() {
                var values = dataObject.value;
                if(1 === values.length && Array.isArray(values[0]))
                {
                    values = dataObject.value[0];
                    innerArray = true;
                }

                fields = [];
                for(var i = 0; i < values.length; ++i)
                    fields[i] = textFieldComponent.createObject(rowLayout, {index: i});

                update();
            }

            function update() {
                var values = dataObject.value;
                if(innerArray)
                    values = dataObject.value[0];

                for(var i = 0; i < values.length; ++i) {
                    fields[i].text = values[i].toString();
                }
            }

            Component {
                id: textFieldComponent

                TextField {
                    Layout.fillWidth: true
                    readOnly: dataObject.readOnly
                    enabled: !dataObject.readOnly

                    property int index
                    onTextChanged: {
                        if(rowLayout.innerArray)
                            dataObject.value[0][index] = text;
                        else
                            dataObject.value[index] = text;

                        dataObject.modified = true;
                    }
                }
            }

            Connections {
                target: dataObject
                onValueChanged: rowLayout.update();
            }
        }
    }

    Component {
        id: staticArrayView
        TextField {
            id: textField
            readOnly: dataObject.readOnly
            enabled: !dataObject.readOnly
            text: undefined !== dataObject.value ? dataObject.value.toString() : ""

            Binding {
                target: dataObject
                property: "value"
                value: textField.text
            }
        }
    }

    Component {
        id: staticInDynamicTableView

        ColumnLayout {
            spacing: 0

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Size"
                }
                SpinBox {
                    id: rowNumber
                    enabled: !dataObject.readOnly && showEditButton.checked
                    Layout.fillWidth: true
                    value: dataObject.value.length
                    onEditingFinished: {
                        if(value === dataObject.value.length)
                            return;

                        var oldLength = dataObject.value.length;
                        dataObject.value.length = value;
                        for(var j = oldLength; j < dataObject.value.length; ++j) {
                            dataObject.value[j] = [];
                            for(var i = 0; i < dataObject.properties.cols; ++i)
                                dataObject.value[j][i] = 0;
                        }

                        dataObject.modified = true;

                        if(loader.item)
                            loader.item.populate();
                    }

                    minimumValue: 0
                    maximumValue: Number.MAX_VALUE
                }
                Button {
                    id: showEditButton
                    text: "Show / Edit"
                    checkable: true
                }
            }

            Loader {
                id: loader
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: showEditButton.checked
                active: visible
                sourceComponent: staticInStaticTableView
            }
        }
    }

    Component {
        id: dynamicArrayView

        TextField {
            id: textField
            readOnly: dataObject.readOnly
            enabled: !dataObject.readOnly

            onTextChanged: {
                if(!dataObject.readOnly)
                    if(Array.isArray(dataObject.value))
                        dataObject.value = text.split(' ')
                    else
                        dataObject.value = text
            }

            Binding {
                target: textField
                property: "text"
                value: Array.isArray(dataObject.value) ? dataObject.value.join(' ') : dataObject.value
            }
        }
    }
}
