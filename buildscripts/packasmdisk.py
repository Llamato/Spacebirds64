import os
import sys
import pathlib
from flattenasm import flattenIncludes

def syscmd(cmd):
    print(cmd)
    os.system(cmd)

def pack_code_disk(code_path, pack_path, img_name):
    filenames = os.listdir(code_path)
    if len(filenames) == 0:
        print("No asm files found. Aborting...", file=sys.stderr)
        exit(1)
    syscmd("c1541 -format asmdisk,01 d64 " + os.path.join(pack_path, img_name))
    for filename in filenames:
        if filename.endswith(".asm"):
            syscmd(f'petcat -text -w2 -o {os.path.join(pack_path, filename)} {os.path.join(code_path, filename)}')
            syscmd(f'c1541 -attach {os.path.join(pack_path, img_name)} -write {os.path.join(pack_path, filename)} {filename},s')
            if len(filename) > 16:
                print("Warning: file name too long", file=sys.stderr)

def copy_code(src, dest, exclude=[]):
    if not os.path.exists(dest):
        pathlib.Path.mkdir(dest)
    filenames = os.listdir(".")
    for filename in filenames:
        if filename.endswith(".asm") and filename not in exclude:
            src_file = open(os.path.join(src, filename))
            dest_file = open(os.path.join(dest, filename), "w", newline='\n')
            dest_file.writelines(src_file.readlines())
            src_file.close()
            dest_file.close()

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].endswith(".asm"):
        input_filepath = sys.argv[1]
        preprocessor_path = os.path.join("build", "pre")
        copy_code(".", preprocessor_path)
        output_filepath = os.path.join(preprocessor_path, f'flat{input_filepath}')
        output_file = open(output_filepath, "w", newline='\n')
        output_file.write(flattenIncludes(input_filepath))
        output_file.close()
        pack_code_disk(preprocessor_path, "build", "asmdisk.d64")
    else:
        pack_code_disk(".", "build", "asmdisk.d64")
