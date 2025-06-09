{
  description = "Rust development environment using Nix Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Use stable release
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, nixvim, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        config = import ./config;
        overlays = [ rust-overlay.overlays.default ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default;

        nixvimlib = nixvim.lib.${system};
        vv = nixvim.legacyPackages.x86_64-linux.makeNixvimWithModule {
          inherit pkgs;
          module = config;
        };
      in {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "shell-rs";
          version = "0.1.0";

          src = ./.;

          cargoLock = { lockFile = ./Cargo.lock; };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            rustToolchain
            vv
            pkgs.rust-analyzer
            pkgs.clippy
            pkgs.rustfmt
            pkgs.pkg-config
          ];

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

          shellHook = ''
            echo "Welcome to your Rust development environment!"
          '';
        };
      });
}

