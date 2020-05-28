# Meteoroid
Set your wallpaper from various space sources.
[View the video demo](https://youtu.be/4zlm2yrzdrQ).

[![Banner](https://github.com/JeffResc/Meteoroid/raw/master/_assets/Banners/BannerWithText.png)](#)

Compatible with iOS 11 - 13.

Sources Include:
- [NASA (Image of the Day)](https://www.nasa.gov/multimedia/imagegallery/iotd.html)
- [NASA (Earth Observatory)](https://earthobservatory.nasa.gov/topic/image-of-the-day)
- [NASA (Astronomy Picture of the Day)](https://science.nasa.gov/astronomy-picture-of-the-day)
- [SpaceX Flickr](https://www.flickr.com/photos/spacex/)
- [NASA HQ Flickr](https://www.flickr.com/photos/nasahqphoto/)
- [NASA JPL Flickr](https://www.flickr.com/photos/nasa-jpl/)
- [NASA Johnson Flickr](https://www.flickr.com/photos/nasa2explore/)
- [NASA Kennedy Flickr](https://www.flickr.com/photos/nasakennedy/)
- [NASA Goddard Flickr](https://www.flickr.com/photos/gsfc/)
- [NASA Marshall Flickr](https://www.flickr.com/photos/nasamarshall/)

Features:
- Set where the image is applied to (homescreen, lockscreen, or both)
- Set the parallax to on or off
- An optional timer to automatically update the wallpaper at a certain time every 24 hours
- An advanced command line interface to customize how and when to update the wallpaper (see Advanced Usage)
- Set your source from four different space image sources (as listed above)
- If you really like that wallpaper you got, save it with the button in settings
- Manually update the wallpaper if you like

## Downloading and Installing
You can either [Download Meteoroid for Free from the Dynastic Repo](https://repo.dynastic.co/package/com.jeffresc.meteoroid), or download and install it manually using the .deb file, which can be downloaded from the [GitHub releases section](https://github.com/JeffResc/Meteoroid/releases).

# Advanced Usage
### Command Usage
By design, this package comes bundled with an advanced command line interface for setting the wallpaper from various sources. It can be invoked from the terminal by typing the following command:
```bash
meteoroidcli --help
```
### Command Options
This command line interface comes with several options as depicted below:
| Option | Description                        | Requires Argument?                        | Required?                                                |
|--------|------------------------------------|-------------------------------------------|----------------------------------------------------------|
| -s     | Set the image source               | Yes, the image source as an integer (1-4) | Yes                                                      |
| -l     | Set only the lock screen wallpaper | No                                        | No, but must use -h or -b instead, but not more than one |
| -h     | Set only the home screen wallpaper | No                                        | No, but must use -l or -b instead, but not more than one |
| -b     | Set both wallpapers                | No                                        | No, but must use -l or -h instead, but not more than one |
| -p     | Enable parallax                    | No                                        | No, off by default                                       |
### Command Examples
Set the wallpaper from the "NASA (Image of the Day)" source to both the lockscreen and homescreen
```bash
meteoroidcli -s 1 -b
```
Set the wallpaper from the "NASA (Earth Observatory)" source to homescreen with parallax enabled
```bash
meteoroidcli -s 2 -h -p
```

# Changelog
The changelog has been moved to the [releases tab](https://github.com/JeffResc/Meteoroid/releases).
