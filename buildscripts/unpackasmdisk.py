import sys
import os
import re
from packasmdisk import syscmd

def unpack_file(disk_img_path, src_filename, dest_path=None):
    if dest_path == None:
        dest_path = src_filename
    syscmd(f'c1541 -attach {disk_img_path} -read {src_filename} {dest_path}')

def unpack_disk(disk_img_path, dest_path=None):
    if dest_path == None:
        dest_path = "."
    working_directory = os.getcwd()
    os.chdir(dest_path)
    syscmd(f'c1541 -attach {os.path.join(working_directory, disk_img_path)} -extract')
    os.chdir(working_directory)

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
                src_file = os.path.join(preprocess_path, filename)
                dest_file = os.path.join(unpack_path, filename)
                if filetype == "seq":
                    petscii_to_ascii(src_file, dest_file)
                elif filetype == "prg":
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
