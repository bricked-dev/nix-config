# File Structure

```tree
/
├── flake.nix # Input and output definitions
│
├── doc
│   └── src # Documentation
│
├── lib
│   └── <name>
│       └── lib.nix # Function definitions
│
├── packages
│   └── <name>
│       └── package.nix # Package definition
│
├── modules
│   └── <name>
│       ├── nixos.nix # NixOS module
│       ├── home.nix # Home Manager module
│       └── common.nix # Shared NixOS + Home Manager module
│
├── hosts # Per-host configurations
│   └── <name>
│       ├── nixos.nix # NixOS configuration
│       ├── home.nix # Home Manager configuration
│       ├── users.nix # NixOS + Home Manager users
│       ├── disko.nix # Disko filesystem configuration
│       └── hardware.nix # Generated hardware configuration
│
└── users # Per-user configurations
    └── <name>
        └── home.nix # Home Manager configuration
```
