/*******************************************************************
Copyright 2018, CNRS

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
********************************************************************/
/*******************************************************************
 Contributors:
    - damien.marchal@univ-lille.fr
********************************************************************/

/// The order for the inclusion sequence is from the wider to the narrower.
#include <iostream>
#include <algorithm>
#include <functional>

#include <QStack>
#include <sofa/simulation/Visitor.h>
#include "SofaSceneItemModel.h"
#include "SofaSimulationGraph/DAGNode.h"

namespace sofa
{
namespace qtquick
{
namespace _sofasceneitemmodel_
{
using sofa::core::objectmodel::Base;
using sofa::core::objectmodel::BaseObject;
using sofa::core::objectmodel::BaseNode;
using sofa::simulation::Node;

SofaSceneItemModel::SofaSceneItemModel(QObject* parent) : QAbstractItemModel(parent), MutationListener()
{
}

SofaSceneItemModel::~SofaSceneItemModel()
{
    if(m_root!=nullptr)
        m_root->removeListener(this);
}

QModelIndex SofaSceneItemModel::index(int row, int column, const QModelIndex &parent) const
{
    if (enableDebug)
        qDebug() << "index query " << parent << " : " << row << ", " << column ;

    QModelIndex validParent = parent;
    sofa::core::objectmodel::Base* currentBase ;
    if (!parent.isValid())
    {
        currentBase=m_scene->sofaRootNode().get();
        if (!row && !column)
        {
//            qDebug() << "index for "<< QString::fromStdString(currentBase->getName()) << " is " << createIndex(0, 0, static_cast<Base*>(currentBase->toBaseNode())) ;
            return createIndex(0, 0, static_cast<Base*>(currentBase->toBaseNode()));
        }
        else
        {
            qDebug() << "index query " << parent << " : " << row << ", " << column << " is invalid" ;
            return QModelIndex();
        }
    }
    currentBase=static_cast<sofa::core::objectmodel::Base*>(validParent.internalPointer());

    if(currentBase->toBaseNode())
    {
        QModelIndex newIndex ;
        Node* currentNode = dynamic_cast<Node*>(currentBase);

        /// The row number is encoding either a node or a component.
        /// Its values are between 0 and object.size()+childNode.size().
        /// The components are before the child node so detect if the row is refereing to a
        /// component index or a child node index we are checking if it larger than the components's
        /// container size().
        sofa::core::objectmodel::Base* b;
        if(size_t(row) < currentNode->object.size())
        {
            b=static_cast<sofa::core::objectmodel::Base*>(currentNode->object[unsigned(row)].get());
            newIndex=createIndex(row, 0, b);
            //qDebug() << "index query " << current << " : " << row << ", " << column << " node: "
            //         << QString::fromStdString(currentNode->getName()) << " => object " << newIndex << "  " << currentNode->object[row].get()->toBaseNode() ;
        }
        else
        {
            /// Lets find our parent location.
            /// We change the row id so it fit inside the child array.
            size_t nrow = size_t(row) - currentNode->object.size();
            if(nrow >= currentNode->child.size())
            {
                qWarning() << "Inavlid row number =>" << row << column << validParent;
                return QModelIndex();
            }
            auto childNode = currentNode->child[unsigned(nrow)].get();
            b=childNode;
            int c = (childNode->getFirstParent() != currentNode) ;
            newIndex=createIndex(row, c, b);
            //qDebug() << "index query " << current << " : " << row << ", " << column << " node: "
            //         << QString::fromStdString(currentNode->getName()) << " => node " << newIndex  << "  " << currentNode->child[row].get()->toBaseNode() ;
        }
//        qDebug() << "index for "<< QString::fromStdString(b->getName()) << " is " << newIndex ;

        return newIndex;
    }
//        qDebug() << "index query " << parent << " : " << row << ", " << column << " is invalid" ;

    return QModelIndex(); //createIndex(row, column, nullptr);
}

QModelIndex SofaSceneItemModel::index(Node* node) const
{
    if (enableDebug)
        qDebug() << "index query for node " << QString::fromStdString(node->getName());
    if(node==nullptr)
    {
        return QModelIndex();
    }

    Node* parentNode=static_cast<Node*>(node->getFirstParent());
    if (!parentNode)
        return createIndex(0, 0, static_cast<Base*>(node));

    size_t d = 0;
    d += parentNode->object.size() + size_t(std::distance(parentNode->child.begin(),
                       std::find(parentNode->child.begin(), parentNode->child.end(), node)));

    return createIndex(int(d), 0, static_cast<sofa::core::objectmodel::Base*>(node));
}

QModelIndex SofaSceneItemModel::index(Node* parent, sofa::core::objectmodel::BaseObject* obj) const
{
    if (enableDebug)
        qDebug() << "Object index query (" << QString::fromStdString(parent->getName()) << ", " << QString::fromStdString(obj->getName()) <<  ")";

    if(obj == nullptr || parent == nullptr)
        return QModelIndex();

    size_t d = size_t(std::distance(parent->object.begin(),
                          std::find(parent->object.begin(), parent->object.end(), obj))) ;
    return createIndex(int(d), 0, static_cast<sofa::core::objectmodel::Base*>(obj));
}

QModelIndex SofaSceneItemModel::parent(const QModelIndex &index) const
{
    if (enableDebug)
        qDebug() << "parent query (" << index << "): " << QString::fromStdString(static_cast<sofa::core::objectmodel::Base*>(index.internalPointer())->getName());
    if(!index.isValid())
        return QModelIndex();
    sofa::core::objectmodel::Base* currentBase = static_cast<sofa::core::objectmodel::Base*>(index.internalPointer()) ;
    if(currentBase->toBaseNode())
    {
        Node* currentNode = static_cast<Node*>(currentBase->toBaseNode());
        if(currentNode->getNbParents()==0)
            return QModelIndex();

        //qDebug() << "   a: " << QString::fromStdString(currentNode->getName());
        Node* parentNode=static_cast<Node*>(currentNode->getFirstParent());
        Node* grandparentNode = static_cast<Node*>(parentNode->getFirstParent());

        QModelIndex idx;
        if(grandparentNode==nullptr)
        {
            return createIndex(0, 0, static_cast<Base*>(m_root->toBaseNode()));
        }
        else
        {
            size_t d = size_t(std::distance(grandparentNode->child.begin(),
                              std::find(grandparentNode->child.begin(), grandparentNode->child.end(), parentNode))) ;
            idx=createIndex(int(grandparentNode->object.size()+d), 0, static_cast<sofa::core::objectmodel::Base*>(parentNode));
        }
        //qDebug() << "   b: " << QString::fromStdString(parentNode->getName()) << " => " << idx;

        return idx;
    }
    return QModelIndex();
}

int SofaSceneItemModel::rowCount(const QModelIndex &index) const
{   
    if (enableDebug)
        qDebug() << "rowCount " << index ;

    sofa::core::objectmodel::Base* currentBase ;
    if (!index.isValid())
        return 1;
    currentBase=static_cast<sofa::core::objectmodel::Base*>(index.internalPointer());
    if(index.column()!=0)
        return 0;

    if(currentBase->toBaseNode())
    {
        Node* currentNode = static_cast<Node*>(currentBase->toBaseNode());
        size_t numRows = currentNode->child.size() + currentNode->object.size();

//                qDebug() << "     " << index << " node: " << QString::fromStdString(currentNode->getName())
//                            << "  => " << numRows;

        return int(numRows);
    }

    return 0;
}

bool SofaSceneItemModel::hasChildren(const QModelIndex &index) const
{
    /// A column higher than 0 encode the fact the index has multiple parent.
    /// We don't want to duplicate its content (because this crash TreeView)
    /// so we force it to report zero children.
    if(index.column()>0)
        return false;

    sofa::core::objectmodel::Base* currentBase ;
    if (!index.isValid()){
        return true;
    }else{
        currentBase=static_cast<sofa::core::objectmodel::Base*>(index.internalPointer());
    }

    /// Test if we are a not and not a baseobject.
    sofa::core::objectmodel::BaseNode* basenode = currentBase->toBaseNode();
    if(!basenode)
        return false;

    Node* node = static_cast<Node*>(basenode);
    return !node->child.empty() || !node->object.empty();
}

int SofaSceneItemModel::columnCount(const QModelIndex &index) const
{
    SOFA_UNUSED(index);
    return 1;
}

sofa::qtquick::SofaComponent* SofaSceneItemModel::getComponentFromIndex(const QModelIndex& index) const
{
    if (!index.isValid())
        return nullptr;

    sofa::core::objectmodel::Base* currentBase=static_cast<sofa::core::objectmodel::Base*>(index.internalPointer());

    if(!currentBase)
        return nullptr;

    return new SofaComponent(m_scene, currentBase);
}

QVariant SofaSceneItemModel::data(const QModelIndex &index, int role) const
{    
    if (enableDebug)
        qDebug() << "data: " << index << "role " << role ;
    sofa::core::objectmodel::Base* currentBase;
    sofa::core::objectmodel::BaseNode* currentNode;

    if (!index.isValid()){
        return false;
    }else{
        currentBase=static_cast<sofa::core::objectmodel::Base*>(index.internalPointer());
    }

    currentNode = currentBase->toBaseNode();

    switch(static_cast<Roles>(role))
    {
    case Roles::Name:
        return QVariant(QString::fromStdString(currentBase->getName()));
    case Roles::TypeName:
        return QVariant::fromValue(QString::fromStdString(currentBase->getClass()->className));
    case Roles::IsNode:
        return QVariant(currentBase->toBaseNode()!=nullptr);
    case Roles::IsMultiParent:
        if(currentNode)
            return QVariant(currentBase->toBaseNode()->getNbParents()!=1);
        else
            return QVariant(false);
    case Roles::HasMultiParent:
        if(currentNode)
            return QVariant(index.column()>0);
        else
            return QVariant(false);
    case Roles::IsEnabled:
        return QVariant(true);
    case Roles::Row:
        return QVariant(index.row());
    }

    //qDebug() << "data: " << index << "role " << role ;
    return QVariant(QString("damien"));
}

QHash<int, QByteArray> SofaSceneItemModel::roleNames() const
{
    /// Create a static mapping to link the "role" number as Qt is using and the corresponding
    /// textual represresentation; The Roles are encoded using an 'enum class' so they don't
    /// automatically convert to int value in the constructor initializer_list.
    static QHash<int, QByteArray> mapping {{
            { int(Roles::Name), "name" },
            { int(Roles::TypeName), "typename" },
            { int(Roles::IsNode), "isNode" },
            { int(Roles::IsMultiParent), "isMultiParent" },
            { int(Roles::HasMultiParent), "hasMultiParent" },
            { int(Roles::IsEnabled), "isEnabled" },
            { int(Roles::Row), "row" }
                                           }};
    return mapping;
}

size_t rrowCount(Node* parent)
{
    if (parent == nullptr)
        return 0;
    return parent->child.size() + parent->object.size() ;
}

size_t rrowCount_recurse(Node* node)
{
    if (node == nullptr)
        return 0;
    size_t i = 0;
    for (Node::SPtr child: node->child)
        i += 1 + rrowCount_recurse(child.get());
    return i + node->object.size() ;
}

void SofaSceneItemModel::onAddChildBegin(Node* target, Node* child)
{
    QModelIndex parentIndex = index(target);
    int i = int(rrowCount(target));

//    msg_info("b") << "=========== Adding child node " << child->getName() << " to: " << ((target) ? target->getName() : "NULL") << " (" << parentIndex.row() << ")";
//    msg_warning("       ") << target->getName() << " row is: " << parentIndex.row();
//    msg_warning("       ") << child->getName() <<  " location in parent is: " << i;
//    msg_warning("       ") << "nb of additional rows to add: " << int(rrowCount_recurse(child));

//    qDebug() << "parent index: " << parentIndex;


    msg_info("Pointer Values: ") << "New node: " << child << " " << child->getName() << "\nParent: " << target << " " << target->getName()  << "\nRoot: " << m_root.get() << " " << m_root->getName() ;

    enableDebug = true;
    beginInsertRows(parentIndex, i, i + int(rrowCount_recurse(child)));
}

void SofaSceneItemModel::onAddChildEnd(Node* target, Node* child)
{
    SOFA_UNUSED(target);
    SOFA_UNUSED(child);
    endInsertRows();

    enableDebug = false;
//    qDebug() << "child index: " << index(child);
//    msg_info("e") << "========== " << child->getName() << "added at row" << index(child).row() << " ==========";
}

void SofaSceneItemModel::onRemoveChildBegin(Node* parent, Node* child)
{
//    msg_info("b") << "======== Removing child node " << child->getName() << " from: " << parent->getName();

    QModelIndex parentIndex = index(parent);
    int childIndex = index(child).row();

//    msg_info("b") << "=========== Removing child node " << child->getName() << " from: " << ((parent) ? parent->getName() : "NULL") << " (" << parentIndex.row() << ")";
//    qDebug() << "  parent location is: " << parentIndex.row();
//    qDebug() << "       child location is: " << childIndex;
//    qDebug() << "       nb of additional rows to remove: " << int(rrowCount_recurse(child)) ;

    beginRemoveRows(parentIndex, childIndex, childIndex + int(rrowCount_recurse(child)));
}

void SofaSceneItemModel::onRemoveChildEnd(Node* parent, Node* child)
{
    SOFA_UNUSED(child);
    SOFA_UNUSED(parent);
    endRemoveRows();
//    msg_info("e") << "========== " << child->getName() << "removed ==========";
}



void SofaSceneItemModel::onAddObjectBegin(Node* parent, core::objectmodel::BaseObject* obj)
{
    SOFA_UNUSED(obj);
//    msg_info("b") << "============= Adding object " << obj->getName() << " to: " << parent->getName();
    QModelIndex parentIndex = index(parent);
    int objIndex = int(parent->object.size());


//    qDebug() << "  parent location is: " << parentIndex.row();
//    qDebug() << "       child location is: " << objIndex;

    beginInsertRows(parentIndex, objIndex, objIndex);
}
void SofaSceneItemModel::onAddObjectEnd(Node* parent, core::objectmodel::BaseObject* obj)
{
    SOFA_UNUSED(obj);
    SOFA_UNUSED(parent);
    endInsertRows();
//    msg_info("b") << "========== Adding object done: " << obj->getName();
}
void SofaSceneItemModel::onRemoveObjectBegin(Node* parent, core::objectmodel::BaseObject* obj)
{
//    msg_info("b") << "============= Removing object " << obj->getName() << " from: " << parent->getName();
    QModelIndex parentIndex = index(parent);
    int objIndex = index(parent, obj).row();

//    qDebug() << "  parent location is: " << parentIndex.row();
//    qDebug() << "       child location is: " << objIndex ;

    beginRemoveRows(parentIndex, objIndex, objIndex);
}
void SofaSceneItemModel::onRemoveObjectEnd(Node* parent, core::objectmodel::BaseObject* obj)
{
    SOFA_UNUSED(obj);
    SOFA_UNUSED(parent);
    endRemoveRows();
//    msg_info("b") << "========== Removing object done: " << obj->getName();
}


SofaScene* SofaSceneItemModel::sofaScene() const
{
    return m_scene;
}

void SofaSceneItemModel::setSofaScene(SofaScene* newScene)
{    
    m_scene = newScene;
    msg_info("SofaSceneItemModel") << this << " Setting sofaScene. Again.";

    /// The scene passed to this model is tracked to monitor if its status has changed.
    /// If this is the case then the model needs to be reseted.
    connect(m_scene, &SofaScene::rootNodeChanged, this, &SofaSceneItemModel::handleRootNodeChange);
    emit sofaSceneChanged();
}

void SofaSceneItemModel::handleRootNodeChange()
{    
    enableDebug = false;
    /// At this step the m_root member is still containing the old
    /// scene that will be removed.
    if(m_root.get()!=nullptr)
    {
        m_root->removeListener(this);
    }

    /// Flip the old pointer.
    m_root = m_scene->sofaRootNode();

    /// Register now the listener to the new scene graph.
    m_root->addListener(this);

    beginResetModel();
    endResetModel();

}


} /// namespace _sofasceneitemmodel_
} /// namespace qtquick
} /// namespace sofa
