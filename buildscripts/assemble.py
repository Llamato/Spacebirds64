import helpers
import os
import sys

if __name__ == '__main__':
    helpers.createBuildDir()
    relativeFile = "main.asm"
    fileBasename = "main"
    if len(sys.argv) > 2:
        relativeFile = sys.argv[1]
        fileBasename = sys.argv[2]
        fileBasenameNoExtention = fileBasename.split('.')[0]
    elif len(sys.argv) > 1:
        relativeFile = sys.argv[1]
    print(helpers.syscmd(f'tmpx -i {relativeFile} -o {fileBasenameNoExtention}.prg'))
