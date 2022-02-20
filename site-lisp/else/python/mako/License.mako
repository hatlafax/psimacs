##-- Test.mako ----------------------------------------------------------------
##
##      This template describes just shows a very simple Mako template example.
##
##      That the content is just a json VSCode configruation file is completely
##      artificial and does not has any deeper reasoning.
##
##-----------------------------------------------------------------------------
{
    //
    // key1's value is ${key1}
    // key2's value is ${key2}
    // key3's values are
% for entry in key3:
    //          ${entry}
% endfor
    //
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Python: Attach using Process Id",
            "type": "python",
            "request": "attach",
            "processId": "<%text>$</%text>{command:pickProcess}",
            "justMyCode": false
        },
        {
            "name": "Python: Attach using remote program",
            "type": "python",
            "request": "attach",
            "connect": {
                "host": "localhost",
                "port": 5678
            },
            "justMyCode": false
        },
        {
            "name": "Python: Launch current file",
            "type": "python",
            "request": "launch",
            "program": "<%text>$</%text>{file}",
            "console": "integratedTerminal",
            "justMyCode": false
        }
    ]
}
