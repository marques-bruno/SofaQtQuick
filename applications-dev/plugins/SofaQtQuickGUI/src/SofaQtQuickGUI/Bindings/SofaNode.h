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
#pragma once

#include <QObject>

#include <SofaQtQuickGUI/config.h>

#include <SofaSimulationGraph/DAGNode.h>
#include "SofaBase.h"
#include "SofaBaseObject.h"

namespace sofa::qtquick
{
class SofaComponent;
class SofaScene;
}  // namespace sofa::qtquick

namespace sofaqtquick::bindings
{

namespace _sofanode_
{

using sofaqtquick::bindings::SofaBase;
using sofaqtquick::bindings::_sofaobject_::SofaBaseObject;
using sofa::simulation::graph::DAGNode;

class SofaNode;
class SofaNodeList;

/// QtQuick wrapper to sofa::Node
class SOFA_SOFAQTQUICKGUI_API SofaNode : public SofaBase
{
public:
     Q_OBJECT
public:
    SofaNode(const QString name="unamed", QObject *parent = nullptr);
    SofaNode(DAGNode::SPtr self, QObject *parent = nullptr);
    SofaNode(SofaBase* self);
    ~SofaNode() override;

    DAGNode* self() const { return dynamic_cast<DAGNode*>(m_self.get()); } ///< Hold are reference to the real sofa object.
    DAGNode::SPtr selfptr()const { return DAGNode::SPtr(dynamic_cast<DAGNode*>(m_self.get())); } ///< Hold are reference to the real sofa object.

    Q_INVOKABLE sofa::qtquick::SofaComponent* toSofaComponent(sofa::qtquick::SofaScene* scene = nullptr); ///< legacy method to return a deprecated SofaComponent class


    Q_INVOKABLE SofaNode* createChild(QString name);

    Q_INVOKABLE SofaNode* getFirstParent();
    Q_INVOKABLE SofaNode* getChild(QString name);
    Q_INVOKABLE SofaNode* getNodeInGraph(QString name);
    Q_INVOKABLE SofaNode* getRoot();
    Q_INVOKABLE SofaBaseObjectList* getBaseObjects();
    Q_INVOKABLE SofaNodeList* getChildren();

    /// Returns true if the underlying Base
    /// or any of its ancestors is a SofaPrefab.
    Q_INVOKABLE bool isPrefab() const;
    Q_INVOKABLE bool isInAPrefab() const;
    Q_INVOKABLE bool hasMessageInChild() const;

    Q_INVOKABLE void addChild(SofaNode* child);
    Q_INVOKABLE void copyTo(SofaNode* child);
    Q_INVOKABLE void addObject(SofaBaseObject* obj);

    Q_INVOKABLE void moveChild(SofaNode* node, SofaNode* prev_parent);
    Q_INVOKABLE void moveObject(SofaBaseObject* obj);

    Q_INVOKABLE void removeChild(SofaNode* node);
    Q_INVOKABLE void removeObject(SofaBaseObject* obj);

    Q_INVOKABLE SofaBaseObject* createObject(const QString& type,
                                             const QVariantMap& arguments);
    Q_INVOKABLE SofaBaseObject* getObject(const QString& name) const;
    Q_INVOKABLE QObject* get(const QString& path) const;

    Q_INVOKABLE void init() const;
    Q_INVOKABLE void reinit() const;

    Q_INVOKABLE QString getNextName(const QString& name);
    Q_INVOKABLE QString getNextObjectName(const QString& name);

    static SofaNode* createFrom(sofa::core::objectmodel::Base* obj);

private:
    bool attemptToBreakPrefab();
    sofa::core::objectmodel::BaseNode *getPrefabAncestor(sofa::core::objectmodel::BaseNode* n) const;

};

class SofaNodeList : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE unsigned int size();
    Q_INVOKABLE SofaNode* at(unsigned int);
    Q_INVOKABLE SofaNode* first();
    Q_INVOKABLE SofaNode* last();

    void addSofaNode(sofa::core::objectmodel::BaseNode* node);

private:
    std::vector<SofaNode*> m_list;
};


class SofaNodeFactory : public QObject
{
    Q_OBJECT
public:
  SofaNodeFactory();
  Q_INVOKABLE SofaNode* createInstance(SofaBase* t);
};

} /// namespace _sofanode_

using _sofanode_::SofaNode;
using _sofanode_::SofaNodeList;
using _sofanode_::SofaNodeFactory;

} /// namespace sofaqtquick::bindings
