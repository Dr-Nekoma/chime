{
  description = "Chime";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { devenv, nixpkgs, self, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);       
    in
      {                 
        devShells = forAllSystems (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
            {
              default = devenv.lib.mkShell {
                inherit inputs pkgs;
                modules = [
                  ({ pkgs, lib, ... }: {
                    packages = with pkgs; [
                      clang-tools
                      clang
                      just
                      gnustep.make
                      gnustep.base
                      gnustep.back
                      gnustep.stdenv
                      gnustep.libobjc
                    ];})];
                };
            });
      };
}
