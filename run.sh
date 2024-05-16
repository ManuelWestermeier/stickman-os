nasm -f bin index.asm -o stickman.bin
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=stickman.bin of=floppy.img conv=notrunc
qemu-system-x86_64 -fda floppy.img
