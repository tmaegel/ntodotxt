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
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          flutter341
          jdk21
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
      };

    };
}
