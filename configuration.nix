{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (fetchTarball {
      url = "https://github.com/NixOS/nixos-hardware/archive/d0cb432a9d28218df11cbd77d984a2a46caeb5ac.tar.gz";
    } + "/asus/zephyrus/ga402x/amdgpu")
  ];

  # Display server and desktop environment configuration
  services.xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;  # Enable Wayland
      };
    };
    desktopManager.gnome.enable = true;

    videoDrivers = [ "amdgpu" "displaylink" "modesetting" ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable GNOME Remote Desktop
  services.gnome = {
    gnome-remote-desktop.enable = true;
  };

  # Bootloader configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "amd_pstate=active"
      "cpufreq.default_governor=powersave"
      "pcie_aspm.policy=powersupersave"
      "amdgpu.runpm=1"
      "amdgpu.ppfeaturemask=0xfffbffff"  # More conservative feature mask
    ];
  };

  # Swap configuration with Zram
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  # Networking and firewall
  networking = {
    hostName = "jjnixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
    };
    wireguard.enable = true;
  };

  # Enable Avahi for mDNS
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

  # Localization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # System packages
  environment.systemPackages = with pkgs; [
    vim neovim git vscodium ripgrep wireguard-tools
    gtop htop btop nmap powertop lm_sensors fastfetch
    kitty obsidian google-chrome firefox
    discord ticktick vlc krita element-desktop
    gnome.gnome-tweaks winbox onlyoffice-bin
    steam gamemode barrier
    nerdfonts rustup cargo rust-analyzer
    flatpak vulkan-tools mesa remmina
    xboxdrv linuxConsoleTools evtest
    s-tui  # System monitoring tool
    nvtopPackages.full  # GPU monitoring
    
    # Gnome Remote Desktop and related packages
    gnome.gnome-remote-desktop
    gnome.gnome-control-center
  ];

  # Environment variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Hardware and services
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

  # Audio and pipewire configuration
  sound.enable = true;
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

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
    supergfxd.enable = true;
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  # Automatic system upgrades (minimal configuration)
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # User configuration
  users.users.johnny = {
    isNormalUser = true;
    description = "Jonathan Joyce";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
  };

  # Udev rules
  services.udev = {
    extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS:pn*:*
      KEYBOARD_KEY_ff31007c=f20
    '';
    extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02d1", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0b12", MODE="0666"
    '';
  };

  # Miscellaneous settings
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;
  powerManagement.enable = true;

  system.stateVersion = "24.05";
}
