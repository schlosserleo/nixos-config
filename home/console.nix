{ lib, pkgs, ... }:
let
  inherit (lib.hm.gvariant)
    mkArray
    mkDictionaryEntry
    mkDouble
    mkString
    mkTuple
    mkVariant
    ;

  hexDigits = lib.listToAttrs (
    lib.imap0 (i: c: lib.nameValuePair c i) (lib.stringToCharacters "0123456789abcdef")
  );

  rgb =
    hex:
    let
      byte =
        offset:
        let
          s = lib.substring offset 2 (lib.toLower hex);
        in
        hexDigits.${lib.substring 0 1 s} * 16 + hexDigits.${lib.substring 1 1 s};
    in
    mkTuple (
      map (offset: mkDouble (byte offset / 255.0)) [
        1
        3
        5
      ]
    );

  mkPalette =
    {
      foreground,
      background,
      colours,
    }:
    mkVariant (
      mkArray "{sv}" [
        (mkDictionaryEntry [
          (mkString "foreground")
          (mkVariant (rgb foreground))
        ])
        (mkDictionaryEntry [
          (mkString "background")
          (mkVariant (rgb background))
        ])
        (mkDictionaryEntry [
          (mkString "transparency")
          (mkVariant (mkDouble 0.0))
        ])
        (mkDictionaryEntry [
          (mkString "colours")
          (mkVariant (mkArray "(ddd)" (map rgb colours)))
        ])
      ]
    );

  uuid = "3f2d6b18-9c47-4d1e-8a05-7e6c1b93a2f4";

  # projekt0n/github-nvim-theme: github_dark_colorblind
  # ANSI 0/8 deviate: the theme maps them onto the background, hiding anything
  # dimmed. These are Primer's own terminal grays.
  night = mkPalette {
    background = "#0d1117";
    foreground = "#c9d1d9";
    colours = [
      "#484f58"
      "#ec8e2c"
      "#58a6ff"
      "#d29922"
      "#58a6ff"
      "#bc8cff"
      "#76e3ea"
      "#b1bac4"
      "#6e7681"
      "#fdac54"
      "#79c0ff"
      "#e3b341"
      "#79c0ff"
      "#d2a8ff"
      "#b3f0ff"
      "#b1bac4"
    ];
  };

  # projekt0n/github-nvim-theme: github_light_colorblind
  day = mkPalette {
    background = "#ffffff";
    foreground = "#1b1f24";
    colours = [
      "#24292f"
      "#b35900"
      "#0550ae"
      "#4d2d00"
      "#0969da"
      "#8250df"
      "#1b7c83"
      "#6e7781"
      "#57606a"
      "#8a4600"
      "#0969da"
      "#633c01"
      "#218bff"
      "#a475f9"
      "#3192aa"
      "#8c959f"
    ];
  };

  livery = mkArray "{sv}" [
    (mkDictionaryEntry [
      (mkString "uuid")
      (mkVariant (mkString uuid))
    ])
    (mkDictionaryEntry [
      (mkString "name")
      (mkVariant (mkString "GitHub Colorblind"))
    ])
    (mkDictionaryEntry [
      (mkString "night")
      night
    ])
    (mkDictionaryEntry [
      (mkString "day")
      day
    ])
  ];
in
{
  home.packages = [ pkgs.maple-mono.NF ];

  dconf.settings."org/gnome/Console" = {
    theme = "auto";
    livery = uuid;
    use-system-font = false;
    custom-font = "Maple Mono NF 12";
    custom-liveries = mkArray "{sv}" [
      (mkDictionaryEntry [
        (mkString uuid)
        (mkVariant livery)
      ])
    ];
  };
}
