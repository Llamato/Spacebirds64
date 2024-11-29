import sys
import os
from helpers import syscmd

def pack_assets(assets_path, disk_img_path="build/prgdisk.d64"):
    for asset_name in os.listdir(assets_path):
        asset_path = os.path.join(assets_path, asset_name)
        asset_name = asset_name.lower()
        syscmd(f'c1541 -attach {disk_img_path} -write {asset_path} {asset_name}')

def pack_prgdisk(main_prg="build/main.prg", assets_path="assets", disk_name="prgdisk"):
    main_name = ".".join(os.path.basename(main_prg).split(".")[:-1])
    main_name = main_name.lower()
    disk_name = disk_name.lower()
    syscmd(f'c1541 -format {disk_name},0 d64 build/prgdisk.d64 -attach build/prgdisk.d64 -write {main_prg} {main_name}')
    pack_assets(assets_path)

if __name__ == "__main__":
    argc = len(sys.argv) -1
    if argc == 0:
        pack_prgdisk()
    elif argc == 1:
        pack_prgdisk(disk_name=sys.argv[1])
    elif argc == 2:
        pack_prgdisk(disk_name=sys.argv[1], main_prg=sys.argv[2])
    elif argc == 3:
        pack_prgdisk(disk_name=sys.argv[1], main_prg=sys.argv[2], assets_path=sys.argv[3])
    else:
        print("Wrong number of arguments. Truncating...", file=sys.stderr)
        pack_prgdisk(disk_name=sys.argv[1], main_prg=sys.argv[2], assets_path=sys.argv[3])
