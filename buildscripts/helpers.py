import subprocess
def syscmd(cmd):
    print(cmd)
    argv = cmd.split()
    result = subprocess.run(argv, stdout=subprocess.PIPE)
    return result.stdout.decode("utf-8")
