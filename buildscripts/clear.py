import shutil
import os
import sys

def clean():
    try:
        if os.path.exists("build"):
            shutil.rmtree("build")
        os.mkdir("build")
    except PermissionError:
        print("Error: Permission denied! Continuing...", file=sys.stderr)
    except FileExistsError:
        print("Error: File not found! Continuing...", file=sys.stderr)

if __name__ == "__main__":
    clean()
