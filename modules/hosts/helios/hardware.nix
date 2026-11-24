{ ... }:
{
  flake.nixosModules.heliosHardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      # The HP WMI drivers only fail on this machine: the firmware rejects
      # their fan and BIOS-settings queries at every boot. A headless box has
      # no use for HP hotkeys or changing BIOS settings from Linux anyway.
      boot.blacklistedKernelModules = [
        "hp_wmi"
        "hp_bioscfg"
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
