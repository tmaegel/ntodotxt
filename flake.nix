{
  description = "Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Define the architecture

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [
          "34"
          "35"
          "36"
        ];
        buildToolsVersions = [
          "34.0.0"
          "35.0.0"
          "36.0.0"
        ];
        ndkVersions = [ "28.2.13676358" ];
        cmakeVersions = [ "3.22.1" ];
        abiVersions = [ "x86_64" ];
        systemImageTypes = [ "google_apis" ];

        includeEmulator = true;
        includeSystemImages = true;
        includeNDK = true;
      };

      androidSdk = androidComposition.androidsdk;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          android-tools
          androidSdk
          flutter341
          jdk21
          pre-commit
        ];

        nativeBuildInputs = with pkgs; [
          clang
          cmake
          gcc
          ninja
          pkg-config
        ];

        buildInputs = with pkgs; [
          gtk3
          libsecret
          sqlite
        ];

        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        ANDROID_NDK_ROOT = "${androidSdk}/libexec/android-sdk/ndk-bundle";
        JAVA_HOME = "${pkgs.jdk21}";

        shellHook = ''
          export PATH="$ANDROID_HOME/platform-tools:$PATH"
          export PATH="$ANDROID_HOME/emulator:$PATH"
        '';
      };

    };
}
