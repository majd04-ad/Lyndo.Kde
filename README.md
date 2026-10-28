# Lyndo Kde

A clock and weather widget for the KDE Plasma 6 desktop. It shows the time written out in words, the
weekday and date, and the current weather and place name.

This is a maintained fork of [Lyndo Kde](https://store.kde.org/p/2188581/) by zayronxio, originally
published on the KDE Store under the GPL-3.0-or-later.

## Features

- Time in words, translated with the system language
- Current temperature and conditions from [Open-Meteo](https://open-meteo.com/), no API key needed
- Three ways to set the location:
  - **Automatic**: estimated from your IP address
  - **City**: type a city name, for example "Paris, Texas" or "München"
  - **Coordinates**: enter latitude and longitude
- Celsius or Fahrenheit
- Configurable text and accent colors
- All network requests use HTTPS
- Failed lookups are logged as warnings, so they don't show up in `journalctl -p 3`

## Requirements

- KDE Plasma 6.0 or newer

## Installation

```sh
git clone https://github.com/majd04-ad/Lyndo.Kde.git
kpackagetool6 --type Plasma/Applet --install Lyndo.Kde
```

Then right-click the desktop, choose **Add Widgets…** and search for "Lyndo Kde".

To update after pulling new changes:

```sh
kpackagetool6 --type Plasma/Applet --upgrade Lyndo.Kde
```

To remove it:

```sh
kpackagetool6 --type Plasma/Applet --remove Lyndo.Kde
```

To try it in a window without adding it to the desktop:

```sh
plasmoidviewer -a Lyndo.Kde
```

## Privacy

The widget contacts these services, all over HTTPS:

| Service | Used for | When |
| --- | --- | --- |
| [GeoJS](https://www.geojs.io/), with [ipwho.is](https://ipwhois.io/) as a fallback | Estimating your location from your IP address | Automatic mode only |
| [Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api) | Finding the city you typed | City mode only |
| [Open-Meteo Forecast](https://open-meteo.com/en/docs) | Current weather | Always |
| [Nominatim](https://nominatim.org/) (OpenStreetMap) | Turning coordinates into a place name | Automatic and Coordinates modes |

Set the location by city or coordinates if you don't want your IP address sent to a geolocation
service.

## Credits

- Original widget: [zayronxio](https://store.kde.org/p/2188581/)
- Weather and geocoding data: [Open-Meteo](https://open-meteo.com/), licensed under
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Place names: © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright), licensed
  under the [ODbL](https://opendatacommons.org/licenses/odbl/)

### Fonts

The fonts bundled in [contents/Fonts](contents/Fonts) are free to redistribute:

| Font | Author | License |
| --- | --- | --- |
| Roboto Black | Christian Robertson, Google | [Apache 2.0](contents/Fonts/LICENSE-Apache-2.0.txt) |
| Fivo Sans Light | Alexander Slobzheninov | [SIL OFL 1.1](contents/Fonts/OFL.txt) |
| Mrs Saint Delafield | Alejandro Paul | [SIL OFL 1.1](contents/Fonts/OFL.txt) |

The original release used Tuesday Night and NTOutline. Their licenses don't clearly allow
redistribution, so this fork replaces them with Mrs Saint Delafield and an outlined Roboto Black.

## License

[GPL-3.0-or-later](LICENSE). The bundled fonts keep their own licenses, listed above.
