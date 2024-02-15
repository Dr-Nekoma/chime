build:
	nix build .#chime

run code dialect:
	nix run .#chime {{code}} {{dialect}}

format:
	clang-format -i $(find ./ -type f \( -iname \*.m -o -iname \*.h \))
