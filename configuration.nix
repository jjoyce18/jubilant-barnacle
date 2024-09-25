{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (fetchTarball {
      url = "https://github.com/NixOS/nixos-hardware/archive/d0cb432a9d28218df11cbd77d984a2a46caeb5ac.tar.gz";
    } + "/asus/zephyrus/ga402x/amdgpu")
  ];

  # Nix configuration
  nix = {
    package = pkgs.nixFlakes;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "amd_pstate=passive"
      "cpufreq.default_governor=powersave"
      "pcie_aspm.policy=powersupersave"
    ];
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # Uncomment the following lines if you need these ports open
      # allowedTCPPorts = [ 80 443 ];
      # allowedUDPPorts = [ 5353 ]; # For mDNS
    };
  };

  # Enable mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # X11 and GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Localization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # System packages
  environment.systemPackages = with pkgs; [
    # Development
    vim neovim git vscodium

    # System utilities
    gtop htop btop nmap powertop lm_sensors fastfetch

    # Applications
    kitty obsidian google-chrome firefox
    discord ticktick vlc krita element-desktop
    gnome.gnome-tweaks winbox onlyoffice-bin

    # Gaming
    steam gamemode

    # Fonts
    nerdfonts

    # Misc
    flatpak vulkan-tools mesa xrdp remmina
    xboxdrv linuxConsoleTools evtest
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
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    steam-hardware.enable = true;
  };

  # Audio
  sound.enable = true;
  security.rtkit.enable = true;

  # System services
  services = {
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
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
  };

  # Automatic system upgrades
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    # Uncomment the following line if you want daily upgrades
    # dates = "daily";
  };

  # User configuration
  users.users.johnny = {
    isNormalUser = true;
    description = "Jonathan Joyce";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
  };

  # ASUS-specific udev rules
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.05";
}
