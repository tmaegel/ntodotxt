.PHONY: screenshots

APP_ID = "de.tnmgl.ntodotxt"
FDROID_REPO = "${HOME}/Downloads/nosync/fdroiddata"

licenses:
	flutter pub run flutter_oss_licenses:generate.dart

icon:
	flutter pub run flutter_launcher_icons

emulator_run:
	flutter emulators --launch "Pixel_7_API_34_extension_level_7_x86_64"

emulator_stop:
	adb emu kill

screenshots:
	flutter emulators --launch "Pixel_4_API_34_extension_level_7_x86_64" && sleep 10
	flutter drive \
		--driver=test_driver/screenshot_integration_test.dart \
		--target=integration_test/screenshot_integration_test.dart || true
	adb emu kill

preview_screenshots:
	flutter emulators --launch "Pixel_7_API_34_extension_level_7_x86_64" && sleep 10
	flutter drive \
		--driver=test_driver/screenshot_integration_test.dart \
		--target=integration_test/preview_app_integration_test.dart || true
	adb emu kill

fdroid_lint:
	cd $(FDROID_REPO) && docker run \
		--rm \
		--name fdroid \
		-v "${HOME}/.android-sdk/":/opt/android-sdk \
		-v $(FDROID_REPO):/repo \
		-e ANDROID_HOME:/opt/android-sdk \
		registry.gitlab.com/fdroid/docker-executable-fdroidserver:master lint -v $(APP_ID)

fdroid_signature:
	apksigner verify --print-certs app.apk | grep SHA-256
	cd $(FDROID_REPO) && docker run \
		--rm \
		--name fdroid \
		-v "${HOME}/.android-sdk/":/opt/android-sdk \
		-v $(FDROID_REPO):/repo \
		-e ANDROID_HOME:/opt/android-sdk \
		registry.gitlab.com/fdroid/docker-executable-fdroidserver:master signatures unsigned/app.apk

fdroid_build:
	docker build -t fdroidserver -f Dockerfile_fdroid .

fdroid_run:
	cd $(FDROID_REPO) && docker run \
		--rm \
		--name fdroid \
		-v "${HOME}/.android-sdk/":/opt/android-sdk \
		-v $(FDROID_REPO):/repo \
		-e ANDROID_HOME:/opt/android-sdk \
		fdroidserver build -v -l $(APP_ID)

setup_avd:
	flutter config --android-sdk ${HOME}/.android-sdk/
	sdkmanager --sdk_root=${HOME}/.android-sdk/ --install "cmdline-tools;latest"
	sdkmanager --sdk_root=${HOME}/.android-sdk/ --install "platform-tools"
	sdkmanager --sdk_root=${HOME}/.android-sdk/ --install "tools"
	sdkmanager --sdk_root=${HOME}/.android-sdk/ --install "platforms;android-33"
	sdkmanager --sdk_root=${HOME}/.android-sdk/ --install "build-tools;33.0.2"
