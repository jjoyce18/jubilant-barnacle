{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    "${fetchTarball {
      url = "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";
    }}/asus/zephyrus/ga402x/amdgpu"
  ];

  # Enable flakes and nix-command
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = lib.mkForce [
      "amd_pstate=passive"
      "cpufreq.default_governor=powersave"
      "pcie_aspm.policy=powersupersave"
    ];
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Localization
  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim htop btop nmap git powertop lm_sensors fastfetch
    kitty obsidian google-chrome vscodium
    flatpak vulkan-tools mesa steam xrdp remmina
    xboxdrv linuxConsoleTools evtest
    discord ticktick vlc 
    gnome.gnome-tweaks
  ];

  # Environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Hardware configuration
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    pulseaudio.enable = false;
    steam-hardware.enable = true;
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  # Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  # System services
  services = {
    flatpak.enable = true;
    printing.enable = true;
    fstrim.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    # ASUS-specific services
    supergfxd.enable = true;
    asusd = {
      enable = true;
      enableUserService = true;
    };
  # };
  # XDG Desktop Portal
  #xdg.portal = {
   # enable = true;
   # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
   # config.common.default = "*";
  };

  # System upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # User configuration
  users.users.johnny = {
    isNormalUser = true;
    description = "Jonathan Joyce";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # System version
  system.stateVersion = "24.05";

  # ASUS-specific udev rule
  services.udev = {
    extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS:pn*:*
      KEYBOARD_KEY_ff31007c=f20
    '';
    extraRules = ''
      # Xbox controller rules
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666"
    '';
  };

  # Misc
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;
  powerManagement.enable = true;
}
