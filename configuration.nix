{ config, pkgs, lib, ... }:  # Make sure lib is included here

{
  imports = [
    <nixos-hardware/asus/zephyrus/ga402x/amdgpu>
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ 
    "amd_pstate=passive" 
    "cpufreq.default_governor=powersave"
    "pcie_aspm.policy=powersupersave"
  ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    kate
    auto-cpufreq
    vim
    htop
    btop
    nmap
    gimp
    obsidian
    google-chrome
    vscodium
    flatpak
    vulkan-tools
    mesa
    steam
    xrdp
    remmina
    blueman
    discord
    ticktick
    git
    powertop
    xboxdrv
    linuxConsoleTools
    evtest
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.bluetooth.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  services.flatpak.enable = true;
  nixpkgs.config.allowUnfree = true;

  users.users.johnny = {
    isNormalUser = true;
    description = "Jonathan Joyce";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ kate ];
  };

  system.stateVersion = "24.05";

  # ASUS-specific services
  services.supergfxd.enable = true;
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # ASUS-specific udev rule
  services.udev.extraHwdb = ''
    evdev:name::dmi:bvn:bvr:bd:svnASUS:pn:*
     KEYBOARD_KEY_ff31007c=f20
  '';

  # Power management configuration
  services.power-profiles-daemon.enable = true;
  powerManagement.enable = true;

  # Optional: Enable thermald for better thermal management
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  # New sections for Xbox controller support
  services.udev.extraRules = ''
    # Xbox 360 wired controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
    # Xbox 360 wireless controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0666"
    # Xbox One controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
    # Xbox One S controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666"
    # Xbox Series X|S controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666"
  '';

  # Enable Steam hardware support
  hardware.steam-hardware.enable = true;

  # Optional: Enable xboxdrv service (commented out by default)
  # services.xboxdrv.enable = true;
}
