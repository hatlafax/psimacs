#!python
"""Access to the win32com.client.gencache generated type libraries of the MS Visual Studio.

        Usage:  import DevEnv.Support
                Env = DevEnv.Support.Studio()
"""

__version__ = '1.0'

import os, sys

from win32com.client import gencache
from win32com.client import Dispatch
from win32com.client import constants
from win32com.client import CastTo

def open_file(theFile, EnvDTE = None):
    if not EnvDTE:
        theStudio = Studio()
        EnvDTE = theStudio.DTE()
    if EnvDTE:
        try:
            theWindow = EnvDTE.OpenFile(constants.vsViewKindPrimary, theFile)
            theWindow = CastTo(theWindow, 'Window')
            theWindow.Visible = 1
        except:
            print ("could not open file!")

def import_file(theFile, EnvDTE = None):
    if not EnvDTE:
        theStudio = Studio()
        EnvDTE = theStudio.DTE()

    if EnvDTE:
        try:
            itemOperations = EnvDTE.ItemOperations
            if EnvDTE.SelectedItems.Count > 0:
                selItem = EnvDTE.SelectedItems.Item(1);

                #print (selItem.Name)
                #print (selItem.ProjectItem.FileNames(0))

                if selItem.Name == selItem.ProjectItem.FileNames(0):
                    #print ("AddExistingItem")
                    itemOperations.AddExistingItem(theFile)
                else:
                    #print ("AddFromFile")
                    selItem.ProjectItem.Collection.AddFromFile(theFile)
        except:
            pass

class Modules:
    def __init__(self):
        self.__VStudio = None
        try:
            self.__VStudio = gencache.EnsureDispatch('VisualStudio.DTE.12.0')
        except:
            print ("Exception occured: Visual Studio not available!")

    def VStudio(self):
        return self.__VStudio
       
class Studio:
    theModules = Modules()
    def __init__(self):
        self.__EnvDTE = None

        if self.theModules.VStudio():
            self.__EnvDTE = Dispatch("VisualStudio.DTE.12.0")
        
    def DTE(self):
        return self.__EnvDTE

def main():
    "Test of the Support module"

    theFile = os.path.join(sys.path[0], r'Test.txt')
   
    open_file(theFile)
  
if __name__ == '__main__':
    main()
