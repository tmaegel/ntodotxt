# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] - 2024-01-05

### Added

- Add metadata (fastlane) to get the app ready for deployment in the fdroid store

### Fixed

- Add version code to pubspec.yaml

## [0.4.0] - 2024-01-04

### Added

- App icon (made by @colebemis)
- Confirmation dialog for deleting todo or filter

### Changed

- Update drawer (mobile) style
- Disable 'Apply' button in dialogs if unnecessary (e.g. empty list)
- Bump flutter to 3.16.5
- Bump go_router to 13.0.1
- Bump url_launcher to 6.2.2

### Removed

- Remove google_fonts

## [0.3.0] - 2023-12-22

### Added

- Add functionality to save and manage filters
- Add database (sqflite) and controller to persist data (filter and settings)
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

[unreleased]: https://github.com/tmaegel/ntodotxt/compare/v0.4.1...HEAD
[0.4.1]: https://github.com/tmaegel/ntodotxt/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/tmaegel/ntodotxt/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/tmaegel/ntodotxt/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/tmaegel/ntodotxt/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/tmaegel/ntodotxt/releases/tag/v0.1.0
