{
  description = "ziglings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig-overlay";
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay, zls }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zig-overlay.packages.${system}.master;
      in
      {
        # `nix develop`
        devShells.default = pkgs.mkShell {
          buildInputs = [
            zig
            zls.packages.${system}.default
          ];
          shellHook = ''
            export SDKROOT=$(xcrun --sdk macosx --show-sdk-path 2>/dev/null || echo "")
          '';
        };
      }
    );
}
