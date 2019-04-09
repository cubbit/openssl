from subprocess import PIPE, Popen
from sys import argv, exit
import os, re

commands = []
env = os.environ

cwd = argv[1]
commands.extend(argv[2:])

proc = Popen(" ".join(commands)+" || exit $?", shell=True, env=env, cwd=cwd)
proc.communicate()
exit(proc.returncode)
