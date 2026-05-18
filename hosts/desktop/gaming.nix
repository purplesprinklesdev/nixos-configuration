{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extest.enable = true;
    extraPackages = with pkgs; [
      hidapi
    ];
  };
  hardware.steam-hardware.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
