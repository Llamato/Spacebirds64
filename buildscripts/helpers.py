import subprocess
import os
def syscmd(cmd):
    print(cmd)
    argv = cmd.split()
    result = subprocess.run(argv, stdout=subprocess.PIPE)
    try:
         return result.stdout.decode("utf-8")
    except UnicodeDecodeError as e:
         if cmd.startswith("c1541") and (cmd.find('-write') != -1 or cmd.find('-read') != -1):
            return ''
         else:
             raise e
def createBuildDir():
     try:
        os.mkdir("build")
     except FileExistsError as e:
          pass
