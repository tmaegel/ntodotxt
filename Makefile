.PHONY: screenshots

APP_ID = "de.tnmgl.ntodotxt"
FDROID_REPO = "${HOME}/Downloads/nosync/fdroiddata"

sonarqube:
	docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 127.0.0.1:9000:9000 sonarqube:10.4-community

scan:
	docker run \
    --rm --name sonar-scanner-cli \
    -e SONAR_HOST_URL="http://sonarqube:9000" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=ntodotxt" \
    -e SONAR_TOKEN="token" \
    -v "$(shell pwd):/usr/src" \
		--link sonarqube \
    sonarsource/sonar-scanner-cli

licenses:
	flutter pub run flutter_oss_licenses:generate.dart

icon:
	flutter pub run flutter_launcher_icons

integration_env_start:
	docker run -d --rm --name=nextcloud_local \
		-p 127.0.0.1:8000:80 \
		-e NEXTCLOUD_TRUSTED_DOMAINS="127.0.0.1" \
		-v nextcloud:/var/www/html nextcloud:27.1

integration_env_configure:
	docker exec -it -u www-data nextcloud_local php occ config:system:set trusted_domains 2 --value=10.0.2.2

integration_env_stop:
	docker stop nextcloud_local

screenshots:
	flutter emulators --launch "Pixel_7_API_34_extension_level_7_x86_64" && sleep 10
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
