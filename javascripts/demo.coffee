autocomplete_plugin = ace.edit 'autocomplete'
autocomplete_plugin.setTheme 'ace/theme/dawnjs'
autocomplete_plugin.getSession().setMode 'ace/mode/javascript'

js2py_plugin = ace.edit 'transpiler-js2py'
js2py_plugin.setTheme 'ace/theme/dawnjs'
js2py_plugin.getSession().setMode 'ace/mode/javascript'

js2py_result_plugin = ace.edit 'transpiler-js2py-result'
js2py_result_plugin.setTheme 'ace/theme/dawnjs'
js2py_result_plugin.getSession().setMode 'ace/mode/python'

py2js_plugin = ace.edit 'transpiler-py2js'
py2js_plugin.setTheme 'ace/theme/dawnjs'
py2js_plugin.getSession().setMode 'ace/mode/javascript'

py2js_result_plugin = ace.edit 'transpiler-py2js-result'
py2js_result_plugin.setTheme 'ace/theme/dawnjs'
py2js_result_plugin.getSession().setMode 'ace/mode/javascript'

document.getElementById('autocomplete-run').addEventListener 'click', ->
    eval autocomplete_plugin.getValue()

document.getElementById('js2py-compile').addEventListener 'click', ->
    eval js2py_plugin.getValue()
    js2py_result_plugin.setValue(window.compile_js2py())

document.getElementById('py2js-compile').addEventListener 'click', ->
    eval py2js_plugin.getValue()
    py2js_result_plugin.setValue(window.compile_py2js())

eval autocomplete_plugin.getValue()

editor = ace.edit 'editor'
editor.setTheme 'ace/theme/dawnjs'
editor.getSession().setMode 'ace/mode/javascript'

focused = 0
editor.on 'focus', ->
    focused = 1
editor.on 'blur', ->
    focused = 0

tip = document.querySelector('#tip')
editor_cursor = document.querySelector('#editor .ace_cursor')
document.body.addEventListener 'keyup', (e) ->
    if not focused
        return false

    cursor_left = parseInt editor_cursor.style.left
    cursor_top = parseInt editor_cursor.style.top

    cursor_pos = editor.getCursorPosition()
    all_lines = editor.getSession().getDocument().getAllLines()
    offset = 0
    for line, i in all_lines
        if i == cursor_pos.row
            break

        offset += (line.length + 1)

    data =
        script: editor.getValue()
        cursor_pos: offset + cursor_pos.column

    if window.parseFlow
        ret = window.parseFlow data.script, data.cursor_pos
        tip.innerHTML = ''
        if ret
            for i in ret
                tip.innerHTML += i + '<br/>'

            tip.style.left = cursor_left + 90 + 'px'
            tip.style.top = cursor_top + 70 + 'px'
            tip.style.opacity = 1.0
        else
            tip.style.left = 0
            tip.style.top = 0
            tip.style.opacity = 0

