compiler := "clang"
objcFlags := "-lobjc -lgnustep-base -fobjc-runtime=gnustep-2.0"
nixFlags := "-I/nix/store/8ck8lj95k31vhxd54b4jpxizmbiq9gi6-gnustep-base-1.28.0-dev/include -I/nix/store/4dgizq5m4axp6cr9sb6bqwlcw4csw06l-gnustep-make-2.9.1/include -I/nix/store/9pvga8qxb9padl8k5jdzdrbrmy3aa016-libobjc2-2.1/include -L/nix/store/9m9w7nvfj6fdqjdj732dc5l28g8nzxmk-gnustep-base-1.28.0-lib/lib -L/nix/store/9pvga8qxb9padl8k5jdzdrbrmy3aa016-libobjc2-2.1/lib"
optionalFlags := "-Wall -O2 -pthread -fPIC -Wunused-command-line-argument"
headers := "-I./Chime/Headers"
sourceFiles := "./Chime/VM+Instructions.m ./Chime/VM.m ./Chime/Stack.m ./Chime/Utilities.m ./Chime/Parser.m ./Chime/Main.m"
executableName := "chime"

build:
	{{compiler}} {{optionalFlags}} {{objcFlags}} {{nixFlags}} {{headers}} {{sourceFiles}} -o {{executableName}}

format:
	clang-format -i $(find ./ -type f \( -iname \*.m -o -iname \*.h \))
