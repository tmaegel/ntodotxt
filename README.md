# ntodotxt

[![CI](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml/badge.svg)](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml)
[![Release](https://img.shields.io/github/v/release/tmaegel/ntodotxt)](https://github.com/tmaegel/ntodotxt/releases)
[![F-Droid](https://img.shields.io/f-droid/v/de.tnmgl.ntodotxt.svg?logo=F-Droid)](https://f-droid.org/packages/de.tnmgl.ntodotxt)
[![License](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/_Flutter_-3.24.5-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue)](https://github.com/flutter/flutter)

With `ntodotxt` you can manage your todos in a [todo.txt](https://github.com/todotxt/todo.txt) file (i.e. all information
is stored in a single file). You can save your todos locally on your device and/or synchronize the todo.txt file via webdav - for
example with a self-hosted nextcloud instance.

This application is under active development and will continue to be modified and improved over time.

## Screenshots

<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/preview/1.png"><img src="screenshots/preview/1.png" width="19.2%"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/preview/2.png"><img src="screenshots/preview/2.png" width="19.2%"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/preview/3.png"><img src="screenshots/preview/3.png" width="19.2%"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/preview/4.png"><img src="screenshots/preview/4.png" width="19.2%"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/preview/5.png"><img src="screenshots/preview/5.png" width="19.2%"/></a>

## Downloads

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid" height="80">](https://f-droid.org/packages/de.tnmgl.ntodotxt/)

## Features

### v1.0

- [x] Manage todos in [todo.txt](https://github.com/todotxt/todo.txt) format
- [x] Manage todos locally and/or synchronize todos via webdav with a server of your choice
- [x] Custom path and filename of todo files (local and remote)
- [x] Search todos
- [x] Create custom views of todos via filters
- [ ] Sort (ascending/descending) todos by criteria such as priority, creation date or due date
- [ ] Android widget
- [ ] Import/Export existing todos from/to file
- [ ] Import/Export filters and other settings
- [ ] Language localization (e.g. english, german)
- [ ] [Recurring](https://c306.net/t/topydo-docs/#Recurrence) tasks
- [ ] Archiving of completed todos (done.txt)
- [ ] ...

### Low priority

- [ ] Build and publish to Google Play (Android)
- [ ] Build and publish as `flatpak` to [flathub](https://flathub.org/) (Linux)
- [ ] Build and publish as `snap` to [snapcraft](https://snapcraft.io/) (Linux)
- [ ] Build and publish to Microsoft Store (Windows)

## Build

### General

[Flutter SDK](https://docs.flutter.dev/get-started/install) is required to build this project.

### Building on Linux

1. First you need to get the source code of `ntodotxt`.

```bash
git clone https://github.com/tmaegel/ntodotxt
```

2. Installing the dependencies for [sqflite](https://pub.dev/packages/sqflite_common_ffi#linux) and [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage#configure-linux-version).

```bash
dnf install sqlite-devel libsecret-devel1
```

3. Open project via [Android Studio](https://developer.android.com/studio).

4. Click the `Run` button and it will be built and run automatically.

5. Or you can build and run from command line.

```bash
flutter pub get
flutter run
# or
flutter build
```

If an error occurs during the build process, please follow these [steps](https://docs.flutter.dev/get-started/install/linux/desktop#development-tools).

## Sponsorship

`ntodotxt` is a free open source software that benefits from the open source community and every user can enjoy it's full functionality for free, so if you appreciate my current work, you can buy me a offee.

<a href='https://ko-fi.com/N4N41GAU03' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi5.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

Thanks for all the love and support.

## Alternatives

There are a bunch of other note taking apps with the WebDAV support. See them in [awesome-webdav](https://github.com/WebDAVDevs/awesome-webdav/blob/main/readme.md#android-other-apps) repository.
