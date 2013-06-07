all:
	nasm -f bin boot.asm -o a.img

clean:
	rm -rf a.img
