{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        python = pkgs.python3.withPackages (packages:  
          with packages; [
            boto3
            botocore
          ]
        );

      in {
        devShells.default = pkgs.mkShell {
          packages = [
            python
            pkgs.go
            
            pkgs.ansible
            pkgs.opentofu
            pkgs.kubectl
          ];

          shellHook = ''
            # Load env 
            if [ -f .env ]; then
              export $(cat .env | xargs)
            fi

            alias vi="nvim"
            alias vim="nvim"
            alias ls="lsd"
            alias k="kubectl"

            export STARSHIP_CONFIG=~/.config/starship.toml
            eval "$(starship init bash)"
          '';
        };
      }
    );
}
