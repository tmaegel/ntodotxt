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
          bashInteractive
          cmake
          flutter341
          gtk3
          jdk21
          libsecret
          nil
          ninja
          nixd
          pre-commit
          shellcheck
          shfmt
          sqlite
        ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
          pkgs.sqlite
          pkgs.libsecret
        ];
      };

    };
}
