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
  networking.networkmanager.enable = true;

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

  # Enable greetd service
  services.greetd.enable = true;

  # Enable regreet (will use Cage automatically)
  programs.regreet.enable = true;

  # Optionally, configure regreet appearance
  programs.regreet.settings = {
    # Example options; see documentation for more
    theme.name = "Adwaita";
  };

  services.gnome.gnome-keyring.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matthew = {
    shell = pkgs.bash;
    isNormalUser = true;
    description = "Matthew";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
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

    greetd.enableGnomeKeyring = true;
  };

  # HW BUTTON BEHAVIOR

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };

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

