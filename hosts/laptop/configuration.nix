# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "laptop-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

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

  # ---- Enable Hibernation ----
  boot.kernelParams = ["resume_offset=242839552"];

  boot.resumeDevice = "/dev/disk/by-uuid/15bf51f6-5e1b-4b6f-a7bf-d1016d6919d3";

  powerManagement.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB
    }
  ];

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=45m
  '';

  # Wifi after wake fix
  environment.etc."systemd/system-sleep/rtw89_8852ce".source =
    pkgs.writeShellScript "rtw89_8852ce-system-sleep" ''
      #!/bin/sh
      # args: $1 = pre|post, $2 = suspend|hibernate|suspend-then-hibernate|...

      case "$1/$2" in
        pre/hibernate|pre/suspend-then-hibernate)
          ${pkgs.kmod}/bin/modprobe -rv rtw89_8852ce || true
          ;;
        post/hibernate|post/suspend-then-hibernate)
          ${pkgs.kmod}/bin/modprobe -v rtw89_8852ce || true
          ${pkgs.systemd}/bin/systemctl restart NetworkManager.service || true
          ;;
      esac
    '';
  # ---- Enable Hibernation ----

  # Enable greetd service
  services.greetd.enable = true;

  # Enable regreet (will use Cage automatically)
  programs.regreet.enable = true;

  # Optionally, configure regreet appearance
  programs.regreet.settings = {
    # Example options; see documentation for more
    theme.name = "Adwaita";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
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

  # Media control 
  programs.dconf.enable = true;
  services.playerctld.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Flipper Zero
  users.groups.flipper = {};
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="5740", GROUP="flipper", MODE="0660"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.storage = {};
  users.users.matthew = {
    shell = pkgs.bash;
    isNormalUser = true;
    description = "Matthew";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "storage" "flipper" "dialout" ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "matthew" = import ./home.nix;
    };
    backupFileExtension = "backup";
  };

  programs.firefox.enable = false;

  # Run dynamically linked binaries 
  programs.nix-ld.enable = true;

  # STYLIX
  stylix = {
    enable = true;
    image = ../../styles/erasmusbrugStyle/wallpaper.jpg;
    base16Scheme = ../../styles/erasmusbrugStyle/mocha.yaml;
    autoEnable = true;
    polarity = "dark";
    targets.chromium.enable = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # STABLE PACKAGES
  environment.systemPackages = with pkgs; [ 
        wget
        htop
	wireguard-tools
	ntfs3g
	efibootmgr
	samba
	virt-manager
        btop-rocm
        psmisc
        usbutils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Automount to drives
  boot.supportedFilesystems = [ "ntfs" ];
  services.udisks2.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var YES = polkit.Result.YES;
      // NOTE: there must be a comma at the end of each line except for the last:
      var permission = {
        // required for udisks2:
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.power-off-drive": YES,
        // required for udisks2 if using udiskie from another seat (e.g. systemd):
        "org.freedesktop.udisks2.filesystem-mount-other-seat": YES,
        "org.freedesktop.udisks2.filesystem-unmount-others": YES,
        "org.freedesktop.udisks2.encrypted-unlock-other-seat": YES,
        "org.freedesktop.udisks2.eject-media-other-seat": YES,
        "org.freedesktop.udisks2.power-off-drive-other-seat": YES
      };
      if (subject.isInGroup("storage")) {
        return permission[action.id];
      }
    });
  '';
  
  # Power efficiency
  services.power-profiles-daemon.enable = true;

  # VM

  services.kresd.enable = false;
  services.resolved.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      #ovmf = { # not needed in NixOS 25.11 since https://github.com/NixOS/nixpkgs/pull/421549
      #  enable = true;
      #  packages = [(pkgs.OVMF.override {
      #    secureBoot = true;
      #    tpmSupport = true;
      #  }).fd];
      #};
    };
  };

  # FONTS

  fonts.packages = with pkgs; [
    powerline-fonts
    noto-fonts-cjk-sans
    nerd-fonts.arimo
    nerd-fonts.dejavu-sans-mono

    roboto
    helvetica-neue-lt-std
  ]; 

  # SECURITY and FINGERPRINT

  # Fingerprint Sensor
  services.fprintd.enable = true;

  # For ELAN sensors, you might need the TOD driver
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-elan;


  security.pam.services = {
    login.fprintAuth = true;

    sudo.fprintAuth = true;

    swaylock = {};
    swaylock.fprintAuth = true;

    greetd.fprintAuth = true;  
  };

  # HW BUTTON BEHAVIOR

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
    HandlePowerKey = "hibernate";
  };

  # SAMBA

  services.gvfs.enable = true;

  # Wireless devices battery

  services.upower.enable = true;
  
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

}

