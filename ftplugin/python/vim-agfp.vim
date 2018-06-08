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
import countparentheses

vim.current.buffer.append("import AGFPparameters", 0)
vim.current.buffer.append("from AGFPparameters import recordparametertype", 0)
vim.current.buffer.append("bottom")
vim.current.buffer[-1] = "AGFPparameters.logfunctionparameters()"

vim.command("!cp ~/.vim/plugged/vim-agfp/ftplugin/python/parameters.py ./AGFPparameters.py")

for row, line in enumerate(vim.current.buffer):
	extra = line.lstrip()
	if extra.startswith("def ") and (row==0 or not vim.current.buffer[row-1].lstrip().startswith("@")):
		space = " " * (len(line) - len(extra))
		vim.current.buffer.append("", row)
		vim.current.buffer[row] = space + "@recordparametertype"


vim.command("w")
vim.command("!python %")

# del vim.current.buffer[-1]
vim.command("g/import AGFPparameters/d")
vim.command("g/from AGFPparameters import recordparametertype/d")
vim.command("g/@recordparametertype/d")
vim.command("g/AGFPparameters.logfunctionparameters/d")

parameterfile = open(".AGFPparameters.log", "r")
parameterinfo = parameterfile.readlines()
for parafunc in parameterinfo:
	if parafunc[-1] == ">":
		continue
	funcname = parafunc.split(">>")[0]
	argumentinfo = parafunc.split(">>")[1].split(";")[0:-1]
	for row, line in enumerate(vim.current.buffer):
		extra = line.lstrip()
		if extra.startswith("def ") and row < len(vim.current.buffer) - 1:
			endrow = -1
			startrow = row
			prev = (0, 0, None)
			while True:
				prev = countparentheses.count(vim.current.buffer[startrow], prev)
				if prev[0] != prev[1]:
					startrow += 1
				else:
					break
			if startrow < len(vim.current.buffer) - 3 and vim.current.buffer[startrow + 1].lstrip().startswith('"""'):
				endrow = startrow+1
				if '"""' in vim.current.buffer[startrow+1].lstrip()[4:]:
					endrow = startrow+1
				else:
					endrow = startrow+2
					while endrow < len(vim.current.buffer) - 1 and endrow - startrow < 100:
						if '"""' in vim.current.buffer[endrow]:
							break
						endrow += 1
				flag = False
				for i in range(startrow+1, endrow+1):
					if "@type" in vim.current.buffer[i]:
						flag = True
				if flag:
					continue

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
			# functiondefine = extra[4:]
			# for i in range(row + 1, startrow + 1):
			# 	functiondefine += vim.current.buffer[i].strip()
			# functiondefine = functiondefine[(functiondefine.find("(") + 1): (functiondefine.rfind(")"))]
			# parameterlist = functiondefine.split(",")
			# parameterlist = [p.strip() for p in parameterlist]
			# parameterlist = [p if "=" not in p else p[0:p.find("=")] for p in parameterlist]
			functiondefines = list()
			for i in range(row, startrow+1):
				functiondefines.append(vim.current.buffer[i].strip())
			parameterlist = countparentheses.getargument(functiondefines).split(",")
			space = " " * (len(line) - len(extra) + 4)
			if endrow == -1:
				vim.current.buffer.append(space + '"""', startrow + 1)
				vim.current.buffer.append(space + '"""', startrow + 2)
				for k, info in enumerate(argumentinfo):
					vim.current.buffer.append("", startrow + 2 + k)
					vim.current.buffer[startrow + 2 + k] = space + "@type " + \
						parameterlist[k].strip() + ": " + info.split(":")[1]
			else:
				oldcomment = list()
				if len(vim.current.buffer[startrow + 1].lstrip()[3:]) != 0:
					oldcomment.append(space + vim.current.buffer[startrow + 1].lstrip()[3:])
				for i in range(startrow + 2, endrow):
					oldcomment.append(vim.current.buffer[i])
				if not vim.current.buffer[endrow].lstrip().startswith('"""'):
					oldcomment.append(vim.current.buffer[endrow][0:-3])
				for j in range(endrow, startrow, -1):
					del vim.current.buffer[j]
				vim.current.buffer.append(space + '"""', startrow + 1)
				vim.current.buffer.append(space + '"""', startrow + 2)
				for k, info in enumerate(argumentinfo):
					vim.current.buffer.append("", startrow + 2 + k)
					vim.current.buffer[startrow + 2 + k] = space + "@type " + \
						parameterlist[k].strip() + ": " + info.split(":")[1]
				for k, line in enumerate(oldcomment):
					vim.current.buffer.append(line, startrow + 2 + len(argumentinfo) + k)
			break

vim.command("!rm AGFPparameters.py")
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
