/**
  Disk layout for Helios, HP ProDesk 400 G4 DM devbox.

  - NVMe (256 GB): ESP and the system (root, Nix store, swap).
  - SATA (2 TB): home directories and container storage.

  Both disks are LUKS-encrypted and unlocked in the systemd initrd, by the TPM
  once it is enrolled, otherwise with the passphrase set at format time
  (read from /tmp/disk.key). Enroll the TPM after Secure Boot (lanzaboote)
  is enabled, since that changes PCR 7:

    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-system-luks
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/disk/by-partlabel/disk-data-luks
*/
{ inputs, ... }:
{
  flake.nixosModules.heliosDisko =
    { ... }:
    let
      btrfsOpts = [
        "compress=zstd"
        "noatime"
      ];

      # The passphrase for both volumes, read only when formatting. Copy it
      # there with nixos-anywhere's --disk-encryption-keys.
      luksPasswordFile = "/tmp/disk.key";

      # Settings shared by both LUKS volumes; they end up in
      # boot.initrd.luks.devices.
      luksSettings = {
        allowDiscards = true;
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    in
    {
      imports = [
        inputs.disko.nixosModules.disko
      ];

      disko.devices.disk = {
        system = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-SK_hynix_BC501_HFM256GDJTNG-8310A_FS87N478812507D51";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
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
                  name = "cryptsystem";
                  passwordFile = luksPasswordFile;
                  settings = luksSettings;
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/root" = {
                        mountpoint = "/";
                        mountOptions = btrfsOpts;
                      };
                      "/nix" = {
                        mountpoint = "/nix";
                        mountOptions = btrfsOpts;
                      };
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        swap.swapfile.size = "16G";
                      };
                    };
                  };
                };
              };
            };
          };
        };

        data = {
          type = "disk";
          device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S754NS0WB17503D";
          content = {
            type = "gpt";
            partitions = {
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "cryptdata";
                  passwordFile = luksPasswordFile;
                  settings = luksSettings;
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/home" = {
                        mountpoint = "/home";
                        mountOptions = btrfsOpts;
                      };
                      "/docker" = {
                        mountpoint = "/var/lib/docker";
                        mountOptions = btrfsOpts;
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
