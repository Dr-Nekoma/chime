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

        apps = forAllSystems (system:
          let
            pkgs = import nixpkgs { inherit system; };
            mktemp = "${pkgs.coreutils}/bin/mktemp";
            clang = "${pkgs.clang}/bin/clang";
            mustFlags = "-lobjc -lgnustep-base -fobjc-runtime=gnustep-2.0 -I${pkgs.gnustep.base.dev}/include -I${pkgs.gnustep.make}/include  -I${pkgs.gnustep.libobjc}/include";
            libFlags = " -L${pkgs.gnustep.base.lib}/lib  -L${pkgs.gnustep.libobjc}/lib";
            optionalFlags = "-Wall -O2 -pthread -fPIC -fobjc-exceptions -fexceptions -Wunused-command-line-argument";
            compileFlags = mustFlags + " " + libFlags + " " + optionalFlags;
            src = ./src;
          in
          {          
            flags = {
              type = "app";
              program = toString (pkgs.writeShellScript "flags-program" ''
                echo ${compileFlags} > compile_flags.txt 
              '');           
            };

            execute = {
              type = "app";
              program = toString (pkgs.writeShellScript "execute-program" ''
                output=$(${mktemp})
                ${clang} ${compileFlags} -o $output ${src}/main.m && $output
             '');
            };       
          });        
        
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
                      # Headers not found
                      clang-tools
                      clang
                      # LSP std
                      # gnustep.gui
                      # gnustep.gorm
                      # gnustep.system_preferences
                      # gnustep.projectcenter
                      # gnustep.gworkspace
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
