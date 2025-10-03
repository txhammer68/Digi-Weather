import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasma5support as Plasma5Support

// weather app based off ipad weather app
// twc weather data
// fishing
// https://tpwd.texas.gov/fishboat/fish/action/reptmap.php?EcoRegion=GC
// txhammer
// 1/2023
// *********************************************************************************************************

ApplicationWindow {
   id:root
   visible: false
   width: 840
   height:650
   title: "Weather"
   color:"black"

   // Veðr - The Old Norse word for "weather". It is the root of the words for weather in Danish, Faroese, Norwegian, and Swedish.

   Shortcut {
        sequence: "Esc"
        onActivated: root.close()
    }

   // documentation - https://docs.google.com/document/d/1pXDXkT4wd4I77LxkBnltQ7tKG4GlOsDeRUPdaDDtAW8/edit

    //property string url1:"/home/Data/projects/QML/weather/TWC/1day.json"        // rainfall
    //property string url2:"/home/Data/projects/QML/weather/TWC/current.json"     // current conditions
    //property string url3:"/home/Data/projects/QML/weather/TWC/7day.json"        // forecast
    //property string url4:"/home/Data/projects/QML/weather/TWC/headlines.json"   // alerts
    //property string url5:"/home/Data/projects/QML/weather/TWC/hourly.json"      // hourly forecast

    //property string url1:"https://api.weather.com/v2/pws/observations/all/1day?stationId=KTXLAPOR73&format=json&units=e&apiKey=5fedbd808df145cdadbd808df105cd7b"
    property string url2:"https://api.weather.com/v3/wx/observations/current?language=en-US&apiKey=71f92ea9dd2f4790b92ea9dd2f779061&geocode=29.662731,-95.067247&units=e&format=json";
    property string url3:"https://api.weather.com/v3/wx/forecast/daily/7day?language=en-US&apiKey=71f92ea9dd2f4790b92ea9dd2f779061&geocode=29.662731,-95.067247&units=e&format=json"
    property string url4:"https://api.weather.com/v3/alerts/headlines?geocode=29.662731,-95.067247&format=json&language=en-US&apiKey=71f92ea9dd2f4790b92ea9dd2f779061"
    property string url5:"https://api.weather.com/v3/wx/forecast/hourly/2day?language=en-US&apiKey=71f92ea9dd2f4790b92ea9dd2f779061&geocode=29.662731,-95.067247&units=e&format=json"
    property string url6:"https://api.weather.com/v3/wx/globalAirQuality?language=en-US&geocode=29.662731,-95.067247&scale=EPA&format=json&apiKey=71f92ea9dd2f4790b92ea9dd2f779061"

    // air quaility index // working
    // https://api.weather.com/v3/wx/globalAirQuality?language=en&geocode=29.662731,-95.067247&scale=EPA&format=json&apiKey=21d8a80b3d6b444998a80b3d6b1449d3

    // when will it rain forecast /// working
    // https://api.weather.com/v1/geocode/29.66/-95.06/forecast/wwir.json?language=en-US&units=e&apiKey=21d8a80b3d6b444998a80b3d6b1449d3


    // tide reports // not working
    // https://api.weather.com/v3/wx/forecast/tides/daily/3day?tide=8670870&units=e&format=json&startDay=01&startMonth=10&startYear=2018&apiKey=yourApiKey
    // https://api.weather.com/v3/wx/forecast/tides/daily/3day?language=en&geocode=29.662731,-95.067247&units=e&format=json&startDay=13&startMonth=04&startYear=2023&apiKey=21d8a80b3d6b444998a80b3d6b1449d3

    //Mosquito index // not working
    // https://api.weather.com/v2/indices/mosquito/daily/3day?geocode=29.66,-95.06&language=en-US&format=json&apiKey=21d8a80b3d6b444998a80b3d6b1449d3
    // https://api.weather.com/v2/indices≈?geocode=29.66,-95.06&language=en-US&format=json&apiKey=21d8a80b3d6b444998a80b3d6b1449d3
    // https://api.weather.com/v2/indices/mosquito/daily/3day?postalCode=77571&countryCode=US&format=json&language=en-US&apiKey=21d8a80b3d6b444998a80b3d6b1449d3

    /// https://wiki.webcore.co/TWC_Weather#Conditions

    //property var rainfall:{}
    property var weather:{}
    property var wforecast:{}
    property var warnings:{}
    property var whourly:{}
    property var airQuality:{}
    property bool weatherWarnings:false
    property string radarImage:"SETX1_1280.jpg";
    property string img1:""
    property var cloudDesc:["Mostly", "Flurries", "Fog", "Haze","Smoke","Rain","Drizzle","Ice/Snow", "Snow","Wintry Mix","Sleet","Showers","Thunderstorms","Tornado","Tropical Storm","Hurricane","Strong Storms"]

    property var forecastIcons:[]
    property var forecastRains:[]

   Component.onCompleted: {
      //getWeather(url1);
      radarImage="https://cdns.abclocal.go.com/three/ktrk/weather/16_9/SETX1_1280.jpg";
      //visibleRadarImage:"https://s.w-x.co/staticmaps/wu/wu/satir1200_cur/usasc/20250114/0600z.gif"
      // https://cdn.star.nesdis.noaa.gov/GOES16/ABI/SECTOR/sp/11/600x600.jpg
      getWeather(url2);
      getWeather(url3);
      getWeather(url4);
      getWeather(url5);
      getWeather(url6);
      // weather.dayOrNight == "N" || cloudDesc.some(str=> weather.wxPhraseMedium.includes(str)) ? img1="bk1.png" : img1="bk2.png"

      // const isIncluded = stringsToTest.some(str => stringToCheck.includes(str));
     // root.visible=true;
     // mainLoader.source = "weatherApp.qml";
   }

   Loader {
      id: mainLoader
      anchors.fill: parent
      opacity: 0
      onSourceChanged:{
         opacity = 1
      }
      //focus: true
      Behavior on opacity {
         OpacityAnimator {
            duration: units.longDuration
            easing.type: Easing.InCubic
         }
      }

   }

   function getWeather(url){  // read weather icon code from file
      let xhr = new XMLHttpRequest;
      xhr.open("GET", url,false); // set Method and File  true=asynchronous
      xhr.onreadystatechange = function () {
         let x={};
         if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
            //var response = xhr.responseText;
            x=JSON.parse(xhr.responseText);
            parseWeatherData(url,x);
            xhr=null;
            x=null;
         }
      }
      xhr.send(); // begin the request
      return null;
   }

   function parseWeatherData(url,x) {

      if (url===url2) {
         weather=x;
         x=null
      }
       else if (url===url3) {
         wforecast=x;
         let i1=["","","","","","",""]
         let r1=["","","","","","",""]
         i1[0]="./icons/"+wforecast.daypart[0].iconCode[0]+".png";
         i1[1]="./icons/"+wforecast.daypart[0].iconCode[2]+".png";
         i1[2]="./icons/"+wforecast.daypart[0].iconCode[4]+".png";
         i1[3]="./icons/"+wforecast.daypart[0].iconCode[6]+".png";
         i1[4]="./icons/"+wforecast.daypart[0].iconCode[8]+".png";
         i1[5]="./icons/"+wforecast.daypart[0].iconCode[10]+".png";
         i1[6]="./icons/"+wforecast.daypart[0].iconCode[12]+".png";
         r1[0]=Math.floor(wforecast.daypart[0].precipChance[0]/10)*10+"%"
         r1[1]=Math.floor(wforecast.daypart[0].precipChance[2]/10)*10+"%"
         r1[2]=Math.floor(wforecast.daypart[0].precipChance[4]/10)*10+"%"
         r1[3]=Math.floor(wforecast.daypart[0].precipChance[6]/10)*10+"%"
         r1[4]=Math.floor(wforecast.daypart[0].precipChance[8]/10)*10+"%"
         r1[5]=Math.floor(wforecast.daypart[0].precipChance[10]/10)*10+"%"
         r1[6]=Math.floor(wforecast.daypart[0].precipChance[12]/10)*10+"%"
         //r1[i]=Math.floor((wforecast.forecast.daypart[0].precipChance[i < 2 ? 0 : i*2])/10)*10+"%"
         wforecast.daypart[0].iconCode[0] != null ? i1[0]="./icons/"+wforecast.daypart[0].iconCode[0] : i1[0]="./icons/"+wforecast.daypart[0].iconCode[1]

         wforecast.daypart[0].precipChance[0] != null ? r1[0]=Math.floor(wforecast.daypart[0].precipChance[0]/10)*10+"%" : r1[0]=Math.floor(wforecast.daypart[0].precipChance[1]/10)*10+"%"
         forecastIcons=i1;
         forecastRains=r1;
         i1=null;
         r1=null;
         x=null
      }
      else if (url===url4) {
         warnings=x;
         weatherWarnings=warnings.hasOwnProperty("alerts")
         x=null
      }
       else if (url===url5) {
         whourly=x;
         x=null
      }
       else if (url===url6) {
         airQuality=x;
         x=null;
         weather.dayOrNight == "N" || cloudDesc.some(str=> weather.wxPhraseMedium.includes(str)) ? img1="bk1.png" : img1="bk2.png"
         root.visible=true;
         mainLoader.source = "weatherApp.qml";
      }
      x=null;
      url=null;
      return null;
   }

   function dstinEffect(x) {
      var date=new Date(x);
      const january = new Date(date.getFullYear(), 0, 1).getTimezoneOffset();
      const july = new Date(date.getFullYear(), 6, 1).getTimezoneOffset();
      return Math.max(january, july) != date.getTimezoneOffset();
   }

   function dayTime () {
      if (dstinEffect(timeSource.data["Local"]["DateTime"])) {
         if (Qt.formatTime(timeSource.data["Local"]["DateTime"],"h") > 5 && Qt.formatTime(timeSource.data["Local"]["DateTime"],"h") < 21) {
            if (!weather.wxPhraseMedium.includes(clouds)) {
               return true;
            }
         }
         else return false;
      }
      else if (Qt.formatTime(timeSource.data["Local"]["DateTime"],"h") > 6 && Qt.formatTime(timeSource.data["Local"]["DateTime"],"h") < 18) {
         if  (!weather.wxPhraseMedium.includes(clouds)) {
            return true;
         }
      }
      else return false;
   }

   Plasma5Support.DataSource {
      id: timeSource
      engine: "time"
      connectedSources: ["Local"]
      interval: 1000
   }

   Timer{                  // timer to trigger update for weather info
      id: updateWeather
      interval: 10 * 60 * 1000 // every 10 minutes
      running: true
      repeat:  true
      triggeredOnStart:false
      onTriggered: {
         ///getWeather(url1);
         radar.source="SETX1_1280.jpg"
         radar.source="https://cdns.abclocal.go.com/three/ktrk/weather/16_9/SETX1_1280.jpg"
         getWeather(url2);
         getWeather(url3);
         getWeather(url4);
         getWeather(url5);
         getWeather(url6);
         //weather.dayOrNight == "N" || cloudDesc.some(str=> weather.wxPhraseMedium.includes(str)) ? img1="bk1.png" : img1="bk2.png"
      }
   }
}
