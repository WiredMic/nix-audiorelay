{
  description = "Audiorelay on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        self,
        ...
      }:
      {
        imports = [
          # Optional: use external flake logic, e.g.
          # inputs.foo.flakeModules.default
        ];
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            self',
            system,
            lib,
            pkgs,
            ...
          }:
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              config.allowUnfreePredicate =
                pkg:
                builtins.elem (lib.getName pkg) [
                  "audiorelay"
                ];
            };

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                # self'.packages.audiorelay
              ];
              NIXPKGS_ALLOW_UNFREE = "1";
            };
            packages = rec {
              audiorelay = pkgs.callPackage ./audiorelay.nix { };
              default = audiorelay;
            };
          };
      }
    );
}
