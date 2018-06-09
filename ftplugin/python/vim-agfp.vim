" --------------------------------
" Add our plugin to the path
" --------------------------------
python3 import sys
python3 import vim
python3 sys.path.append(vim.eval('expand("<sfile>:h")'))

" --------------------------------
"  Function(s)
" --------------------------------
function! s:TestUtil() abort
python3 << endOfPython

import vim
import vimbufferutil

abc = vimbufferutil.AddBufferContent()

abc.removeandwait(1)
abc.addandwait("hello from line2", 2)
abc.removeandwait(3)

abc.conduct(vim.current.buffer)

endOfPython
endfunction


function! s:AddRecordParameterWrapper() abort
python3 << endOfPython

import vim
import countparentheses
import vimbufferutil
import agfp

abc = vimbufferutil.AddBufferContent()

vim.current.buffer.append("import AGFPparameters", 0)
vim.current.buffer.append("from AGFPparameters import recordparametertype", 0)
vim.current.buffer.append("bottom")
vim.current.buffer[-1] = "AGFPparameters.logfunctionparameters()"

path = vim.eval("s:path")
flag_return_type = vim.eval("g:agfp_display_return_type")

vim.command("!cp {}/parameters.py ./AGFPparameters.py".format(path))

for row, line in enumerate(vim.current.buffer):
	extra = line.lstrip()
	if extra.startswith("def ") and (row==0 or not vim.current.buffer[row-1].lstrip().startswith("@")):
		space = " " * (len(line) - len(extra))
		vim.current.buffer.append("", row)
		vim.current.buffer[row] = space + "@recordparametertype"

vim.command("w")
vim.command("!python %")

vim.command("g/import AGFPparameters/d")
vim.command("g/from AGFPparameters import recordparametertype/d")
vim.command("g/@recordparametertype/d")
vim.command("g/AGFPparameters.logfunctionparameters/d")

agfp.adddocstring_paramtype(vim.current.buffer, flag_return_type)

vim.command("w")
vim.command('call delete("AGFPparameters.py")')
# vim.command('call delete(".AGFPparameters.log")')

endOfPython
endfunction


function! s:RecordCurrentFunction() abort
python3 << endOfPython

import vim
import countparentheses
import agfp

currentindent = 999

for row in range(vim.current.window.cursor[0]-1, -1, -1):
	line = vim.current.buffer[row]
	extra = line.lstrip()
	if len(extra) == 0:
		continue
	elif (len(line) - len(extra)) // 4 >= currentindent:
		continue
	elif extra.startswith("def ") and (row==0 or not vim.current.buffer[row-1].lstrip().startswith("@")):
		space = " " * (len(line) - len(extra))
		vim.current.buffer.append("", row)
		vim.current.buffer[row] = space + "@recordparametertype"
		break
	else:
		currentindent = (len(line) - len(extra)) // 4


vim.current.buffer.append("import AGFPparameters", 0)
vim.current.buffer.append("from AGFPparameters import recordparametertype", 0)
vim.current.buffer.append("bottom")
vim.current.buffer[-1] = "AGFPparameters.logfunctionparameters()"

path = vim.eval("s:path")
flag_return_type = vim.eval("g:agfp_display_return_type")

vim.command("!cp {}/parameters.py ./AGFPparameters.py".format(path))

vim.command("w")
vim.command("!python %")

vim.command("g/import AGFPparameters/d")
vim.command("g/from AGFPparameters import recordparametertype/d")
vim.command("g/@recordparametertype/d")
vim.command("g/AGFPparameters.logfunctionparameters/d")

agfp.adddocstring_paramtype(vim.current.buffer, flag_return_type)

vim.command("w")
vim.command('call delete("AGFPparameters.py")')
# vim.command('call delete(".AGFPparameters.log")')

endOfPython
endfunction

" --------------------------------
"  Expose our commands to the user
" --------------------------------

let s:path = expand('<sfile>:p:h')

if !exists("g:agfp_display_return_type")
	let g:agfp_display_return_type = 1
endif

command! RecordParameter :call s:AddRecordParameterWrapper()
command! RecordCurrentFunction :call s:RecordCurrentFunction()
command! TestUtil :call s:TestUtil()
