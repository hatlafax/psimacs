#
# Distributed under the MIT License.
#
# Copyright (c) 2022 Johannes Brunen <hatlafax@gmx.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

import os, sys, copy, re
import pickle
import argparse
import json

from mako.template import Template
from mako.lookup import TemplateLookup
from mako.exceptions import RichTraceback


def serve_template(template, lookup, **kwargs):
    """Get template and render template with data.

    :param str template: The name of the template file.
    :param dict lookup: The data structure provided by the mako TemplateLookup function.
    :param kwargs: Data to be evaluated by the template.

    :return: the result of the template evaluation.
    :rtype: str
    """
    result = "Invalid"
    try:
        tpl = lookup.get_template(template)
        result = tpl.render(**kwargs)
    except:
        traceback = RichTraceback()
        for (filename, lineno, function, line) in traceback.traceback:
            print("File %s, line %s, in %s" % (filename, lineno, function))
            print(line, "\n")
        print("%s: %s" % (str(traceback.error.__class__.__name__), traceback.error))
        exit(1)
    #exit(1)
    return result


def generate_files(lookup, container):
    """Generate the output files requested in the container list.

    :param dict lookup: The data structure provided by the mako TemplateLookup function.
    :param list container: List of tuples of (template, data, file, encoding)

    whith:
    :param str template: The mako template name.
    :param dict data: The data to be evaluated by the template.
    :param str file: The filename of the output file. If None the result is printed to the console.
    :param str encoding: The encoding to be used for the result if writing to file.
    """

    for console, offset, template, data, out_file, enc in container:
        p, f = os.path.split(out_file)
        if not os.path.exists(p):
            os.makedirs(p)

        #
        # generate template code output...
        #
        #       On default all parsed template constructs and output streams
        #       are handled by mako as Python 3 str objects, i.e. utf-8.
        #       All our input_encoding to mako is utf-8.
        #
        #       See: https://docs.makotemplates.org/en/latest/unicode.html
        #
        result = serve_template(template, lookup, **data)

        if offset > 0:
            lines = result.split("\n")
            lines = [ " " * offset + line for line in lines ]
            result = '\n'.join(lines)

        if console:
            print(result)
        else:
            with open(out_file, 'w', encoding=enc) as out:
                out.write(result)


def Generate(cache_dir, template_dirs, python_module = False, pickle_file = None, data = None):
    #
    # Three types of input are supported:
    #   1. data is directly given
    #   2. python_module is a valid python module; data is imported from that module
    #   3. pickle_file is a pickled file; data is unpickled from that file
    #
    data_copy = None

    if data:
        data_copy = copy.deepcopy(data)

    elif python_module:
            (path, file) = os.path.split(python_module)

            mod = os.path.splitext(file)
            module_name = mod[0]

            __import__(module_name)
            ContextProvider = sys.modules[module_name]

            data_copy = ContextProvider.context

    elif pickle_file:
            if pickle_file:
                with open(pickle_file, 'rb') as fp:
                    data_copy = pickle.load(fp)
    else:
        return;


    #
    # Determine target, and environment
    #
    tpl_dirs = []

    for dir in template_dirs:
        if os.path.exists(dir):
            for root, dirs, files in os.walk(dir):
                tpl_dirs.append(root)


    lookup = TemplateLookup(
                directories = tpl_dirs,
                module_directory = cache_dir,
                preprocessor=[lambda x: x.replace("\r\n", "\n")]    # mako open template files in binary mode,
            )                                                  # thuse we get the "\r\n" line endings on
                                                               # the Windows patform. This problem shows
                                                               # up with Python >= 3
    #
    # Each container list entry specifies one output file. A tuple entry consists of: template, tpl_data, out_file, encoding
    #   1. template : the mako template to be used
    #   2. tpl_data : a dictionary serving as mako template input
    #   3. out_file : and the name of the file to be generated from 1. and 2.
    #   4. encoding : the encoding to be used for the file generation process
    #
    container = []

    try:
        instances = data_copy['instances']

        for instance in instances:
            console  = instance['console']
            out_file = instance['output_file']
            offset   = instance['offset_spaces']
            encoding = instance['encoding']
            template = instance['template_file']
            data     = instance['template_data']

            container.append( (console, offset, template, data, out_file, encoding) )

    except:
        print(f"Input data {data_copy} are invalid.")
        exit(1)

    print(container)

    generate_files(lookup, container)


