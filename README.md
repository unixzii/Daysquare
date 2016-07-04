# Daysquare

An elegant calendar control for iOS.

[![Version](https://img.shields.io/cocoapods/v/Daysquare.svg?style=flat)](http://cocoapods.org/pods/Daysquare)
[![License](https://img.shields.io/cocoapods/l/Daysquare.svg?style=flat)](http://cocoapods.org/pods/Daysquare)
[![Platform](https://img.shields.io/cocoapods/p/Daysquare.svg?style=flat)](http://cocoapods.org/pods/Daysquare)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Introduction

Get bored with native silly **UIDatePicker**? You may have a try on this control. Instead of showing you an awkward wheel, it just presents as a intuitive full-size calendar with a lot of preference properties that you can change.

## Screencast
### Overview
![](https://github.com/unixzii/Daysquare/raw/master/Images/overview.gif)

### Set the date
![](https://github.com/unixzii/Daysquare/raw/master/Images/setting.gif)

### Bold current month
![](https://github.com/unixzii/Daysquare/raw/master/Images/bold.gif)

## Features
* Highly customizable.
* Navigating between arbitrary dates.
* Automatically adjust view to fit variety sizes.

**[Changelog - 6.14]**
* Add: user's calendar events displaying supports.

![](https://github.com/unixzii/Daysquare/raw/master/Images/event.gif)

**[Changelog - 6.15]**
* Add: single row mode supports, see `singleRowMode` property.

![](https://github.com/unixzii/Daysquare/raw/master/Images/singlerow.gif)

## Example
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation
Daysquare is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Daysquare', :git => 'https://github.com/unixzii/Daysquare.git'
```

Also, if you prefer to use Carthage, you can add the following line to your Cartfile:

```bash
github "unixzii/Daysquare"
```

## Guide
Try the demo project, it's very easy to use. Daysquare follows the **target-action** pattern, just like the native `UIDatePicker` class.

> **PAY ATTENTION**
> <br>
> After changing any appearance property, you have the responsibility to call `reloadViewAnimated:` method to update the view.

Enjoy it!!

## License
The project is available under the MIT license. See the LICENSE file for more info.
