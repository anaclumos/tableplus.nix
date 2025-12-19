# tableplus.nix

Nix flake that packages **TablePlus** (Database management GUI) for `x86_64-linux` by repackaging the official `.deb`.

## Usage

Build:

```sh
nix build .#tableplus
./result/bin/tableplus
```

Run without building a `result/` symlink:

```sh
nix run .#tableplus
```

Install to your profile:

```sh
nix profile install .#tableplus
```

## Declarative installation

### NixOS (flakes)

Add this flake as an input to your system flake and reference its package:

```nix
# flake.nix (excerpt)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tableplus.url = "github:<you>/tableplus.nix"; # or "path:/path/to/tableplus.nix"
  };

  outputs = { self, nixpkgs, tableplus, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ({ ... }: {
            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = [
              tableplus.packages.${system}.default
            ];
          })
        ];
      };
    };
}
```

### NixOS (`configuration.nix`, non-flake)

Import `package.nix` from a pinned tarball/checkout:

```nix
{ pkgs, ... }:
let
  tableplusSrc = builtins.fetchTarball {
    url = "https://github.com/<you>/tableplus.nix/archive/<rev>.tar.gz";
    sha256 = "<sha256>";
  };
  sources = pkgs.callPackage "${tableplusSrc}/_sources/generated.nix" { };
  tableplus = pkgs.callPackage "${tableplusSrc}/package.nix" { inherit sources; };
in
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [ tableplus ];
}
```

### Home Manager

Add the package to `home.packages` (flake-based example; pass `inputs` via `extraSpecialArgs`):

```nix
{ pkgs, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = [
    inputs.tableplus.packages.${pkgs.system}.default
  ];
}
```

## Unfree package (required)

TablePlus is proprietary software (`meta.license = unfree`), so Nix needs unfree packages enabled.

Temporarily (common with flakes):

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run --impure .#tableplus
```

Or enable unfree packages in your Nix/NixOS configuration (for example `nixpkgs.config.allowUnfree = true;`).

## Updating the pinned `.deb`

This repo uses `nvfetcher` to track the TablePlus Debian repository and generate `_sources/generated.nix`.

```sh
nix develop
nvfetcher -c nvfetcher.toml -o _sources
```

Then rebuild with `nix build .#tableplus`.

## Notes

- Supported platform: `x86_64-linux` only (see `flake.nix`).
- Not affiliated with TablePlus.