def integrity_check(args):
    if args.cache_dir:
        if args.verbose:
            print(f"Cache directory is {args.cache_dir}.")

    if args.template_dirs:
        expr = re.split(r',\s*|\s+', args.template_dirs)
        args.template_dirs = [ t.strip() for t in expr ]

        not_found  = False
        for d in args.template_dirs:
            if not os.path.exists(d):
                print(f"Template directory {d} does not exists.")
                not_found = True
        if not_found:
            exit(1)

        if args.verbose:
            if len(args.template_dirs) == 1:
                print(f"Template directory is {args.template_dirs}.")
            else:
                print(f"Template directories are {args.template_dirs}.")

    if args.json:
        try:
            args.json = json.loads(args.json)
        except:
            print(f"Invalid JSON string {args.json} given.")
            exit(1)
        if args.verbose:
            print(f"Parsed JSON file is {args.json}.")

    if args.module:
        if not os.path.exists(args.module):
            print(f"Python module file {args.module} does not exist.")
            exit(1)
        if args.verbose:
            print(f"Python module file is {args.module}.")

    if args.pickle:
        if not os.path.exists(args.pickle):
            print(f"Python pickle file {args.pickle} does not exist.")
            exit(1)
        if args.verbose:
            print(f"Python pickle file is {args.pickle}.")

    if not (args.json or args.module or args.pickle):
        print("No valid input given. Can't do any sensible work :-(")
        exit(1)

    if args.verbose:
        if args.json:
            print(f"Generator works with provided JSON data {args.json}.")
        elif args.module:
            print(f"Generator works with provided Python module {args.module}.")
        elif args.pickle:
            print(f"Generator works with provided Python pickle file {args.pickle}.")



if  __name__=='__main__':
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description = "Generates text by evaluation of Mako templates and associated data.",
        epilog = """The associated data are provided as a command line string argument and are expected
to conform to a valid JSON format. Each template does have its own list entry in the
JSON file.

The JSON data must conform to the following structure. The key fields 'console', 'output_file',
'offset_spaces', 'encoding', 'template_file' and 'template_data' are mandatory. The valid structure of the
'template_data' value depends solely on the corresponding 'template_file'.

    {
        "instances": [
            {
                "console": true,
                "output_file": "path",
                "offset_spaces": number,
                "encoding": "utf-8",
                "template_file": "filename",
                "template_data": {
                    "key1": "value1",
                    "key2": "value2",
                    "key3": [ "v1", "v2", "v3", "v4" ]
                     ...
                }
            }
        ]
    }

If the 'console' key true, the 'output_file' entry is ignored and the result of the template
evaluation is directly printed to the console.

Key 'offset_spaces' defines how many extra spaces are prefixed to each resulting output text line.""")
    parser.add_argument("-c", "--cache-dir",     help="The caching directory for preprocced template files.", default=os.getcwd())
    parser.add_argument("-t", "--template-dirs", help="The caching directory for preprocced template files.", default=os.getcwd())
    parser.add_argument("-m", "--module",        help="A python module file providing the data instead of a JSON string argument.", default=None)
    parser.add_argument("-p", "--pickle",        help="A python pickle file providing the data instead of a JSON string argument.", default=None)
    parser.add_argument("-v", "--verbose",       help="Verbose output.", action="store_true")
    parser.add_argument("json", nargs='?',       help="The json string argument governs the template evaluation process.", default=None)

    args = parser.parse_args()

    integrity_check(args)

    Generate(args.cache_dir, args.template_dirs, args.module, args.pickle, args.json)

#
# c:\utils\Python399\python.exe MakoTemplateEval.py -v -c .\Cache -t ".\templates .\old,.\new"  -p pickle.pkl -m test.py "{\"id\":\"abc123\", \"name\":\"Bob\"}"
# c:\utils\Python399\python.exe MakoTemplateEval.py -v -c ..\..\session\mako-cache -t ..\else\python\mako  "{\"id\":\"abc123\", \"name\":\"Bob\"}"
# c:\utils\Python399\python.exe MakoTemplateEval.py -v -c ..\..\session\mako-cache -t ..\else\python\mako "{ \"instances\": [ { \"console\": true, \"output_file\": \"N/A\", \"offset_spaces\": 4, \"encoding\": \"utf-8\", \"template_file\": \"Test.mako\", \"template_data\": { \"key1\": \"value1\", \"key2\": \"value2\", \"key3\": [ \"v1\", \"v2\", \"v3\", \"v4\" ]  } } ] }"
#
