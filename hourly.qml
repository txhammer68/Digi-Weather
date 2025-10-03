import QtQuick 2.9
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.5
import QtQuick.Controls 1.5 as QC15
import org.kde.plasma.core 2.1

Rectangle {
    id:root
    visible: true
    width: 840
    height:120
    color:"black"

     property string url2:"/home/data/Downloads/2day.json"

     property var whourly:{}

      Component.onCompleted: {
      getWeather(url2);
      }

      function getWeather(url){  // read weather icon code from file
      var xhr = new XMLHttpRequest;
      xhr.open("GET", url,false); // set Method and File  true=asynchronous
      xhr.onreadystatechange = function () {
         if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
            var response = xhr.responseText;
            whourly=JSON.parse(response);
         }
      }
      xhr.send(); // begin the request
      return null;
   }

   Component{
   id:hourlyList

   Text {
                text:Qt.formatTime(new Date(whourly.validTimeUtc[index]*1000))
                color:"white"
                font.pointSize:11
                font.bold:true

                Image {
                    anchors.top:parent.bottom
                    anchors.left:parent.left
                    source:"../icons/"+whourly.iconCode[index]+".png"
                    width:22
                    height:22
                    smooth:true
                    anchors.leftMargin:-15
                    //anchors.rightMargin:15

                    Text {
                        anchors.top:parent.top
                        anchors.left:parent.right
                        text:"  "+Math.round(whourly.temperature[index])+"°"+" | "+Math.floor(whourly.precipChance[index]/10)*10+"%"
                        color:"white"
                        font.pointSize:10
                        anchors.rightMargin:10
                    }
                }
            }
        }

        ListView {
            id:listView
            focus:true
            spacing:25
            anchors.fill:root
            anchors.margins:10
            width:parent.width
            height:parent.height
            model:whourly.temperature
            contentWidth: 500  // 1 of 2 newly inserted lines of code
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            orientation:ListView.Horizontal
            //cacheBuffer:315*18
            //highlight:highlightView
            clip:true
            interactive:true
            snapMode :ListView.SnapToItem
            //keyNavigationEnabled: true
            //keyNavigationWraps: false // endless scrolling
            delegate:hourlyList

            ScrollBar.horizontal: ScrollBar {
                id:scroll
            policy: ScrollBar.AlwaysOn
            active: ScrollBar.AlwaysOn
            interactive: true
            anchors.top:listView.top
            anchors.left:listView.left
            anchors.fill:listView
            MouseArea {
                        anchors.fill: parent
                        //drag.target: parent
                        onWheel: {
                            if (wheel.angleDelta.y > 0) scroll.decrease()
                            else scroll.increase()
                        }
                    }
            }
        }
}
