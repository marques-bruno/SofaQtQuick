import QtQuick 2.12
import Sofa.Core.SofaFactory 1.0
import Sofa.Core.SofaNode 1.0
import QmlGTestCase 1.0

QmlGTestCase
{
    function tst_gets()
    {
        var n = SofaFactory.createNode()
        assert_eq(n.getName(), "unnamed")
        assert_eq(n.getClassName(), "DAGNode")
        assert_eq(n.getTemplateName(), "")
    }

    function tst_getData()
    {
        var n = SofaFactory.createNode()
        assert_throw(function(){ n.getData("unknown")} )
        assert_eq(n.getData("name").value, "unnamed")
    }

    function tst_createChild()
    {
        var n = SofaFactory.createNode()
        var c = n.createChild("Child")
        assert_eq(c.getData("name").value, "Child")
    }

    function tst_getChildren()
    {
        var n = SofaFactory.createNode()
        var c1 = n.createChild("Child1")
        var c2 = n.createChild("Child2")
        assert_eq(n.getChildren().size(), 2)
    }

    function tst_getObject()
    {
        var n = SofaFactory.createNode()
        var o = n.createObject("MechanicalObject", {name:"test"})
        assert_eq(n.getObject("test").getName(),"test")
    }

    function tst_getInitReInit()
    {
        var n = SofaFactory.createNode()
        n.init()
        n.reinit()
    }

    function tst_downCast()
    {
        var nn = SofaFactory.createNode()
        var n =  as_SofaNode(nn)
    }

    function tst_get()
    {
        var node = SofaFactory.createNode("root")
        var node2 = node.createChild("child")
        var o = node2.createObject("MechanicalObject", {name:"dofs"})
        var data =  node2.get("/child/dofs.name")
        assert_eq(data.getName(),"name")
        assert_eq(data.getValue(),"dofs")
        var obj =  node2.get("/child/dofs")
        assert_eq(obj.getName(),"dofs")
        assert_eq(obj.getClassName(),"MechanicalObject")
        var n =  node.get("/child")
        assert_eq(n.getName(),"child")
        assert_eq(n.getClassName(),"DAGNode")
    }
}
