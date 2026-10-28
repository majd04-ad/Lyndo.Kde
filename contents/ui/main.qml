import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import "components" as Components
import "js/NumberWords.js" as NumberWords

PlasmoidItem {
    id: root
    // initial size on the desktop
    width: 450
    height: 150

    readonly property color textColor: Plasmoid.configuration.colorHex
    readonly property color accentColor: Plasmoid.configuration.accentColor
    readonly property bool fahrenheit: Plasmoid.configuration.temperatureUnit === 1

    property string monthText
    property string dayText
    property string timeText
    property string dayNumber

    readonly property string weatherText: {
        if (!weatherData.hasWeather) {
            return "?"
        }
        let temperature = Math.round(fahrenheit ? weatherData.temperature * 9 / 5 + 32 : weatherData.temperature) + "°"
        let text = weatherData.conditionText ? weatherData.conditionText + " " + temperature : temperature
        return weatherData.city ? text + "  ·  " + weatherData.city : text
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground
    preferredRepresentation: fullRepresentation

    // Qt.formatDateTime always uses English names, toLocale*String follows the system locale
    function updateClock() {
        let now = new Date()
        monthText = now.toLocaleDateString(Qt.locale(), "MMMM").substring(0, 4) + "."
        dayText = now.toLocaleDateString(Qt.locale(), "dddd").substring(0, 3)
        timeText = now.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        dayNumber = now.toLocaleDateString(Qt.locale(), "d")
    }

    // milliseconds until the next minute starts, plus a little margin
    function msToNextMinute() {
        return 60000 - Date.now() % 60000 + 100
    }

    Component.onCompleted: updateClock()

    Components.WeatherData {
        id: weatherData
    }

    FontLoader {
        id: robotoFont
        source: "../Fonts/Roboto Black.ttf"
    }
    FontLoader {
        id: scriptFont
        source: "../Fonts/MrsSaintDelafield-Regular.ttf"
    }
    FontLoader {
        id: fivoFont
        source: "../Fonts/Fivo Sans Light.otf"
    }

    // realigned on every tick so the clock changes right at the start of each minute
    Timer {
        interval: root.msToNextMinute()
        running: true
        onTriggered: {
            root.updateClock()
            interval = root.msToNextMinute()
            restart()
        }
    }

    fullRepresentation: Item {
        id: view
        Layout.preferredWidth: 450
        Layout.preferredHeight: 150

        Item {
            id: content
            width: Math.min(view.width, view.height * 2.5)
            height: width / 2.5

            Text {
                id: month
                text: root.monthText
                anchors.left: parent.left
                anchors.leftMargin: day.implicitWidth
                font.family: robotoFont.name
                // hollow letters: only the outline is drawn
                color: "transparent"
                style: Text.Outline
                styleColor: root.textColor
                renderType: Text.CurveRendering
                font.capitalization: Font.Capitalize
                font.pixelSize: content.height * .7
                font.letterSpacing: content.height * .035
            }
            Text {
                id: day
                text: root.dayText
                font.pixelSize: content.height * .35
                font.family: robotoFont.name
                color: root.textColor
                font.capitalization: Font.Capitalize
                anchors.verticalCenter: month.verticalCenter
            }
            Text {
                text: root.timeText
                anchors.top: day.bottom
                anchors.topMargin: -day.implicitHeight * .15
                font.family: robotoFont.name
                color: root.textColor
                renderType: Text.NativeRendering
                font.pixelSize: content.height * .06
            }
            Text {
                text: NumberWords.dayNumberText(weatherData.language, root.dayNumber)
                font.pixelSize: content.height * .42
                font.family: scriptFont.name
                color: root.accentColor
                anchors.left: month.left
                font.capitalization: Font.Capitalize
                anchors.leftMargin: month.implicitWidth * .09
                anchors.verticalCenter: month.verticalCenter
            }
            Rectangle {
                id: point
                width: content.height * .01
                height: width
                radius: height / 2
                anchors.top: month.bottom
                anchors.left: parent.left
                color: root.textColor
                anchors.leftMargin: day.implicitWidth * .95
            }
            Text {
                text: root.weatherText
                anchors.verticalCenter: point.verticalCenter
                anchors.left: point.right
                color: root.textColor
                anchors.leftMargin: point.width * 4
                font.pixelSize: content.height * .1
                renderType: Text.NativeRendering
                font.family: fivoFont.name
            }
        }
    }
}
