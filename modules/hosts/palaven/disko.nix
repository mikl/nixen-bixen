{ inputs, ... }:
{

  flake.nixosModules.palavenDisko =
    { pkgs, lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
      ];

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/disk/by-id/ata-LITEONIT_LCS-128M6S_002321116129";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "2G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypted";
                    settings = {
                      allowDiscards = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/home" = {
                          mountpoint = "/home";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/swap" = {
                          mountpoint = "/.swapvol";
                          swap.swapfile.size = "2G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

}
