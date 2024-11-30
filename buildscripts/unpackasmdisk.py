import sys
import os
import re
from helpers import syscmd

class cbmfile:
    def __init__(self, size, name, type):
        self.size = size
        self.name = name
        self.type = type

def list_disk(img_path):
    files = []
    disk_dir = syscmd(f'c1541 -attach {img_path} -list')
    for dir_line in disk_dir.split('\n'):
        dir_entry = dir_line.split()
        if len(dir_entry) != 3:
            continue
        filesize = dir_entry[0]
        filenamestart = dir_line.find('"')
        if filenamestart == -1:
            continue
        filenamestart += 1
        filenameend = dir_line.find('"', filenamestart)
        if filenameend == -1:
            continue
        filenameend -= 1
        filename = dir_line[filenamestart : filenamestart + filenameend - filenamestart +1]
        if len(filename) == 0:
            continue
        filetype = dir_entry[2]
        files.append(cbmfile(filesize, filename, filetype))
    return files

def unpack_file(disk_img_path, src_file, dest_path=None):
    if dest_path == None:
        dest_path = src_file
    if src_file is cbmfile and src_file.type == "seq":
        syscmd(f'c1541 -attach {disk_img_path} -read {src_file.name},s {dest_path}')
    elif src_file is cbmfile:
        syscmd(f'c1541 -attach {disk_img_path} -read {src_file.name} {dest_path}')
    elif src_file is str:
        files_on_disk = list_disk(disk_img_path)
        

def unpack_disk(disk_img_path, dest_path=None):
    if dest_path == None:
        dest_path = "."
    for file in list_disk(disk_img_path):
        unpack_file(disk_img_path, file, os.path.join(dest_path, file.name))

def petscii_to_ascii(petscii_file, ascii_file):
    syscmd(f'petcat -text -o {ascii_file} {petscii_file}')

def tmp_to_ascii(tmp_file, ascii_file):
    syscmd(f'tmpview -i {tmp_file} -o {ascii_file}')

if __name__ == "__main__":
    if len(sys.argv) == 4:
        img_path = sys.argv[1]
        unpack_path = sys.argv[2]
        preprocess_path = sys.argv[3]
        if (not os.path.exists(unpack_path) and not os.path.isdir(unpack_path)):
            os.makedirs(unpack_path)
        if (not os.path.exists(preprocess_path) and not os.path.isdir(preprocess_path)):
            os.makedirs(preprocess_path)
        if os.path.isdir(preprocess_path):
            unpack_disk(img_path, preprocess_path)
        for file in list_disk(img_path):
            src_file = os.path.join(preprocess_path, file.name)
            dest_file = os.path.join(unpack_path, file.name)
            if file.type == "seq":
                petscii_to_ascii(src_file, dest_file)
            elif file.type == "prg":
                tmp_to_ascii(src_file, dest_file)
        else:
            print("Error: Wrong number of arguments for file extraction", file=sys.stderr)
    elif len(sys.argv) == 5:
        img_path = sys.argv[1]
        unpack_filename = sys.argv[2]
        unpack_destination_filename = sys.argv[3]
        conversion_destination_filename = sys.argv[4]
        unpack_file(img_path, unpack_filename, unpack_destination_filename)
        petscii_to_ascii(unpack_destination_filename, conversion_destination_filename)
    else:
        print("Error: Wrong number of arguments", file=sys.stderr)
