import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQuickControls

import "js/Location.js" as Location

KCM.SimpleKCM {
    id: page

    property alias cfg_locationMode: locationMode.currentIndex
    property alias cfg_cityName: cityName.text
    property alias cfg_latitudeC: latitude.text
    property alias cfg_longitudeC: longitude.text
    property alias cfg_temperatureUnit: temperatureUnit.currentIndex
    property alias cfg_colorHex: textColor.color
    property alias cfg_accentColor: accentColor.color

    // result of looking up the typed city, shown under the field
    property string cityStatus: ""
    property bool cityStatusError: false

    function searchCity() {
        let name = cityName.text.trim()
        if (name === "") {
            cityStatus = i18n("Enter a city, otherwise the location from the IP address is used")
            cityStatusError = true
            return
        }
        cityStatus = i18n("Searching…")
        cityStatusError = false
        Location.fetchCityCoordinates(name, Qt.locale().name.substring(0, 2), function (place) {
            // ignore answers for text that was changed in the meantime
            if (name !== cityName.text.trim()) {
                return
            }
            if (place) {
                cityStatus = i18n("Found: %1", [place.name, place.region, place.country].filter(Boolean).join(", "))
                cityStatusError = false
            } else if (place === false) {
                cityStatus = i18n("No city with this name was found, the location from the IP address will be used instead")
                cityStatusError = true
            } else {
                cityStatus = i18n("Could not search for the city, check your internet connection")
                cityStatusError = true
            }
        })
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: locationMode
            Kirigami.FormData.label: i18n("Location:")
            model: [i18n("Automatic (from IP address)"), i18n("City"), i18n("Coordinates")]
            onCurrentIndexChanged: citySearch.restart()
        }

        QQC2.TextField {
            id: cityName
            visible: locationMode.currentIndex === 1
            Kirigami.FormData.label: i18n("City:")
            placeholderText: i18n("e.g. Paris or Paris, Texas")
            onTextChanged: citySearch.restart()
        }
        QQC2.Label {
            visible: locationMode.currentIndex === 1 && page.cityStatus !== ""
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            wrapMode: Text.WordWrap
            color: page.cityStatusError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
            text: page.cityStatus
        }
        // waits for typing to pause before searching
        Timer {
            id: citySearch
            interval: 600
            onTriggered: {
                if (locationMode.currentIndex === 1) {
                    page.searchCity()
                }
            }
        }

        QQC2.TextField {
            id: latitude
            visible: locationMode.currentIndex === 2
            Kirigami.FormData.label: i18n("Latitude:")
            placeholderText: i18n("-90 to 90")
            validator: DoubleValidator { bottom: -90; top: 90; locale: "C"; notation: DoubleValidator.StandardNotation }
            color: acceptableInput ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
        }
        QQC2.TextField {
            id: longitude
            visible: locationMode.currentIndex === 2
            Kirigami.FormData.label: i18n("Longitude:")
            placeholderText: i18n("-180 to 180")
            validator: DoubleValidator { bottom: -180; top: 180; locale: "C"; notation: DoubleValidator.StandardNotation }
            color: acceptableInput ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
        }
        QQC2.Label {
            visible: locationMode.currentIndex === 2
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
            wrapMode: Text.WordWrap
            color: latitude.acceptableInput && longitude.acceptableInput ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
            text: latitude.acceptableInput && longitude.acceptableInput
                ? i18n("You can look up coordinates at <a href=\"https://open-meteo.com/en/docs\">open-meteo.com</a>")
                : i18n("Invalid coordinates, the location from the IP address will be used instead")
            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.ComboBox {
            id: temperatureUnit
            Kirigami.FormData.label: i18n("Temperature unit:")
            model: [i18n("Celsius (°C)"), i18n("Fahrenheit (°F)")]
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        KQuickControls.ColorButton {
            id: textColor
            Kirigami.FormData.label: i18n("Color:")
            dialogTitle: i18n("Color")
        }
        KQuickControls.ColorButton {
            id: accentColor
            Kirigami.FormData.label: i18n("Accent color:")
            dialogTitle: i18n("Accent Color")
        }
    }
}
