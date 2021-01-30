#!python
from DevEnv.Support import *
import sys
import os

def main():
    theStudio = Studio()
    EnvDTE = theStudio.DTE()

    for i in range(1,len(sys.argv)):
        file = sys.argv[i]
        file = file.replace('/', '\\')
        if file.find(':') == -1:
            file = os.getcwd() + '\\' + file

        open_file(file, EnvDTE)

if __name__ == '__main__':
    main()
