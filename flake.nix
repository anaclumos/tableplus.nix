{
  description = "TablePlus - Database management GUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        sources = pkgs.callPackage ./_sources/generated.nix { };
      in
      {
        packages = {
          tableplus = pkgs.callPackage ./package.nix { inherit sources; };
          default = self.packages.${system}.tableplus;
        };

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nvfetcher ];
        };
      }
    );
}
