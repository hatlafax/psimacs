##-- UnitTest.mako ------------------------------------------------------------
##
##      A template for a standard python unittest file.
##
##-----------------------------------------------------------------------------
<%include file="Licenses/License${copyright_license}.mako"/>
##
<%text>##</%text>
<%text>##</%text>
<%text>##</%text>
"""Unit test for module ${python_module}.
[text]...
"""

import unittest

[import_stmt]...

from ${python_module} import ${python_class}


class ${python_class}Test(unittest.TestCase):
    """Unit tests for class ${python_class} from module ${python_module}.
    [text]...
    """
    [classdef]...
    __verbose: bool = False
    [init_def]

    def setUp(self) -> None:
        [document_string]
        if self.__verbose: print("running setUp of ${python_class}Test ...")
        [statement]...

    def tearDown(self) -> None:
        [document_string]
        if self.__verbose: print("running tearDown of ${python_class}Test ...")
        [statement]...

    % if python_function is None:
    def test_{test_function_name}(self) -> None:
        [document_string]
        if self.__verbose: print("running unit test {test_function_name} ...")
        [statement]...
    
        self.addCleanup(self.clean_test_{test_function_name}, [parameter]...)
    
    def clean_test_{test_function_name}(self, [defparameter]...) -> None:
        [function_document_string]
        if self.__verbose: print("running clean_test_{test_function_name} added by unit test {test_function_name} ...")
        [statement]...
    % else:
        % for test_function_name in python_function:
    def test_${test_function_name}(self) -> None:
        [document_string]
        if self.__verbose: print("running unit test ${test_function_name} ...")
        [statement]...
    
        self.addCleanup(self.clean_test_${test_function_name}, [parameter]...)
    
    def clean_test_${test_function_name}(self, [defparameter]...) -> None:
        [function_document_string]
        if self.__verbose: print("running clean_test_${test_function_name} added by unit test %{test_function_name} ...")
        [statement]...

        % endfor
    % endif

    [unittest_funcdef]...
    [class_funcdef]...

[statement]...

if __name__ == '__main__':
    unittest.main()
