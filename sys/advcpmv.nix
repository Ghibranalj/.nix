{ config, lib, pkgs, prevpkgs, pkgs-24-11, ... }:
let
  advcpmv_pkg =
    (pkgs-24-11.coreutils.override { singleBinary = false; }).overrideAttrs (old:
      let
        advcpmv-data = {
          pname = "advcpmv";
          patch-version = "0.9";
          coreutils-version = "9.5";
          version =
            "${advcpmv-data.patch-version}-${advcpmv-data.coreutils-version}";
          src = pkgs.fetchFromGitHub {
            owner = "jarun";
            repo = "advcpmv";
            rev = "1635eb96e5dbf0dde06830db8aee0c840705d7ed";
            hash = "sha256-9YlGiYQZXnvA5SxMLDSFga7xJk7vc9Vy9WRrcK8NBS8=";
          };
          patch-file = advcpmv-data.src
            + "/advcpmv-${advcpmv-data.version}.patch";
        };
      in assert (advcpmv-data.coreutils-version == old.version); {
        inherit (advcpmv-data) pname version;

        patches = (old.patches or [ ]) ++ [ advcpmv-data.patch-file ];

        configureFlags = (old.configureFlags or [ ])
          ++ [ "--program-prefix=adv" ];

        postInstall = (old.postInstall or [ ]) + ''
          pushd $out/bin
          ln -s advcp cpg
          ln -s advmv mvg
          popd
        '';
        meta = old.meta // {
          description = "Coreutils patched to add progress bars";
        };
      });
in {
  options = with lib; {
    advcpmv.enable = mkEnableOption "enables advcpmv";
    advcpmv.package = mkOption {
      type = types.package;
      default = advcpmv_pkg;
      description = "The advcpmv package to use.";
    };
  };

  config = lib.mkIf config.advcpmv.enable {
    environment.systemPackages = [ config.advcpmv.package ];
  };
}
