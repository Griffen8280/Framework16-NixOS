# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan and others
      ./hardware-configuration.nix
      ./decky.nix
    ];

  # Setup monitor output for GDM/Gnome
  system.activationScripts = {
    gdm_config = {
      deps = [ "specialfs" ];
      text = ''
        MONITORS_CONF_FILE=/etc/nixos/data/monitors.xml
        GDM_CONF_PATH=/run/gdm/.config
        if [ ! -d $GDM_CONF_PATH ]; then
          mkdir -p $GDM_CONF_PATH
        fi
        if [ -f $MONITORS_CONF_FILE ]; then
          cp -rf $MONITORS_CONF_FILE $GDM_CONF_PATH
          chown gdm:gdm  $GDM_CONF_PATH/$(basename $MONITORS_CONF_FILE)
          chmod 644 $GDM_CONF_PATH/$(basename $MONITORS_CONF_FILE)
        fi
      '';
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable Hardware Graphics
  hardware = {
    graphics = {
        enable = true;
        enable32Bit = true;
    };

    amdgpu.amdvlk = {
        enable = true;
        support32Bit.enable = true;
    };
  };

  # Load the graphics drivers
  services.xserver.videoDrivers = ["amdgpu"];

  # Enable kernel level Graphics options
  boot.kernelParams = [
    "video=DP-4:3840x1600@60"
    "video=eDP-2:2560x1600@165"
  ];

  # Enable i2c Control
  hardware.i2c.enable = true;
  services.udev.extraRules = ''
        KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  # Enable Plymouth for "pretty" boot
  boot.plymouth.enable = true;
 
  # Enable Flatpak on system
  services.flatpak.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # May not need this on Gnome
  # Note be sure to run `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
  # after updating with `sudo nixos-rebuild switch` so that the flathub repo is integrated into software center.

  # Setup Appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  #Network Mounts
  fileSystems."/mnt/Main" = {
    device = "//192.168.1.2/Main";
    fsType = "cifs";
    options = ["credentials=/etc/nixos/smb-secrets,uid=1000,gid=1000"];
  };
  fileSystems."/mnt/Misc" = {
    device = "//192.168.1.2/Misc";
    fsType = "cifs";
    options = ["credentials=/etc/nixos/smb-secrets,uid=1000,gid=1000"];
  };
  fileSystems."/mnt/RetroNAS" = {
    device = "//192.168.1.75/retronas";
    fsType = "cifs";
    options = ["credentials=/etc/nixos/nas-secrets,uid=1000,gid=1000"];
  };

  # Use latest kernel.
  #boot.kernelPackages = pkgs.linuxPackages_latest; # Latest stable mainstream kernel
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable; # Latest stable Xanmod optimized kernel
  hardware.amdgpu.initrd.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable firmwares
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Zram - Dedicate some ram to swap to keep the OS happy
  zramSwap.enable = true;
  zramSwap.memoryPercent = 05;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.username = {
    isNormalUser = true;
    description = "Your Name";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    #System Packages
    htop
    wget 
    curl 
    python311Full
    lm_sensors 
    git 
    ddcutil 
    fastfetch 
    openrgb 
    cifs-utils
    gnome-extension-manager
    gnome-tweaks
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    framework-tool
    gnome-firmware
    xdg-utils
    jq
    zenity
    efibootmgr
    zulu
    #Internet/Social
    remmina
    discord 
    filezilla 
    #Audio/Video
    handbrake 
    vlc 
    #Gaming
    protontricks
    #Misc
    meslo-lgs-nf
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  #Enable the gnome extensions services
  #nixpgks.config.firefox.enableGnomeExtensions = true;
  services.gnome.gnome-browser-connector.enable = true;

  # Install Steam with everything needed
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Setup gamemode to go with Steam and others
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Setup support for Xbox Controllers
  #hardware.xpadneo.enable = true; # Only needed for older controllers

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
