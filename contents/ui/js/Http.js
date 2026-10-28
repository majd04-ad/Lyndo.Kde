.pragma library

// Identifies the widget to the services it talks to, Nominatim rejects generic user agents
const userAgent = "Lyndo.Kde/0.6.0 (KDE Plasma widget; https://github.com/majd04-ad/Lyndo.Kde)";

// Calls callback(data) with the parsed JSON response, or callback(null, reason) on any failure
function getJson(url, callback) {
    let req = new XMLHttpRequest();
    req.open("GET", url, true);
    req.setRequestHeader("User-Agent", userAgent);

    // onerror can fire alongside readyState DONE, report only once
    let done = false;
    function finish(data, reason) {
        if (done) return;
        done = true;
        callback(data, reason);
    }

    req.onreadystatechange = function () {
        if (req.readyState !== XMLHttpRequest.DONE) return;
        if (req.status !== 200) {
            finish(null, `HTTP ${req.status}`);
            return;
        }
        let data;
        try {
            data = JSON.parse(req.responseText);
        } catch (e) {
            finish(null, `invalid JSON: ${e}`);
            return;
        }
        finish(data);
    };

    req.onerror = function () {
        finish(null, "network error");
    };

    req.send();
}
