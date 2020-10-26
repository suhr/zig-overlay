self: super:

let
  zigWithParameters = parameters:
    let
      arch = let system = builtins.currentSystem;
      in if system == "x86_64-darwin" then
        "macos-x86_64"
      else
        builtins.concatStringsSep "-"
        (super.lib.reverseList (super.lib.splitString "-" system));
    in super.stdenvNoCC.mkDerivation {
      name = "zig";
      version = parameters.version;
      src = super.fetchurl {
        url =
          "https://ziglang.org/builds/zig-${arch}-${parameters.version}.tar.xz";
        sha256 = parameters.sha256;
      };
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out $out/bin $out/doc
        mv lib/ $out/
        mv zig $out/bin
        mv langref.html $out/doc
      '';
    };
in {
  lib = super.lib // {
    zig = rec {
      versionIndex = super.lib.importJSON
        (builtins.fetchurl "https://ziglang.org/download/index.json");
      getParameters = version: {
        version = versionIndex.${version}.version;
        sha256 = versionIndex.${version}.${builtins.currentSystem}.shasum;
      };
    };
  };

  zig = (super.lib.attrsets.mapAttrs
    (name: value: (zigWithParameters (self.lib.zig.getParameters name)))
    self.lib.zig.versionIndex) // {
      custom = zigWithParameters;
    };
}
