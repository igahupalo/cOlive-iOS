<img alt="header" src="https://user-images.githubusercontent.com/56322245/197550597-902d188c-3969-4322-975b-4434bd8f6345.png">

# cOlive

cOlive is an iOS application designed for roommates. It aims to simplify various aspects of flatsharing. The app lets users to create groups. Group members gain access to features such as a virtual board with notices or shared calendar allowing keeping flatmates up to date with upcoming events.

The application was created with usage of UIKit and Firebase Realtime Database. 

## Requirements

- iOS 13.0+

## Features

- [x] User authentication
- [x] Creating a new group and sending out invitations or joining an existing one with usage of an invitation code
- [x] Menaging group settings and members
- [x] Menaging profile settings
- [x] Browsing group's virtual board, creating new notices or adding comments to exisitng ones
- [x] Accessing group's shared calendar and menaging presented events

## UI examples

### App start, sign up and log in

https://user-images.githubusercontent.com/56322245/196964205-04d89a0c-6e5f-4d5c-a799-071d12e30813.mp4

### Profile settings, switching flat and sharing invitation code

https://user-images.githubusercontent.com/56322245/196964662-d186e0cd-441e-4b75-baec-c1a1d3be4a56.mp4

### Checking in with new invitation code

https://user-images.githubusercontent.com/56322245/196964791-f9dde82c-608c-4cb2-91ec-8fa657909461.mp4

### Virtual board

https://user-images.githubusercontent.com/56322245/196964897-10c86bd6-c364-4c2c-92e6-66239a392308.mp4

### Shared calendar

https://user-images.githubusercontent.com/56322245/196964973-db1af4a1-76fd-477f-ab1a-98c3512f739e.mp4

## Running the App

1. Clone this repository.
1. Open shell window and navigate to project folder.
1. Run `pod install`.
1. Open `Furdresser.xcworkspace` and run the project on selected device or simulator.

## Sample account

- email: ritigat213@corylan.com
- password: 123456

## Used third-party libraries
- Firebase - https://cocoapods.org/pods/Firebase
- JVFloatLabeledTextField - https://cocoapods.org/pods/JVFloatLabeledTextField
- IQKeyboardManagerSwift - https://cocoapods.org/pods/IQKeyboardManagerSwift
- FSCalendar - https://cocoapods.org/pods/FSCalendar
- KKPinCodeTextField - https://github.com/kolesa-team/ios_pinCodeTextField
- PhoneNumberKit - https://cocoapods.org/pods/PhoneNumberKit

## TODOs
- [ ] Refactor data layer and models
- [ ] Fix dates in calendar events preview
- [ ] Show number of comments in post preview
- [ ] Fix navigation bar appearence for smaller screen resolutions (ex. iPhone 8)
- [ ] Fix labels of buttons in profile settings (phone number, birthday)

## Credits

UI/UX design created by Alicja Łuszpińska - https://dribbble.com/aluszpinska.

App logo created by Kinga Gniedziejko - https://github.com/kingaGniedziejko.
