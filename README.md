# ntodotxt

[![CI](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml/badge.svg)](https://github.com/tmaegel/ntodotxt/actions/workflows/ci.yaml)
[![Release](https://img.shields.io/github/v/release/tmaegel/ntodotxt)](https://github.com/tmaegel/ntodotxt/releases)
[![License](https://img.shields.io/badge/License-MIT-yellow)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/_Flutter_-3.16.5-grey.svg?&logo=Flutter&logoColor=white&labelColor=blue)](https://github.com/flutter/flutter)

**This app is still under active development and not released, yet.**

With `ntodotxt` you can manage your todos in the [todo.txt](https://github.com/todotxt/todo.txt) format (i.e. all information
is stored in a single file). You can save your todos locally on your device and/or synchronize the todo.txt file via webdav - for
example with a self-hosted nextcloud instance.

Moreover, this app is completely open source.

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
- [ ] Increase test coverage

## Build

[Flutter SDK](https://docs.flutter.dev/get-started/install) is required to build this project.

```bash
flutter pub get
flutter run  # debug version
flutter build  # release version
```

## Requirements

- [Nextcloud](https://nextcloud.com/) instance or other webdav server running (**webdav-sync only**)
