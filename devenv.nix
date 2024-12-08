{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
in
{

  env.USE_CCACHE = 1;
  env.JAVA_HOME = lib.mkForce pkgs-unstable.jdk17.home;
  env.ANDROID_JAVA_HOME = pkgs-unstable.jdk17.home;

  enterShell = ''
    export PUB_CACHE="$HOME/.pub-cache"
    export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/34.0.0/aapt2"
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs-unstable.sqlite ]}:$LD_LIBRARY_PATH"
  '';

  packages = [
    pkgs-unstable.clang
    pkgs-unstable.gtk3
    pkgs-unstable.jdk17
    pkgs-unstable.libsecret
    pkgs-unstable.ninja
    pkgs-unstable.pkg-config
    pkgs-unstable.pre-commit
    pkgs-unstable.sqlite
  ];

  android = {
    enable = true;
    platforms.version = [
      "32"
      "33"
      "34"
    ];
    abis = [
      "arm64-v8a"
      "x86_64"
    ];
    emulator = {
      enable = true;
      version = "34.1.9";
    };
    flutter = {
      enable = true;
      package = pkgs-unstable.flutter319;
    };
    android-studio = {
      enable = true;
      package = pkgs.android-studio;
    };
    tools.version = "26.1.1";
    cmdLineTools.version = "11.0";
    platformTools.version = "34.0.5";
    buildTools.version = [
      "30.0.3"
      "34.0.0"
    ];
    cmake.version = [ "3.22.1" ];
    sources.enable = false;
    systemImages.enable = true;
    systemImageTypes = [ "google_apis_playstore" ];
    ndk.enable = true;
    googleAPIs.enable = true;
    googleTVAddOns.enable = false;
    extras = [ "extras;google;gcm" ];
    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };
}
