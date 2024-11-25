import shutil
import os
import sys

def clean():
    try:
        shutil.rmtree("build")
        os.mkdir("build")
    except PermissionError:
        print("Error: Permission denied! Continueing...", file=sys.stderr)
    except FileExistsError:
        print("Error: File not found! Continueing...", file=sys.stderr)

if __name__ == "__main__":
    clean()
