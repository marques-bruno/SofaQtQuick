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

#include "SofaSceneListProxy.h"

namespace sofa
{

namespace qtquick
{

SofaSceneListProxy::SofaSceneListProxy(QObject* parent) :
    SofaSceneListModel(parent)
{

}

SofaSceneListProxy::~SofaSceneListProxy()
{

}

void SofaSceneListProxy::setDisabled(int modelRow, bool value)
{

}

void SofaSceneListProxy::setCollapsed(int modelRow, bool value)
{

}


} ///namespace qtquick
} ///namespace sofa
