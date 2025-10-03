import QtQuick 2.9
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.5

Item {
    width:600
    height:400

    property string d1:"D"
    property string c1:"Cloudy"

Text{
text:d1 == "D" && !c1.includes("Cloud") ? "bk2.png" : "bk1.png"
color:"black"
}
}
