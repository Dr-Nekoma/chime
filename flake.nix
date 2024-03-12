{
  description = "Chime";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
          clang = "${pkgs.clang}/bin/clang";
          gnustepBaseDev = pkgs.gnustep.base.dev;
          gnustepBaseLib = pkgs.gnustep.base.lib;
          gnustepMake = pkgs.gnustep.make;
          gnustepLibObjc = pkgs.gnustep.libobjc;
        in
          {
            chime = pkgs.stdenv.mkDerivation {
              name = "chime";
              src = ./.;
              installPhase = ''
                mkdir -p $out/bin
                ${clang} -Wall -O2 -pthread -fPIC -Wunused-command-line-argument -lobjc -lgnustep-base -fobjc-runtime=gnustep-2.0 -I${gnustepBaseDev}/include -I${gnustepMake}/include -I${gnustepLibObjc}/include -L${gnustepLibObjc}/lib -L${gnustepBaseLib}/lib -I./Chime/Headers ./Chime/VM+Syscalls.m ./Chime/VM+Instructions.m ./Chime/VM.m ./Chime/Stack.m ./Chime/Utilities.m ./Chime/Parser.m ./Chime/Main.m -o $out/bin/chime'';
            };
          });

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          clang = "${pkgs.clang}/bin/clang";
          gnustepBaseDev = pkgs.gnustep.base.dev;
          gnustepBaseLib = pkgs.gnustep.base.lib;
          gnustepMake = pkgs.gnustep.make;
          gnustepLibObjc = pkgs.gnustep.libobjc;
          mktemp = "${pkgs.coreutils}/bin/mktemp";
        in
        {
          build = {
            type = "app";
            program = toString (pkgs.writeShellScript "execute-program" ''
              output=$(${mktemp})
              ${clang} -Wall -O2 -pthread -fPIC -Wunused-command-line-argument -lobjc -lgnustep-base -fobjc-runtime=gnustep-2.0 -I${gnustepBaseDev}/include -I${gnustepMake}/include -I${gnustepLibObjc}/include -L${gnustepLibObjc}/lib -L${gnustepBaseLib}/lib -I./Chime/Headers ./Chime/VM+Syscalls.m ./Chime/VM+Instructions.m ./Chime/VM.m ./Chime/Stack.m ./Chime/Utilities.m ./Chime/Parser.m ./Chime/Main.m -o $output && $output/chime
            '');
          };

          getCompileFlags = {
            type = "app";
            program = toString (pkgs.writeShellScript "execute-program" ''
              echo "-lobjc" > compile_flags.txt
              echo "-lgnustep-base" >> compile_flags.txt
              echo "-fobjc-runtime=gnustep-2.0" >> compile_flags.txt
              echo "-I${gnustepBaseDev}/include" >> compile_flags.txt
              echo "-I${gnustepMake}/include" >> compile_flags.txt
              echo "-I${gnustepLibObjc}/include" >> compile_flags.txt
              echo "-I${gnustepLibObjc}/include" >> compile_flags.txt
              echo "-L${gnustepBaseLib}/lib" >> compile_flags.txt
              echo "-I./Chime/Headers" >> compile_flags.txt
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
                  clang-tools
                  clang
                  just
                  gnustep.make
                  gnustep.base
                  gnustep.back
                  gnustep.stdenv
                  gnustep.libobjc
                ];
              })
            ];
          };
        });
      
    };
}
