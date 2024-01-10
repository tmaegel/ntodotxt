# ntodotxt

[![CI](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml/badge.svg)](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml)
[![Release](https://img.shields.io/github/v/release/tmaegel/ntodotxt)](https://github.com/tmaegel/ntodotxt/releases)
[![F-Droid](https://img.shields.io/f-droid/v/de.tnmgl.ntodotxt.svg?logo=F-Droid)
[![License](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/_Flutter_-3.16.5-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue)](https://github.com/flutter/flutter)

**This app is still under active development and not released, yet.**

With `ntodotxt` you can manage your todos in the [todo.txt](https://github.com/todotxt/todo.txt) format (i.e. all information
is stored in a single file). You can save your todos locally on your device and/or synchronize the todo.txt file via webdav - for
example with a self-hosted nextcloud instance.

Moreover, this app is completely open source.

[![Get it on F-Droid][https://fdroid.gitlab.io/artwork/badge/get-it-on.png]][https://f-droid.org/packages/de.tnmgl.ntodotxt]

## Screenshots

<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/phone/1.png"><img src="screenshots/preview/1.png" width="150px"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/phone/2.png"><img src="screenshots/preview/2.png" width="150px"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/phone/3.png"><img src="screenshots/preview/3.png" width="150px"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/phone/4.png"><img src="screenshots/preview/4.png" width="150px"/></a>
<a href="https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/screenshots/phone/5.png"><img src="screenshots/preview/5.png" width="150px"/></a>

## Features

tbd

## Planned features

- [ ] Build and publish to F-Droid (Android)
- [ ] Build and publish to Google Play (Android)
- [ ] Build and publish as `flatpak` to [flathub](https://flathub.org/) (Linux)
- [ ] Build and publish as `snap` to [snapcraft](https://snapcraft.io/) (Linux)
- [ ] Build and publish to Microsoft Store (Windows)
- [x] Manage saved filters (ordering, filter by project, context and priorities)
- [ ] [Recurring](https://c306.net/t/topydo-docs/#Recurrence) tasks
- [ ] Add language localization
- [ ] Archiving of all completed todos (done.txt)
- [ ] Animations

## Build

[Flutter SDK](https://docs.flutter.dev/get-started/install) is required to build this project.

```bash
flutter pub get
flutter run  # debug version
flutter build  # release version
```

## Requirements

- [Nextcloud](https://nextcloud.com/) instance or other webdav server running (**webdav-sync only**)
