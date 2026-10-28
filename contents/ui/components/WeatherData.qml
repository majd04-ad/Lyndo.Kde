import QtQuick
import org.kde.plasma.plasmoid

import "../js/Location.js" as Location
import "../js/City.js" as City
import "../js/Weather.js" as Weather

// Keeps the location, place name and current weather up to date
Item {
    id: root

    readonly property string language: Qt.locale().name.substring(0, 2)

    // 0 = automatic from the IP address, 1 = city name, 2 = coordinates; an empty city or invalid
    // coordinates fall back to the IP location
    readonly property int locationMode: Plasmoid.configuration.locationMode
    readonly property string cityName: Plasmoid.configuration.cityName.trim()
    readonly property bool coordinatesValid: validCoordinate(Plasmoid.configuration.latitudeC, 90)
        && validCoordinate(Plasmoid.configuration.longitudeC, 180)

    property real latitude: NaN
    property real longitude: NaN
    readonly property bool hasLocation: !isNaN(latitude) && !isNaN(longitude)

    property string city: ""
    property real temperature: NaN // °C
    property int weatherCode: -1
    readonly property bool hasWeather: !isNaN(temperature)
    readonly property string conditionText: Weather.conditionText(language, weatherCode)

    readonly property int maxRetries: 5
    property int failures: 0
    property int cityFailures: 0

    readonly property string locationSettings: [locationMode, cityName, Plasmoid.configuration.latitudeC, Plasmoid.configuration.longitudeC].join()
    onLocationSettingsChanged: scheduleRefresh(500)

    Component.onCompleted: refresh()

    function validCoordinate(value, limit) {
        let n = Number(value)
        return value !== "" && value !== "0" && !isNaN(n) && Math.abs(n) <= limit
    }

    function refresh() {
        if (locationMode === 1 && cityName !== "") {
            Location.fetchCityCoordinates(cityName, language, function (place) {
                if (place) {
                    setLocation(place.latitude, place.longitude, place.name)
                    fetchWeather()
                } else if (place === false) {
                    console.warn(`no city called "${cityName}" found, using the IP location`)
                    refreshFromIp()
                } else if (hasLocation) {
                    // the search failed, keep using the previous location
                    fetchWeather()
                } else {
                    retry()
                }
            })
        } else if (locationMode === 2 && coordinatesValid) {
            setLocation(Number(Plasmoid.configuration.latitudeC), Number(Plasmoid.configuration.longitudeC))
            fetchWeather()
        } else {
            refreshFromIp()
        }
    }

    function refreshFromIp() {
        Location.fetchIpCoordinates(function (coordinates) {
            if (coordinates) {
                setLocation(coordinates.latitude, coordinates.longitude)
            }
            // if the lookup failed, keep using the previous location
            if (hasLocation) {
                fetchWeather()
            } else {
                retry()
            }
        })
    }

    // name is the place name when already known, otherwise it is looked up from the coordinates
    function setLocation(newLatitude, newLongitude, name) {
        if (newLatitude === latitude && newLongitude === longitude) {
            if (name) {
                city = name
            }
            return
        }
        latitude = newLatitude
        longitude = newLongitude
        cityFailures = 0
        cityRetry.stop()
        if (name) {
            city = name
        } else {
            city = ""
            fetchCity()
        }
    }

    function fetchWeather() {
        Weather.fetchCurrentWeather(latitude, longitude, function (result) {
            if (result) {
                temperature = result.temperature
                weatherCode = result.code
                failures = 0
            } else {
                retry()
            }
        })
    }

    function fetchCity() {
        let requestedLatitude = latitude
        let requestedLongitude = longitude
        City.fetchCityName(latitude, longitude, language, function (name) {
            // ignore answers for a location we already moved away from
            if (requestedLatitude !== latitude || requestedLongitude !== longitude) {
                return
            }
            if (name !== null) {
                city = name
            } else if (cityFailures < maxRetries) {
                cityFailures++
                cityRetry.start()
            }
        })
    }

    // retries a failed update a few times, after that the regular refresh takes over
    function retry() {
        if (failures < maxRetries) {
            failures++
            scheduleRefresh(5000)
        }
    }

    function scheduleRefresh(delay) {
        pendingRefresh.interval = delay
        pendingRefresh.restart()
    }

    Timer {
        id: pendingRefresh
        onTriggered: root.refresh()
    }

    Timer {
        id: cityRetry
        interval: 6000
        onTriggered: root.fetchCity()
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            root.failures = 0
            if (root.hasLocation && root.city === "") {
                root.cityFailures = 0
                root.fetchCity()
            }
            root.refresh()
        }
    }
}
