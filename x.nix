{ config, pkgs, ... }:

let background-image = pkgs.fetchurl {
      url = "http://orig01.deviantart.net/1810/f/2012/116/a/4/tranquility_by_andreewallin-d4xjtd0.jpg";
      sha256 = "17jcvy268aqcix7hb8acn9m9x7dh8ymb07w4f7s9apcklimz63bq";
    };
    solarized-theme = pkgs.fetchFromGitHub {
      owner = "anderspapitto";
      repo = "nixos-solarized-slim-theme";
      rev = "2822b7cb7074cf9aa36afa9b5cabd54105b3306c";
      sha256 = "0jp7qq02ly9wiqbgh5yamwd31ah1bbybida7mn1g6qpdijajf247";
    };
    simpleXService = name: description: execStart: {
      inherit description;
      environment = {
        DISPLAY = ":${toString config.services.xserver.display}";
      };
      serviceConfig = {
        Type = "simple";
        User = "anders";
        ExecStart = pkgs.writeScript name ''
            #! ${pkgs.bash}/bin/bash
            . ${config.system.build.setEnvironment}
            set -xe
            ${execStart}
          '';
        RestartSec = 3;
        Restart = "always";
      };
      wantedBy = [ "display-manager.service" ];
      after = [ "display-manager.service" ];
    };
in {
  environment = {
    etc = {
      "compton/inverted"          .source = ./config/compton-inverted;
      "compton/noninverted"       .source = ./config/compton-noninverted;
      "dunst/dunstrc"             .source = ./config/dunstrc;
      "i3/status"                 .source = ./config/i3status;
      "xdg/herbstluftwm/autostart".source = ./config/herbstluftwm;
      "xdg/herbstluftwm/panel.sh" .source = ./config/panel.sh;
      "X11/xresources"            .source = ./config/xresources;
    };
    systemPackages = with pkgs; [ dzen2 gnupg ];
  };

  services = {
    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      displayManager.slim.theme = solarized-theme;
      windowManager = {
        herbstluftwm = {
          enable = true;
          configFile = "/etc/xdg/herbstluftwm/autostart";
        };
        default = "herbstluftwm";
      };
      synaptics = {
        enable = true;
        tapButtons = false;
        twoFingerScroll = true;
      };
      layout = "us";
      # note typo in base.lst, where it says 'ctrl:ctrl_ralt' when it
      # means 'ctrl:ralt_rctrl'
      xkbOptions = "ctrl:ralt_rctrl, lv3:caps_switch, shift:both_capslock";
      xkbVariant = "colemak";
    };
  };

  systemd.services = {
    compton = simpleXService "compton"
      "lightweight compositing manager"
      "${pkgs.compton}/bin/compton -cCG --config /etc/compton/noninverted"
      ;
    compton-night =
      let base-service = simpleXService "compton-night"
            "lightweight compositing manager (night mode)"
            "${pkgs.compton}/bin/compton -cCG --config /etc/compton/inverted"
            ;
      in base-service // {
          conflicts = [ "compton.service" ];
          wantedBy = [ ];
      };
    dunst = simpleXService "dunst"
      "Lightweight libnotify server"
      "exec ${pkgs.dunst}/bin/dunst -config /etc/dunst/dunstrc"
      ;
    feh = simpleXService "feh"
      "Set background"
      ''
        ${pkgs.feh}/bin/feh --bg-fill --no-fehbg ${background-image}
        exec sleep infinity
      ''
      ;
    redshift = simpleXService "redshift"
      "Redshift colour temperature adjuster"
      "exec ${pkgs.redshift}/bin/redshift -l 37.7:133.4 -t 5500:2500 -b 1:1"
      ;
    xbanish = simpleXService "xbanish"
      "xbanish hides the mouse pointer"
      "exec ${pkgs.xbanish}/bin/xbanish"
      ;
    clipit = simpleXService "clipit"
      "clipboard manager"
      "exec ${pkgs.clipit}/bin/clipit"
      ;
  };
}
