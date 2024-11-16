import os
import sys

def syscmd(cmd):
    print(cmd)
    os.system(cmd)

filenames = os.listdir(".")
if len(filenames) == 0:
    print("No asm files found. Aborting...", file=sys.stderr)
    exit(1)

syscmd("c1541 -format asmdisk,01 d64 build/asmdisk.d64")
preprocess_path = "build/preprocess"

for filename in filenames:
    if filename.endswith(".asm"):
        syscmd(f'petcat -text -w2 -o build/{filename} {filename}')
        syscmd(f'c1541 -attach build/asmdisk.d64 -write build/{filename} {filename},s')
        if len(filename) > 16:
            print("Warning: file name too long", file=sys.stderr)
