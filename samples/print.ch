some_jump:
	return

main:
	push 1
	push 2
	push 3
	over
	jump some_jump
	call print
	halt
