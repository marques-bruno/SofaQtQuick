/*********************************************************************
Copyright 2019, Inria, CNRS, University of Lille

This file is part of runSofa2

runSofa2 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

runSofa2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with sofaqtquick. If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
/********************************************************************
 Contributors:
    - damien.marchal@univ-lille.fr
********************************************************************/
pragma Singleton
import QtQuick 2.0

Item
{
    property var components : ({})
    Component.onCompleted:
    {
        getWidgetForData({"type":"undefined"})
    }

    function getWidgetForData(properties)
    {
        var type = properties.type
        if(0 === type.length)
        {
            console.error("Empty widget type. Replacing it with an undefined one. ")
            type = "undefined"
        }
        var filename = "qrc:/SofaDataTypes/SofaDataType_" + type + ".qml"

        if(!(type in components))
        {
            var component = Qt.createComponent(filename)
            if(component.status === Component.Ready){
                components[type] = component
                console.log("Loading data widget from file "+filename+" suceeded")
            }else{
                console.error("Error loading data component:", component.errorString());
            }
        }
        return components[type]
    }
}
