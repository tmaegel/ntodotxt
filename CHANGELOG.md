# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.1] - 2024-03-05

### Added

- Hide keyboard if tap outside of textfield

### Changed

- Bump file_picker to 6.2.0
- Bump flutter_bloc to 8.1.4
- Bump go_router to 13.2.0
- Bump sqflite_common_ffi to 2.3.2+1
- Bump sqlite3_flutter_libs to 0.5.20
- Bump url_launcher to 6.2.5
- Update style of drawer
- Update style of loading spinner

### Fixed

- Filter todo list on search page correctly
- Order todos for the different filters/groupings correctly
- Keep scroll position of todo list if todo was created or edited
- Solve error while initialization on desktop

## [0.6.0] - 2024-02-28

### Added

- Add new widget tests and refactor existing ones

### Changed

- Disable landscape mode
- Add a confirmation dialog when the app settings are reset
- Improve the appearance of the todo list page
- Make app bar transparent
- Hide floating action button if keyboard is open
- Hide floating action button (save) if todo or filter has not be changed
- Hide floating action button (save) if name todo or filter is empty

### Removed

- Remove the functionality to set the todo completion state by swiping

### Fixed

- Improved error handling on login screen
- Improved text field behavior when creating or editing todos #27
- Prevention of + and @ characters at the beginning of the tag when displayed in the tag dialog

## [0.5.1] - 2024-02-21

### Added

- Hide primary floating action button when scrolling down and show 'go to top' button instead

### Changed

- Remove bottom bar
- Transparent bottom system navigation bar and edge to edge view
- Small style adjustments of the snackbar and loading indicator
- Replace app launcher icon

### Fixed

- Dismiss dialogs on back button
- Resolve some build warnings
- Resolve some minor theme issues

## [0.5.0] - 2024-02-16

### Added

- Add possibility to customize the local path of the todo.txt file #7
- Tests the connection to the webdav before login

### Changed

- Improve the appearance of the login screen

### Fixed

- Activate the previous item in the drawer when navigating back
- Ignore empty lines in todo.txt file

## [0.4.7] - 2024-02-06

### Fixed

- Add missing permission android.permission.INTERNET #20

## [0.4.6] - 2024-02-04

### Fixed

- Pin tag/version of flutter submodule to v3.16.9

## [0.4.5] - 2024-02-03

### Changed

- Bump flutter version to 3.16.9
- Update some dialogs

### Fixed

- Server port for the webdav connection is optional #12 #17
- Sometimes the hamburger menu gets lost #18
- dense attribute is not neccessary for material3 themes

## [0.4.4] - 2024-01-16

### Changed

- Move drawer to appbar (mobile only)
- Redesign todo and filter detail page/view

### Fixed

- Disable allowBackup in AndroidManifest.xml
- Some dialogs are scrollable if the keyboad appears
- Fix regex for hostname validation #8

## [0.4.3] - 2024-01-08

### Changed

- Sign apks

### Fixed

- Add missing `flutter_launcher_icons` dependency

## [0.4.2] - 2024-01-05

### Added

- Add `flutter` as git submodule

## [0.4.1] - 2024-01-05

### Added

- Add metadata (`fastlane`) to get the app ready for deployment in the fdroid store

### Fixed

- Add version code to `pubspec.yaml`

## [0.4.0] - 2024-01-04

### Added

- App icon (made by @colebemis)
- Confirmation dialog for deleting todo or filter

### Changed

- Update drawer (mobile) style
- Disable 'Apply' button in dialogs if unnecessary (e.g. empty list)
- Bump `flutter` to 3.16.5
- Bump `go_router` to 13.0.1
- Bump `url_launcher` to 6.2.2

### Removed

- Remove `google_fonts`

## [0.3.0] - 2023-12-22

### Added

- Add functionality to save and manage filters
- Add database (`sqflite`) and controller to persist data (filter and settings)
- Add simple loading / splash screen while initialize the app

### Changed

- Save default filter settings in sqlite database instead of shared preferences
- Theme and UI improvements and some redesign (app bar, dialogs, ...)
- Replace navigation drawer with bottom sheet (for mobile) and navigation rail (desktop)

### Removed

- Remove dependencie shared_preferences
- Remove todo selection functionality

### Fixed

- Add error state to FilterState and handle/show errors

## [0.2.0] - 2023-12-11

### Added

- Add swipe (left/right) action to toggle the completion of todo

### Changed

- Minor style adjustments to the theme and layout

### Fixed

- Hide tags (projects, contexts, key values) in tag dialog if already present in todo
- Toggle filter/order/group by if tapping on the label
- Notification bars are floating

## [0.1.0] - 2023-12-08

### Added

- Intiial release

[unreleased]: https://github.com/tmaegel/ntodotxt/compare/v0.6.1...HEAD
[0.6.1]: https://github.com/tmaegel/ntodotxt/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/tmaegel/ntodotxt/compare/v0.5.1...v0.6.0
[0.5.1]: https://github.com/tmaegel/ntodotxt/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/tmaegel/ntodotxt/compare/v0.4.7...v0.5.0
[0.4.7]: https://github.com/tmaegel/ntodotxt/compare/v0.4.6...v0.4.7
[0.4.6]: https://github.com/tmaegel/ntodotxt/compare/v0.4.5...v0.4.6
[0.4.5]: https://github.com/tmaegel/ntodotxt/compare/v0.4.4...v0.4.5
[0.4.4]: https://github.com/tmaegel/ntodotxt/compare/v0.4.3...v0.4.4
[0.4.3]: https://github.com/tmaegel/ntodotxt/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/tmaegel/ntodotxt/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/tmaegel/ntodotxt/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/tmaegel/ntodotxt/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/tmaegel/ntodotxt/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/tmaegel/ntodotxt/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tmaegel/ntodotxt/releases/tag/v0.1.0
