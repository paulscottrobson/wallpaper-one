#
#	Convert test.bin to binaries\__image.h
#
import os

def convert(srcFile,hFile,m = 1):
	src = open(srcFile,"rb").read(-1)
	src = [str(ord(x)*m) for x in src]
	src = ",".join(src)
	open("binaries"+os.sep+hFile,"w").write(src)

convert("monitor.bin","__monitor_rom.h")
convert("rom9000.bin","__rom_9000.h",0)
