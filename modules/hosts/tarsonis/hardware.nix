{ self, inputs, ... }:
{
  flake.nixosModules.tarsonisHardware =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "uas"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/mapper/luks-c19c96c8-900f-48e7-a6d3-e8f4c4bd3031";
        fsType = "ext4";
      };

      boot.initrd.luks.devices."luks-c19c96c8-900f-48e7-a6d3-e8f4c4bd3031".device =
        "/dev/disk/by-uuid/c19c96c8-900f-48e7-a6d3-e8f4c4bd3031";

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/A351-BE20";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [
        { device = "/dev/mapper/luks-e0cefc69-fbde-4c4f-bf27-89b5b7a49dfe"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
