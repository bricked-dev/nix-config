{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (builtins) readFile;
  inherit (lib) mkIf singleton;
  inherit (config.lib.stylix) colors;

  cfg = config.programs.librewolf;

  extensions = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  extensionsDeclarative = inputs.firefox-extensions-declarative.packages.${pkgs.stdenv.hostPlatform.system};
in {
  config = mkIf cfg.enable {
    programs.librewolf = {
      policies."3rdparty".Extensions."addon@darkreader.org" = {
        theme = {
          darkSchemeBackgroundColor = colors.withHashtag.base00;
          darkSchemeTextColor = colors.withHashtag.base05;
          lightSchemeBackgroundColor = colors.withHashtag.base00;
          lightSchemeTextColor = colors.withHashtag.base05;
          selectionColor = colors.withHashtag.base0D;
          previewNewDesign = true;
        };
      };

      profiles.default = {
        name = "Default";
        extensions = {
          force = true;
          packages = [
            extensions.ublock-origin
            extensions.bitwarden
            extensionsDeclarative.darkreader-declarative
          ];
        };

        search = {
          default = "ddg";
          force = true;
          engines = {
            "bing".metaData.hidden = true;
            "google".metaData.hidden = true;
            "perplexity".metaData.hidden = true;
            "reddit".metaData.hidden = true;
            "wikipedia".metaData.hidden = true;
            "policy-DuckDuckGo Lite".metaData.hidden = true;
            "policy-MetaGer".metaData.hidden = true;
            "policy-Mojeek".metaData.hidden = true;
            "policy-SearXNG - searx.be".metaData.hidden = true;
            "policy-StartPage".metaData.hidden = true;

            "AliExpress (de)" = {
              urls = singleton {template = "https://de.aliexpress.com/w/wholesale-{searchTerms}.html";};
              icon = "https://de.aliexpress.com/favicon.ico";
              definedAliases = ["@aliexpressde" "@al"];
            };
            "AlternativeTo" = {
              urls = singleton {template = "https://alternativeto.net/browse/search/?q={searchTerms}";};
              icon = "https://alternativeto.net/static/icons/a2/favicon.svg";
              definedAliases = ["@alternativeto" "@alt"];
            };
            "Amazon (de)" = {
              urls = singleton {template = "https://www.amazon.de/s?k={searchTerms}";};
              icon = "https://www.amazon.de/favicon.ico";
              definedAliases = ["@amazonde" "@az"];
            };
            "ArchWiki" = {
              urls = singleton {template = "https://wiki.archlinux.org/title/Special:Search?search={searchTerms}";};
              icon = "https://www.archwiki.org/favicon.ico";
              definedAliases = ["@archwiki" "@arw"];
            };
            "Brave" = {
              urls = singleton {template = "https://search.brave.com/search?q={searchTerms}";};
              icon = "https://cdn.search.brave.com/serp/v3/_app/immutable/assets/brave-search-icon.CsIFM2aN.svg";
              definedAliases = ["@brave" "@br"];
            };
            "Codeberg" = {
              urls = singleton {template = "https://codeberg.org/explore/repos?q={searchTerms}";};
              icon = "https://codeberg.org/assets/img/favicon.svg";
              definedAliases = ["@codeberg" "@cb"];
            };
            "Crates" = {
              urls = singleton {template = "https://crates.io/search?q={searchTerms}";};
              icon = "https://crates.io/favicon.ico";
              definedAliases = ["@crates" "@cr"];
            };
            "DuckDuckGo Bangs" = {
              urls = singleton {template = "https://duckduckgo.com/bangs?q={searchTerms}";};
              icon = "https://duckduckgo.com/favicon.ico";
              definedAliases = ["@duckduckgobangs" "@bangs" "@bang"];
            };
            "Custom Wikipedia" = {
              _id = "custom-wikipedia";
              _name = "Wikipedia (en)";
              urls = singleton {template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}";};
              icon = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
              definedAliases = ["@wikipedia" "@wp"];
            };
            "Custom Wikipedia (de)" = {
              _id = "custom-wikipedia-de";
              _name = "Wikipedia (de)";
              urls = singleton {template = "https://de.wikipedia.org/wiki/Special:Search?search={searchTerms}";};
              icon = "https://de.wikipedia.org/static/favicon/wikipedia.ico";
              definedAliases = ["@wikipediade" "@wpde"];
            };
            "Ebay (de)" = {
              urls = singleton {template = "https://www.ebay.de/sch/i.html?_nkw={searchTerms}";};
              icon = "https://www.amazon.de/favicon.ico";
              definedAliases = ["@ebayde" "@eb"];
            };
            "Fancade Wiki" = {
              urls = singleton {template = "https://www.fancade.com/wiki/Special:Search?search={searchTerms}";};
              icon = "https://www.fancade.com/favicon.ico";
              definedAliases = ["@fancadewiki" "@fcw"];
            };
            "Flathub" = {
              urls = singleton {template = "https://flathub.org/apps/search?q={searchTerms}";};
              icon = "https://flathub.org/favicon.png";
              definedAliases = ["@flathub" "@fh"];
            };
            "GitHub" = {
              urls = singleton {template = "https://github.com/search?q={searchTerms}";};
              icon = "https://github.githubassets.com/favicons/favicon.png";
              definedAliases = ["@github" "@gh"];
            };
            "GitLab" = {
              urls = singleton {template = "https://gitlab.com/search?search={searchTerms}";};
              icon = "https://gitlab.com/assets/favicon-72a2cad5025aa931d6ea56c3201d1f18e68a8cd39788c7c80d5b2b82aa5143ef.png";
              definedAliases = ["@gitlab" "@gl"];
            };
            "Home Manager Options" = {
              urls = singleton {template = "https://search.nixos.org/options?source=home_manager&query={searchTerms}";};
              icon = "https://search.nixos.org/favicon.png";
              definedAliases = ["@homemanageroptions" "@hmo"];
            };
            "Lib.rs" = {
              urls = singleton {template = "https://lib.rs/search?q={searchTerms}";};
              icon = "https://lib.rs/logo.svg";
              definedAliases = ["@librs" "@lr"];
            };
            "MDN Web Docs" = {
              urls = singleton {template = "https://developer.mozilla.org/search?q={searchTerms}";};
              icon = "https://developer.mozilla.org/favicon.svg";
              definedAliases = ["@mdnwebdocs" "@mdn"];
            };
            "MediaWiki" = {
              urls = singleton {template = "https://www.mediawiki.org/wiki/Special:Search?search={searchTerms}";};
              icon = "https://www.mediawiki.org/static/apple-touch/mediawiki.png";
              definedAliases = ["@mediawiki" "@mw"];
            };
            "Nix Documentation" = {
              urls = singleton {template = "https://nix.dev/search.html?q={searchTerms}";};
              icon = "https://nix.dev/_static/favicon.png";
              definedAliases = ["@nixdocs" "@nxd"];
            };
            "Nix Manual" = {
              urls = singleton {template = "https://nix.dev/manual/nix/latest/?search={searchTerms}";};
              icon = "https://nix.dev/manual/nix/latest/favicon.svg";
              definedAliases = ["@nixmanual" "@nxm"];
            };
            "Nix Software" = {
              urls = singleton {template = "https://nixsoftware.org/en/packages?search={searchTerms}";};
              icon = "https://nixsoftware.org/favicon-32x32.png";
              definedAliases = ["@nixsoftware" "@nxs"];
            };
            "Nixpkgs" = {
              urls = singleton {template = "https://search.nixos.org/packages?query={searchTerms}";};
              icon = "https://search.nixos.org/favicon.png";
              definedAliases = ["@nixpkgs" "@nxp"];
            };
            "NixOS Options" = {
              urls = singleton {template = "https://search.nixos.org/options?query={searchTerms}";};
              icon = "https://search.nixos.org/favicon.png";
              definedAliases = ["@nixosoptions" "@noo"];
            };
            "NixOS Wiki" = {
              urls = singleton {template = "https://wiki.nixos.org/wiki/Special:Search?search={searchTerms}";};
              icon = "https://wiki.nixos.org/favicon.ico";
              definedAliases = ["@nixoswiki" "@now"];
            };
            "Noogle" = {
              urls = singleton {template = "https://noogle.dev/q?term={searchTerms}";};
              icon = "https://noogle.dev/favicon.png";
              definedAliases = ["@noogle" "@ng"];
            };
            "Porkbun" = {
              urls = singleton {template = "https://porkbun.com/checkout/search?q={searchTerms}";};
              icon = "https://porkbun.com/images/favicons/favicon-96x96.png";
              definedAliases = ["@porkbun" "@pb"];
            };
            "Rust Book" = {
              urls = singleton {template = "https://rust.docs.localhost/book/?search={searchTerms}";};
              icon = "https://rust-lang.org/static/images/favicon-32x32.png";
              definedAliases = ["@rustbook" "@rsb"];
            };
            "Rust Reference" = {
              urls = singleton {template = "https://rust.docs.localhost/reference/?search={searchTerms}";};
              icon = "https://rust-lang.org/static/images/favicon-32x32.png";
              definedAliases = ["@rustreference" "@rsr"];
            };
            "Rust Standard Library" = {
              urls = singleton {template = "https://rust.docs.localhost/std/?search={searchTerms}";};
              icon = "https://rust-lang.org/static/images/favicon-32x32.png";
              definedAliases = ["@ruststandardlibrary" "@rsl"];
            };
            "Rustnomicon" = {
              urls = singleton {template = "https://rust.docs.localhost/nomicon/?search={searchTerms}";};
              icon = "https://rust-lang.org/static/images/favicon-32x32.png";
              definedAliases = ["@rustnomicon" "@rsn"];
            };
            "Searchix" = {
              urls = singleton {template = "https://searchix.ovh/?query={searchTerms}";};
              icon = "https://searchix.ovh/favicon.ico";
              definedAliases = ["@searchix" "@sx"];
            };
            "StartPage" = {
              urls = singleton {template = "https://noogle.dev/q?term={searchTerms}";};
              icon = "https://noogle.dev/favicon.png";
              definedAliases = ["@startpage" "@sp"];
            };
            "The Movie DB" = {
              urls = singleton {template = "https://www.themoviedb.org/search?query={searchTerms}";};
              icon = "https://www.themoviedb.org/favicon.ico";
              definedAliases = ["@themoviedb" "@tmdb" "@tm"];
            };
            "TLD-List TLD" = {
              urls = singleton {template = "https://tld-list.com/tld/{searchTerms}";};
              icon = "https://tld-list.com/favicon.ico";
              definedAliases = ["@tldlist" "@tl"];
            };
            "Urban Dictionary" = {
              urls = singleton {template = "https://www.urbandictionary.com/define.php?term={searchTerms}";};
              icon = "https://www.urbandictionary.com/favicon-32x32.png";
              definedAliases = ["@urbandictionary" "@ud"];
            };
            "Wayback Machine" = {
              urls = singleton {template = "https://web.archive.org/web/*/{searchTerms}";};
              icon = "https://web.archive.org/favicon.ico";
              definedAliases = ["@waybackmachine" "@wb"];
            };
          };
        };

        bookmarks = {
          force = true;
          settings = [
            {
              name = "Bricked";
              tags = ["bricked"];
              url = "https://bricked.dev";
            }
            {
              name = "Codeberg";
              tags = ["git"];
              url = "https://codeberg.org";
            }
            {
              name = "Deepl (en)";
              tags = ["translator"];
              url = "https://www.deepl.com/en/translator";
            }
            {
              name = "Fancade Web";
              tags = ["fancade" "game"];
              url = "https://play.fancade.com";
            }
            {
              name = "GitHub";
              tags = ["git"];
              url = "https://github.com";
            }
            {
              name = "GitLab";
              tags = ["git"];
              url = "https://gitlab.com";
            }
            {
              name = "GNOME GitLab";
              tags = ["gnome" "git"];
              url = "https://gitlab.gnome.org";
            }
            {
              name = "Home Manager Repository";
              tags = ["homemanager" "git"];
              url = "https://github.com/nix-community/home-manager";
            }
            {
              name = "Monkeytype";
              tags = ["typing"];
              url = "https://monkeytype.com";
            }
            {
              name = "Nixpkgs Repository";
              tags = ["nixpkgs" "git"];
              url = "https://github.com/nixos/nixpkgs";
            }
            {
              name = "Nushell Book";
              tags = ["nushell" "docs"];
              url = "https://www.nushell.sh/book";
            }
            {
              name = "Proton Mail";
              tags = ["proton" "mail"];
              url = "https://mail.proton.me";
            }
            {
              name = "Purelymail";
              tags = ["mail"];
              url = "https://www.purelymail.com";
            }
            {
              name = "Rust Book";
              tags = ["rust" "docs"];
              url = "https://rust.docs.localhost/book/";
            }
            {
              name = "Rust Documentation";
              tags = ["rust" "docs"];
              url = "https://rust.docs.localhost";
            }
            {
              name = "Rust Reference";
              tags = ["rust" "docs"];
              url = "https://rust.docs.localhost/reference/";
            }
            {
              name = "Rust Standard Library";
              tags = ["rust" "docs"];
              url = "https://rust.docs.localhost/std/";
            }
            {
              name = "Rustnomicon";
              tags = ["rust" "docs"];
              url = "https://rust.docs.localhost/nomicon/";
            }
            {
              name = "Stylix Repository";
              tags = ["stylix" "git"];
              url = "https://github.com/nix-community/stylix";
            }
          ];
        };

        settings = {
          "extensions.autoDisableScopes" = 0; # Enable extensions
          "browser.aboutConfig.showWarning" = false;
          "browser.tabs.closeWindowWithLastTab" = false;

          # Privacy
          "privacy.sanitize.sanitizeOnShutdown" = false; # Keep history
          "privacy.resistFingerprinting.letterboxing" = true;

          # Blank homepage
          "browser.newtabpage.enable" = false;
          "browser.startup.homepage" = "about:newtab";
          "browser.startup.page" = 3;
          "browser.toolbars.bookmarks.visibility" = "never";

          # UI customization
          "browser.uiCustomization.state" = readFile ./toolbar.json;

          # Gnome Theme
          "gnomeTheme.bookmarksToolbarUnderTabs" = true;
          "gnomeTheme.dragWindowHeaderbarButtons" = true;
          "gnomeTheme.symbolicTabIcons" = true;
        };
      };
    };
  };
}
