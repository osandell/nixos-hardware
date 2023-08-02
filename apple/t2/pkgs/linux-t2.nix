{ lib, buildLinux, fetchFromGitHub, fetchurl, ... } @ args:

let
  patchRepo = fetchFromGitHub {
    owner = "osandell";
    repo = "linux-t2-patches";
    rev = "2c64723a17de8f436dcf41acf6d59033ba407e3f";
    hash = "sha256-cP5qG4QUgPfc2uqu6xwfWmvQ67Hmk5lyEdaA5i6sA4A=";
  };

  version = "6.4.2";
  majorVersion = with lib; (elemAt (take 1 (splitVersion version)) 0);
in
buildLinux (args // {
  inherit version;

  pname = "linux-t2";
  # Snippet from nixpkgs
  modDirVersion = with lib; "${concatStringsSep "." (take 3 (splitVersion "${version}.0"))}";

  src = fetchurl {
    url = "mirror://kernel/linux/kernel/v${majorVersion}.x/linux-${version}.tar.xz";
    hash = "sha256-oyarIkF2xbF8c8nMrYXzLkm25Odkhh1XWVcnt+8QBiw=";
  };

  structuredExtraConfig = with lib.kernel; {
    APPLE_BCE = module;
    APPLE_GMUX = module;
    BRCMFMAC = module;
    BT_BCM = module;
    BT_HCIBCM4377 = module;
    BT_HCIUART_BCM = yes;
    BT_HCIUART = module;
    HID_APPLE_IBRIDGE = module;
    HID_APPLE = module;
    HID_APPLE_MAGIC_BACKLIGHT = module;
    HID_SENSOR_ALS = module;
    SND_PCM = module;
    STAGING = yes;
  };

  kernelPatches = lib.attrsets.mapAttrsToList (file: type: { name = file; patch = "${patchRepo}/${file}"; })
    (lib.attrsets.filterAttrs (file: type: type == "regular" && lib.strings.hasSuffix ".patch" file)
      (builtins.readDir patchRepo));
} // (args.argsOverride or { }))
