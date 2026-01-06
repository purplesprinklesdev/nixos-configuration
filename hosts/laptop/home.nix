{ lib, config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
  
  # Sway Config
  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "alacritty";
      menu = "wofi --show run";
      
      # Status bar(s)
      bars = [{
        fonts.size = 11.0;
        command = "waybar";
        position = "top";
      }];

      gaps = {
        smartGaps = true;
        smartBorders = "no_gaps";
        inner = 6;
        outer = 6;
      };

      window = {
        titlebar = false;
        border = 2;
      };

      floating = {
        titlebar = false;
        border = 2;
      };

      # Color fixes for stylix
      colors = let 
        stylix = config.lib.stylix.colors;
      in {
        focused.indicator = lib.mkForce "#${stylix.base0D}";
        focusedInactive.indicator = lib.mkForce "#${stylix.base03}";
        unfocused.indicator = lib.mkForce "#${stylix.base03}";
        urgent.indicator = lib.mkForce "#${stylix.base08}";
        placeholder.indicator = lib.mkForce "#${stylix.base03}";
      };

      # New Keybindings
      modifier = "Mod1";
      keybindings = let mod = "Mod1"; in pkgs.lib.mkOptionDefault {
        "${mod}+Return" = "exec pkill wofi || wofi --show drun";
        "${mod}+d" = "exec pkill wofi || wofi --show drun";
        "${mod}+t" = "exec alacritty";
        "${mod}+b" = "exec brave";
        "${mod}+z" = "exec zeditor";
        "${mod}+q" = "kill";
        "${mod}+f" = "exec nautilus";
        "${mod}+Shift+f" = "fullscreen toggle";
        "${mod}+w" = "exec pkill waybar || waybar";
        "Print" = ''exec grim -g "$(slurp)" - | swappy -f -'';
        "Super_L" = "exec pkill wofi || wofi --show drun";
        "XF86Calculator" = ''exec gnome-calculator'';
        "XF86AudioMute" = ''exec pactl set-sink-mute @DEFAULT_SINK@ toggle'';
        "XF86AudioLowerVolume" = ''exec pactl set-sink-volume @DEFAULT_SINK@ -15%'';
        "XF86AudioRaiseVolume" = ''exec pactl set-sink-volume @DEFAULT_SINK@ +15%'';
        "XF86MonBrightnessUp" = ''exec brightnessctl set 10%+'';
        "XF86MonBrightnessDown" = ''exec brightnessctl set 10%-'';
        "XF86AudioPlay" = ''exec playerctl play-pause'';
      }; 
      
      input = {
        # Set CapsLock to Esc
        "*" = {
          xkb_options = "caps:escape";
        };
        # Mouse sens settings
        "1133:16500:Logitech_G305" = {
          accel_profile = "flat";
          pointer_accel = "-0.2";
        };
        # Touchpad
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled";
        };
      };

      # Display device configuration
      output = {
        DP-3 = {
          # Set HIDP scale (pixel integer scaling)
          scale = "1";
          # Set res and refresh rate
          mode = "1920x1080@165Hz";
        };
      };

      # Startup apps
      startup = [
        { command = "${pkgs.autotiling}/bin/autotiling"; always = true; }
        { command = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit"; always = true; }
        { command = "${pkgs.brightnessctl}/bin/brightnessctl -d intel_backlight"; always = true; }
        { command = "dbus-update-activation-environment --all"; always = true; }
      ];
    };
    # Floating windows for waybar apps
    extraConfig = ''
      for_window [app_id="org.pulseaudio.pavucontrol"] {
        floating enable
        resize set height 600px
        resize set width 600px
        move up 280px
      }
      for_window [app_id="nmwui"] {
        floating enable
        resize set height 600px
        resize set width 800px
        move up 280px
      }
      for_window [app_id=".blueman-manager-wrapped"] {
        floating enable
        resize set height 600px
        resize set width 800px
        move up 280px
      }
    '';
  };
  programs.swayimg.enable = true;

  programs.swaylock.enable = true;

  
  # Idling config
  services.swayidle =
  let
    # Lock command
    lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
    # Sway
    display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
  in
  {
    enable = true;
    timeouts = [
      {
        timeout = 420; # 7 minutes
        command = "${pkgs.libnotify}/bin/notify-send 'Locking in 10 seconds' -t 5000";
      }
      {
        timeout = 430;
        command = lock;
      }
      {
        timeout = 440;
        command = display "off";
        resumeCommand = display "on";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        # adding duplicated entries for the same event may not work
        command = (display "off") + "; " + lock;
      }
      {
        event = "after-resume";
        command = display "on";
      }
      {
        event = "lock";
        command = (display "off") + "; " + lock;
      }
      {
        event = "unlock";
        command = display "on";
      }
    ];
  };
  services.swaync = {
    enable = true;
  };

  # Automount to External Drives
  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "${pkgs.nautilus}/bin/nautilus";
      };
    };
  };

  # Reset GTK font bc home-manager changed it
  gtk.font.size = lib.mkForce 10;
  dconf.settings."org/gnome/desktop/interface".font-name = lib.mkForce "Arimo Nerd Font 10";
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    wofi
    waybar

    swaybg
    sway-audio-idle-inhibit
    autotiling

    blueman
    keychain
    pavucontrol

    gparted
    gdu
    vim-full
    fastfetch
    nautilus # File manager
    gnome-software # flatpak Software Center
    gnome-calculator

    zed-editor
    brave
    
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.alacritty = {
    enable = true;
    settings = lib.mkForce {
      env.TERM = "alacritty";
      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };

        opacity = 0.75;
      };
      font = {
        normal = {
          family = "DejaVu Sans Mono for Powerline";
          style = "Regular";
        };
        bold = {
          family = "DejaVu Sans Mono for Powerline";
          style = "Bold";
        };
        italic = {
          family = "DejaVu Sans Mono for Powerline";
          style = "Oblique";
        };
        bold_italic = {
          family = "DejaVu Sans Mono for Powerline";
          style = "Bold Oblique";
        };
        size = 11.00;
      };
      colors = {
        transparent_background_colors = false;
      };
    };
  };

  programs.starship = 
  let 
    userCol = "#000000";
    userText = "#ffffff";
    dirCol = "#cba6f7";
    dirText = "#000000";
  in {
    enable = true;
    settings = {
      add_newline = true;
      format = ''
        [](bg:${userCol} fg:${userCol})$username$hostname[](bg:${userCol} fg:${userCol})[](bg:${dirCol} fg:${userCol})[](bg:${dirCol} fg:${dirCol})$directory[](bg:${dirCol} fg:${dirCol})[](bg:none fg:${dirCol})
     '';
      command_timeout = 1000;
      username = {
        style_user = "bg:${userCol} fg:${userText}";
        style_root = "bg:red fg:${userText}";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        format = "[@$hostname](bg:${userCol} fg:${userText})";
        disabled = false;
      };
      directory = {
        format = "[$path]($style)[$read_only]($style)";
        style = "bg:${dirCol} fg:${dirText}";
      }; 
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
       if command -v keychain > /dev/null 2>&1
         then eval $(keychain --eval --nogui /home/matthew/.ssh/id_ed25519 --quiet)
       fi
       fastfetch
     '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "purplesprinklesdev";
      user.email = "ought-impale-doozy@duck.com";
      init.defaultBranch = "main";
      gpg.format = "ssh";
    };
  };

  programs.swappy = {
    enable = true;
    settings = {
      Default = {
        save_dir = "$HOME/Pictures/Screenshots";
        save_filename_format = "%Y-%m-%d %H-%M-%S.png";
      };
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".config/waybar/config".source = ./dotfiles/waybar/config;
    ".config/waybar/style.css".source = ./dotfiles/waybar/style.css;

    ".config/wofi/config".source = ./dotfiles/wofi/config;
    ".config/wofi/style.css".source = ./dotfiles/wofi/style.css;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matthew/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
