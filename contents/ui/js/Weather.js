.pragma library
.import "Http.js" as Http

// Calls callback({temperature, code}) with the current temperature in °C and WMO weather code,
// or callback(null) if the request failed
function fetchCurrentWeather(latitude, longitude, callback) {
    let url = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,weather_code&timezone=auto`;
    Http.getJson(url, function (data, reason) {
        let current = data && data.current;
        if (!current || typeof current.temperature_2m !== "number") {
            console.warn(`weather request failed: ${reason || "no current conditions in response"}`);
            callback(null);
            return;
        }
        callback({ temperature: current.temperature_2m, code: current.weather_code });
    });
}

// WMO weather codes grouped into the conditions the widget names
const conditions = {
    0: "clear", 1: "clear", 2: "cloudy", 3: "cloudy",
    45: "fog", 48: "fog",
    51: "drizzle", 53: "drizzle", 55: "drizzle", 56: "drizzle", 57: "drizzle",
    61: "rain", 63: "rain", 65: "rain", 66: "rain", 67: "rain",
    71: "snow", 73: "snow", 75: "snow", 77: "hail",
    80: "showers", 81: "showers", 82: "showers", 85: "showers", 86: "showers",
    95: "storm", 96: "storm", 99: "storm"
};

const names = {
    en: { clear: "Clear", cloudy: "Cloudy", fog: "Fog", drizzle: "Drizzle", rain: "Rain", snow: "Snow", hail: "Hail", showers: "Showers", storm: "Storm" },
    es: { clear: "Despejado", cloudy: "Nublado", fog: "Niebla", drizzle: "Llovizna", rain: "Lluvia", snow: "Nieve", hail: "Granizo", showers: "Aguaceros", storm: "Tormenta" },
    hi: { clear: "साफ", cloudy: "बादल", fog: "कोहरा", drizzle: "बूँदा बाँदी", rain: "वर्षा", snow: "बर्फ", hail: "ओला", showers: "झरी", storm: "तूफान" },
    fr: { clear: "Clair", cloudy: "Nuageux", fog: "Brouillard", drizzle: "Bruine", rain: "Pluie", snow: "Neige", hail: "Grêle", showers: "Averses", storm: "Tempête" },
    ru: { clear: "Ясно", cloudy: "Облачно", fog: "Туман", drizzle: "Морось", rain: "Дождь", snow: "Снег", hail: "Град", showers: "Ливни", storm: "Буря" },
    de: { clear: "Klar", cloudy: "Bewölkt", fog: "Nebel", drizzle: "Niesel", rain: "Regen", snow: "Schnee", hail: "Hagel", showers: "Schauer", storm: "Sturm" },
    it: { clear: "Sereno", cloudy: "Nuvoloso", fog: "Nebbia", drizzle: "Pioggerella", rain: "Pioggia", snow: "Neve", hail: "Grandine", showers: "Rovesci", storm: "Tempesta" },
    pt: { clear: "Claro", cloudy: "Nublado", fog: "Nevoeiro", drizzle: "Garoa", rain: "Chuva", snow: "Neve", hail: "Granizo", showers: "Chuvas", storm: "Tempestade" },
    ja: { clear: "晴れ", cloudy: "曇り", fog: "霧", drizzle: "霧雨", rain: "雨", snow: "雪", hail: "ひょう", showers: "にわか雨", storm: "嵐" },
    zh: { clear: "晴朗", cloudy: "多云", fog: "雾", drizzle: "小雨", rain: "雨", snow: "雪", hail: "冰雹", showers: "阵雨", storm: "暴风" },
    ko: { clear: "맑음", cloudy: "흐림", fog: "안개", drizzle: "이슬비", rain: "비", snow: "눈", hail: "우박", showers: "소나기", storm: "폭풍" },
    ar: { clear: "صافي", cloudy: "غائم", fog: "ضباب", drizzle: "رذاذ", rain: "مطر", snow: "ثلج", hail: "بَرَد", showers: "زخات", storm: "عاصفة" },
    bn: { clear: "পরিষ্কার", cloudy: "মেঘলা", fog: "কুয়াশা", drizzle: "ঝিরঝিরি", rain: "বৃষ্টি", snow: "তুষার", hail: "শিলা", showers: "ঝরণা", storm: "ঝড়" }
};

// Short name of the weather condition in the given language (English if not translated), "" if unknown
function conditionText(language, code) {
    let condition = conditions[code];
    return condition ? (names[language] || names.en)[condition] : "";
}
