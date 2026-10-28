.pragma library
.import "Http.js" as Http

// HTTPS providers that need no API key, tried in order until one answers
const providers = [
    { url: "https://get.geojs.io/v1/ip/geo.json", latitude: "latitude", longitude: "longitude" },
    { url: "https://ipwho.is/?fields=latitude,longitude", latitude: "latitude", longitude: "longitude" }
];

// Calls callback({latitude, longitude}) for the current IP address, or callback(null) if every provider failed
function fetchIpCoordinates(callback, index = 0) {
    if (index >= providers.length) {
        callback(null);
        return;
    }
    let provider = providers[index];
    Http.getJson(provider.url, function (data, reason) {
        let latitude = data ? parseFloat(data[provider.latitude]) : NaN;
        let longitude = data ? parseFloat(data[provider.longitude]) : NaN;
        if (isNaN(latitude) || isNaN(longitude)) {
            console.warn(`IP location failed (${provider.url}): ${reason || "no coordinates in response"}`);
            fetchIpCoordinates(callback, index + 1);
            return;
        }
        callback({ latitude: latitude, longitude: longitude });
    });
}

// Calls callback({latitude, longitude, name, region, country}) for the best match of a place name such as
// "Paris" or "Paris, Texas", false if nothing matched, or null if the request failed
function fetchCityCoordinates(name, language, callback) {
    let url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(name)}&count=1&language=${language}&format=json`;
    Http.getJson(url, function (data, reason) {
        if (!data) {
            console.warn(`city search failed: ${reason}`);
            callback(null);
            return;
        }
        let place = data.results && data.results[0];
        callback(place ? { latitude: place.latitude, longitude: place.longitude, name: place.name, region: place.admin1, country: place.country } : false);
    });
}
