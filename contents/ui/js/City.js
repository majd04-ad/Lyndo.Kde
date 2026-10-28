.pragma library
.import "Http.js" as Http

// Calls callback(name) with the city, town or region at the coordinates, "" if the place has no name
// (e.g. open sea), or null if the request failed
function fetchCityName(latitude, longitude, language, callback) {
    let url = `https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&lat=${latitude}&lon=${longitude}&accept-language=${language}`;
    Http.getJson(url, function (data, reason) {
        if (!data) {
            console.warn(`city lookup failed: ${reason}`);
            callback(null);
            return;
        }
        let address = data.address || {};
        callback(address.city || address.town || address.village || address.municipality || address.county || address.state || "");
    });
}
