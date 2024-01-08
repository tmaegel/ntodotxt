FDROID_REPO = "${HOME}/Downloads/nosync/fdroiddata"

licenses:
	flutter pub run flutter_oss_licenses:generate.dart

icon:
	flutter pub run flutter_launcher_icons

screenshots:
	flutter drive --driver=test_driver/screenshot_integration_test.dart --target=integration_test/screenshot_integration_test.dart

run_fdroid:
	cd $(FDROID_REPO) && docker run --rm --name fdroid -v "/home/toni/.android-sdk/":/opt/android-sdk -v $(FDROID_REPO):/repo -e ANDROID_HOME:/opt/android-sdk registry.gitlab.com/fdroid/docker-executable-fdroidserver:master build -v -l de.tnmgl.ntodotxt
