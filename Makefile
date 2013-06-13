boot:
	nasm -f bin boot.asm -o a.img

installboot:
	dd if=a.img of=floppy.img bs=512 conv=notrunc

floppy:
	mkfs.vfat -C "floppy.img" 1440

test:
	bochs

mount:
	sudo mount -o loop,uid=$UID -t vfat floppy.img /mnt/floppy

umount:
	sudo umount /mnt/floppy

clean:
	rm -rf a.img
	rm -rf floppy.img
