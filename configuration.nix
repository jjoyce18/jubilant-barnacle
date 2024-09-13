{ config, pkgs, lib, ... }:



{

imports = [

<nixos-hardware/asus/zephyrus/ga402x/amdgpu>

./hardware-configuration.nix

];



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



# Nix configuration

nix.settings.experimental-features = [ "nix-command" "flakes" ];



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



# X11 and desktop environment

services.xserver.enable = true;

services.displayManager = {

sddm = {

enable = true;

wayland.enable = true;

};

defaultSession = "plasma";

};

services.desktopManager.plasma6.enable = true;



# Hyprland

programs.hyprland = {

enable = true;

xwayland.enable = true;

};



# System packages

environment.systemPackages = with pkgs; [

# Terminal utilities

vim htop btop nmap git powertop

# GUI applications

kitty kate gimp obsidian google-chrome vscodium

# System tools

flatpak vulkan-tools mesa steam xrdp remmina

# Gaming and input

xboxdrv linuxConsoleTools evtest

# Uncomment if needed:

 discord ticktick

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

packages = with pkgs; [ kate ];

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
