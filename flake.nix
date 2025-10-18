{
  description = "Xenlism GRUB themes — packaged for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;


      # supported resolutions and distros
      resolutions = [ "1080p" "2k" "4k" ];
      distros = [
        "arch" "Debian" "Fedora" "gentoo" "kali" "mac" "Manjaro"
        "mint" "nixos" "opensuse" "popos" "ubuntu" "win10" "win11"
      ];

      mkTheme = { distro, resolution }: pkgs.stdenvNoCC.mkDerivation {
        pname = "xenlism-grub-theme-${distro}-${resolution}";
        version = "2025-10-18";

        src = pkgs.fetchFromGitHub {
          owner = "xenlism";
          repo = "Grub-themes";
          rev = "40ac048df9aacfc053c515b97fcd24af1a06762f";
          hash = "sha256-ProTKsFocIxWAFbYgQ46A+GVZ7mUHXxZrvdiPJqZJ6I=";
        };

        dontBuild = true;

        installPhase = ''
          runHook preInstall

          # Construct path like xenlism-grub-1080p-nixos/
          srcDir="xenlism-grub-${resolution}-${distro}"
          themeDir="$out"

          mkdir -p "$themeDir"
          echo "Copying theme from $srcDir"
          cp -r "$srcDir"/Xenlism-${lib.toUpper (lib.substring 0 1 distro)}${lib.substring 1 (lib.stringLength distro - 1) distro}/* "$themeDir/"

          runHook postInstall
        '';

        meta = {
          description = "Xenlism GRUB theme for ${lib.toUpper distro} (${resolution})";
          homepage = "https://github.com/xenlism/Grub-themes";
          #license = lib.licenses.gpl3Plus;
          platforms = lib.platforms.linux;
          maintainers = [];
        };
      };

      allThemes = builtins.listToAttrs (
        builtins.concatLists (map (distro:
          map (resolution: {
            name = "xenlism-grub-theme-${distro}-${resolution}";
            value = mkTheme { inherit distro resolution; };
          }) resolutions
        ) distros)
      );

    in {
      packages.${system} = allThemes // {
        default = allThemes."xenlism-grub-theme-nixos-1080p";
      };
    };
}

