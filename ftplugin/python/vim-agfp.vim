" --------------------------------
" Add our plugin to the path
" --------------------------------
python3 import sys
python3 import vim
python3 sys.path.append(vim.eval('expand("<sfile>:h")'))

" --------------------------------
"  Function(s)
" --------------------------------
function! s:AddRecordParameterWrapper() abort
python3 << endOfPython

import vim

vim.current.buffer.append("import AGFPparameters", 0)
vim.current.buffer.append("from AGFPparameters import recordparametertype", 0)
vim.current.buffer.append("bottom")
vim.current.buffer[-1] = "AGFPparameters.logfunctionparameters()"

vim.command("!cp ~/.vim/plugged/vim-agfp/ftplugin/python/AGFPparameters.py .")

for row, line in enumerate(vim.current.buffer):
	extra = line.lstrip()
	if extra.startswith("def ") and (row==0 or not vim.current.buffer[row-1].lstrip().startswith("@")):
		space = " " * (len(line) - len(extra))
		vim.current.buffer.append("", row)
		vim.current.buffer[row] = space + "@recordparametertype"


vim.command("w")
vim.command("!python %")

del vim.current.buffer[-1]
vim.command("g/import AGFPparameters/d")
vim.command("g/from AGFPparameters import recordparametertype/d")
vim.command("g/@recordparametertype/d")

parameterfile = open(".AGFPparameters.log", "r")
parameterinfo = parameterfile.readlines()
for parafunc in parameterinfo:
	if parafunc[-1] == ">":
		continue
	funcname = parafunc.split(">>")[0]
	argumentinfo = parafunc.split(">>")[1].split(";")[0:-1]
	for row, line in enumerate(vim.current.buffer):
		extra = line.lstrip()
		if extra.startswith("def ") and\
		        row < len(vim.current.buffer) - 1 and\
		        not vim.current.buffer[row + 1].lstrip().startswith('"""'):
				indentlevel = (len(line) - len(extra)) // 4
				currentname = extra[4:extra.find("(")]
				for i in range(row - 1, -1, -1):
					if indentlevel == 0:
						break
					cline = vim.current.buffer[i]
					if len(cline) == 0:
						continue
					cextra = cline.lstrip()
					cindentlevel = (len(cline) - len(cextra)) // 4
					if cindentlevel == indentlevel - 1:
						if cextra.startswith("def "):
							addname = cextra[4: cextra.find("(")]
							currentname = addname + ".<locals>." + currentname
						elif cextra.startswith("class "):
							addname = cextra[6: cextra.find("(")]
							currentname = addname + "." + currentname
						indentlevel -= 1
				# print(currentname, funcname)
				# print(len(currentname), len(funcname))
				if currentname != funcname:
					continue
				# print(currentname, funcname)
				functiondefine = extra[4:-1]
				functiondefine = functiondefine[(functiondefine.find(
				    "(") + 1): (functiondefine.rfind(")"))]
				parameterlist = functiondefine.split(",")
				space = " " * (len(line) - len(extra) + 4)
				vim.current.buffer.append(space + '"""', row + 1)
				vim.current.buffer.append(space + '"""', row + 2)
				for k, info in enumerate(argumentinfo):
					vim.current.buffer.append("", row + 2 + k)
					vim.current.buffer[row + 2 + k] = space + "@type " + \
					    parameterlist[k].strip() + ": " + info.split(":")[1]
				break

# vim.command("!rm AGFPparameters.py")
vim.command("!rm .AGFPparameters.log")

endOfPython
endfunction

" --------------------------------
"  Expose our commands to the user
" --------------------------------

if g:autoformatpython_enabled == 1
	inoremap <silent> <buffer> <expr> <Cr> (getline('.') != '' && col(".") >= col("$")) ? '<Esc>:FormatCurrentLine<Cr>a<Cr>' : '<Cr>'
	nnoremap <silent> <buffer> <cr> :FormatCurrentLine<cr><cr>
endif

function! s:ChangeFormatCurrentLineMode()
	if g:autoformatpythonstate_mode == 1
		try
			iunmap <buffer> <Cr>
			nunmap <buffer> <Cr>
		catch
		endtry
		echom "Change Mode: Disable"
		let g:autoformatpythonstate_mode = 0
	else
		echom "Change Mode: Enable"
		inoremap <silent> <buffer> <expr> <Cr> (getline('.') != '' && col(".") >= col("$")) ? '<Esc>:FormatCurrentLine<Cr>a<Cr>' : '<Cr>'
		nnoremap <silent> <buffer> <cr> :FormatCurrentLine<cr><cr>
		let g:autoformatpythonstate_mode = 1
	endif
endfunction

command! AddRecordParameterWrapper :call s:AddRecordParameterWrapper()
