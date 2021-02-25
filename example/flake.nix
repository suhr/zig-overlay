{
  description = "A very basic flake";
  inputs = {
    zig.url = "github:arqv/zig-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, zig, flake-utils }:
    let systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    in flake-utils.lib.eachSystem systems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.zig-hello = pkgs.stdenv.mkDerivation {
          pname = "zig-hello";
          version = "1";
          src = ./.;
          nativeBuildInputs = [ zig.packages.${system}.master.latest ];
          buildPhase = ''
            zig build
          '';
          installPhase = ''
            zig build install --prefix=$out
          '';

          XDG_CACHE_HOME = "/tmp/zig-cache";
        };
        defaultPackage = packages.zig-hello;
        apps.zig-hello = flake-utils.lib.mkApp { drv = defaultPackage; };
        defaultApp = apps.zig-hello;
      });
}
