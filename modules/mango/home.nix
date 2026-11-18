{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) genList;
  inherit (lib.attrsets) genAttrs mapAttrsToList;
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) id;
  inherit (config.lib.stylix) colors;

  cfg = config.wayland.windowManager.mango;

  mkColor = color: "0x${color}ff";

  gap = 10;
  radius = 20;
  width = 3;

  directions = {
    left = "h";
    right = "l";
    up = "k";
    down = "j";
  };

  stackDirections = {
    next = "i";
    prev = "u";
  };

  tags =
    genAttrs (genList (i: toString (i + 1)) 9) id
    // {
      "10" = "0";
    };

  eachTag = f: mapAttrsToList f tags;
  eachDirection = f: mapAttrsToList f directions;
  eachStackDirection = f: mapAttrsToList f stackDirections;
in {
  imports = [inputs.mangowm.hmModules.mango];

  config = mkIf cfg.enable {
    services.swayosd.enable = true;

    wayland.windowManager.mango = {
      settings = {
        # Monitors
        monitor_rule = "model:U28E590,scale:1.5";

        # Tags
        tag_rule = eachTag (tag: _: "id:${tag},layout_name:fair");
        tag_num = 10;

        # Animations
        animation_duration = {
          move = 300;
          open = 300;
        };

        # Borders
        root_color = mkColor colors.base00;
        border_color = mkColor colors.base01;
        focus_color = mkColor colors.base01;
        split_color = mkColor colors.base01;
        urgent_color = mkColor colors.base01;

        border = {
          inherit radius;
          px = width;
        };

        gap = {
          inner_horizontal = gap;
          inner_vertical = gap;
          outer_horizontal = gap;
          outer_vertical = gap;
        };

        # Jump labels
        jump_label_decorate = {
          fg_color = mkColor colors.base05;
          bg_color = mkColor colors.base01;
          font_desc = "sans-serif Regular 16";

          padding = {
            x = gap;
            y = gap;
          };

          border = {
            width = 0;
            color = mkColor colors.base01;
          };

          corner.radius = 10;
        };

        # Input
        disable_middle_paste = 1;
        drag_tile_to_tile = 1;
        xkb_rules_layout = config.home.keyboard.layout;

        trackpad = {
          accel_profile = 1; # Flat
          accel_speed = 1.0;
          natural_scrolling = 1;
        };

        # Binds
        axisbind = [
          "super,down,viewtoright_have_client"
          "super,up,viewtoleft_have_client"
        ];

        bind =
          # Applications
          [
            "super,r,spawn,anyrun"
            "super,t,spawn,ghostty"
          ]
          # Windows
          ++ [
            "super+shift,q,quit"
            "super,d,togglefloating"
            "super,f,togglefullscreen"
            "super,q,killclient"
          ]
          ++ eachDirection (dir: key: "super+shift,${key},exchange_client,${dir}")
          ++ eachDirection (dir: key: "super,${key},focusdir,${dir}")
          ++ eachStackDirection (dir: key: "super+shift,${key},exchange_stack_client,${dir}")
          ++ eachStackDirection (dir: key: "super,${key},focusstack,${dir}")
          # Tags
          ++ [
            "super,o,togglejump"
          ]
          ++ eachTag (tag: key: "super+shift,${key},tag,${tag}")
          ++ eachTag (tag: key: "super,${key},view,${tag}")
          # Brightness
          ++ [
            "none,XF86AudioLowerVolume,spawn,swayosd-client --output-volume lower"
            "none,XF86AudioRaiseVolume,spawn,swayosd-client --output-volume raise"
            "none,XF86MonBrightnessDown,spawn,swayosd-client --brightness lower"
            "none,XF86MonBrightnessUp,spawn,swayosd-client --brightness raise"
          ]
          # Volume
          ++ [
            "none,XF86AudioMute,spawn,swayosd-client --output-volume mute-toggle"
            "none,XF86AudioNext,spawn,swayosd-client --playerctl next"
            "none,XF86AudioPlay,spawn,swayosd-client --playerctl play-pause"
            "none,XF86AudioPrev,spawn,swayosd-client --playerctl previous"
          ];

        gesturebind = [
          "none,left,3,viewtoright_have_client"
          "none,right,3,viewtoleft_have_client"
          "none,up,3,spawn,anyrun"
          "none,down,3,spawn,anyrun"
        ];

        mousebind = [
          "super,btn_left,moveresize,curmove"
          "super,btn_right,moveresize,curresize"
        ];
      };
    };
  };
}
