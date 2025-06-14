call plug#begin()
Plug 'justinmk/vim-sneak'
if has("nvim")
	Plug 'neovim/nvim-lspconfig'
endif
call plug#end()

colorscheme quark
if has("nvim")
	set shada="NONE"
	set laststatus=3
else
	set viminfo=
endif
set clipboard=unnamedplus
set completeopt=noinsert,menuone
set nomodeline
set notermguicolors
set nowrap
set nu rnu
set path=**
set shm+=I
set title
set titlestring=vi\ %f

hi StatusLineModified ctermfg=3 ctermbg=8
set statusline=
set statusline+=\ %f " file
set statusline+=%#StatusLineModified#%{getbufinfo('%')[0].changed?'\ [+]':''}%#StatusLine# " modified
set statusline+=%= " sep
set statusline+=%{&filetype}
set statusline+=\ \|\ %3p%% " percent thru file
set statusline+=\ \|\ %-8(%l:%c%) "line:col

let mapleader = ","

func s:CommandAbbrev(from, to)
	execute "cabbrev " . a:from . " <c-r>=getcmdpos() == 1 && getcmdtype() == ':' ? '" . a:to . "' : '" . a:from . "'<cr>"
endfunc
call s:CommandAbbrev("f", "find")
call s:CommandAbbrev("ft", "Ft")
call s:CommandAbbrev("rg", "GrepCw")
call s:CommandAbbrev("man", "Man")
call s:CommandAbbrev("te", "Te")

command! -bar -nargs=1 GrepCw execute "silent grep! " <q-args> | cw
command! -nargs=1 -complete=filetype Ft set ft=<args>
command! -bar Te execute "terminal" | norm i

" normal
nnoremap <esc> <cmd>nohl<cr><cmd>call <sid>QuickFixHighlightOff()<cr>
nnoremap <leader>s <cmd>call <sid>StripTrailingWhitespace()<cr>
nnoremap <leader>e :make!<space>
nnoremap <leader>f :RustFmt<cr>
nnoremap <c-n> <cmd>bn<cr>
nnoremap <c-p> <cmd>bp<cr>
" nvo
noremap <space> :
noremap gf gF
noremap gF gf
" insert
inoremap <expr> <c-n> pumvisible() <bar><bar> &omnifunc == "" ? "<c-n>" : "<c-x><c-o>"
" terminal
tnoremap <esc> <c-\><c-n>

let g:sneak#label = 1
omap s <plug>Sneak_s
omap S <plug>Sneak_S
hi! link Sneak CurSearch
hi! link SneakLabel CurSearch

autocmd FileType netrw set nu rnu
let g:netrw_banner = 0
let g:netrw_liststyle = 3

autocmd FileType * setlocal formatoptions=q
autocmd FileType vim setlocal foldmethod=marker
autocmd FileType rust setlocal makeprg=cargo
autocmd TermOpen * setlocal nonu nornu

hi! link i3ConfigError NONE

func s:StripTrailingWhitespace()
	let l:saved_view = winsaveview()
	redir => l:matches
		silent keeppatterns %s/\s\+$//ne
	redir END
	let l:nsubbed = "0"
	if len(l:matches) != 0
		let l:nsubbed = trim(split(l:matches, " ")[0])
	endif
	silent keeppatterns %s/\s\+$//e
	call winrestview(l:saved_view)
	echo "Trimmed" l:nsubbed "line(s)"
endfunc

" {{{ quickfix tweaks
autocmd FileType qf setlocal cursorline
autocmd FileType qf nnoremap <buffer> <cr> <cr><cmd>call <sid>HiCurQuickfix()<cr>

function s:HiCurQuickfix()
	let l:qf = getqflist({ "idx": 0, "items": 1 })
	let l:idx = l:qf["idx"] - 1
	let l:cur = l:qf["items"][l:idx]
	let l:lnum = l:cur["lnum"]
	let l:end_lnum = l:cur["end_lnum"]
	let l:col = l:cur["col"]
	let l:end_col = l:cur["end_col"]

	if l:end_lnum != 0 && l:lnum != l:end_lnum
		let l:pos = range(l:lnum, l:end_lnum)
	elseif l:end_col == 0
		let l:pos = [[l:lnum, l:col]]
	else
		let l:pos = [[l:lnum, l:col, l:end_col - l:col]]
	endif

	silent! call matchdelete(s:lastqfsearchid)
	let s:lastqfsearchid = matchaddpos("CurSearch", l:pos)
endfunc

func s:QuickFixHighlightOff()
	silent! call matchdelete(s:lastqfsearchid)
endfunc
" }}}

" {{{ visible trailing whitespace
hi TrailingWhitespace ctermfg=3 ctermbg=1
autocmd BufWinEnter,InsertLeave,TermOpen * call <sid>TrailingWhitespaceWinChange()
autocmd InsertEnter * match none TrailingWhitespace

func s:TrailingWhitespaceWinChange()
	" only show it for normal buffers (see :h 'buftype')
	if &buftype == ""
		match TrailingWhitespace /\s\+$/
	else
		match none TrailingWhitespace
	endif
endfunc
" }}}

" {{{ smart delimiters
let s:delims = { "(":")", "{":"}", "[":"]", '"':'"' }
for [s:lhs, s:rhs] in items(s:delims)
	exec "inoremap <expr> " s:lhs "<sid>OnInsertDelim('" . s:lhs . "','" . s:lhs . "', '" . s:rhs . "')"
	if s:lhs != s:rhs
		exec "inoremap <expr> " s:rhs "<sid>OnInsertDelim('" . s:rhs . "','" . s:lhs . "', '" . s:rhs . "')"
	endif
endfor

let s:delimspacechars = [ " ", "\t" ]
" characters that don't prevent autoclose if they are found between cursor and end of line
let s:autoclose_ignorechars = [";", ","] + s:delimspacechars + keys(s:delims) + values(s:delims)

inoremap <expr> <bs> <sid>IfBetweenDelims("\<bs>\<del>", "\<bs>")
inoremap <expr> <space> <sid>IfBetweenDelims("\<space>\<space>\<left>", "\<space>")
inoremap <expr> <cr> <sid>IfBetweenDelims("\<cr>\<c-o>O", "\<cr>")

func s:OnInsertDelim(typed, lhs, rhs)
	" quote at the end of a vimscript line is probably a comment. yuck.
	if &ft == "vim" && col(".") == col("$") && a:typed == '"'
		return a:typed
	endif

	let l:line = getline(".")

	" no autoclose if already unbalanced
	if a:lhs == a:rhs
		if count(l:line, a:lhs) % 2
			return a:typed
		endif
	else
		if count(l:line, a:lhs) != count(l:line, a:rhs)
			return a:typed
		endif
	endif

	let l:curidx = col(".") - 1

	let l:spacesaftercursor = 0
	while index(s:delimspacechars, l:line[l:curidx + l:spacesaftercursor]) != -1
		let l:spacesaftercursor += 1
	endwhile

	" skip over any spaces to get past the typed char, without inserting a new char
	if l:line[l:curidx + l:spacesaftercursor] == a:typed
		return repeat("\<right>", l:spacesaftercursor + 1)
	endif

	if a:typed == a:lhs
		" no autoclose if there is a non-'s:autoclose_ignorechars' char between cursor and end of line
		for i in l:line[l:curidx + l:spacesaftercursor:]
			if index(s:autoclose_ignorechars, i) == -1
				return a:typed
			endif
		endfor
		" otherwise, autoclose
		return a:lhs . a:rhs . "\<left>"
	endif

	return a:typed
endfunc

func s:IfBetweenDelims(when_between, otherwise)
	let l:line = getline(".")
	let l:curidx = col(".")
	let l:bef = l:line[l:curidx - 2]
	let l:aft = l:line[l:curidx - 1]

	if has_key(s:delims, l:bef) && s:delims[l:bef] == l:aft
		return a:when_between
	else
		return a:otherwise
	endif
endfunc
" }}}

" {{{ big ol' has("nvim") block
if has("nvim")
	hi YankeeDoodle ctermfg=3 ctermbg=8
	autocmd TextYankPost * lua vim.highlight.on_yank { higroup = "YankeeDoodle" }

lua <<EOF
	local lspconfig = require("lspconfig")

	vim.lsp.set_log_level("OFF")

	vim.diagnostic.config {
		virtual_text = false,
		underline = false,
		signs = false,
	}

	local on_attach = function(client, bufnr)
		vim.bo.omnifunc="v:lua.vim.lsp.omnifunc"
	end
	lspconfig.rust_analyzer.setup {
		on_attach = on_attach,
		settings = {
			["rust-analyzer"] = {
				completion = {
					callable = {
						snippets = "none",
					},
				},
			},
		},
	}
	lspconfig.clangd.setup { on_attach = on_attach }

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help, {
			close_events = { "CursorMoved" }
		}
	)

	vim.keymap.set("n", "<c-a>", vim.lsp.buf.hover)
	vim.keymap.set("i", "<c-h>", vim.lsp.buf.signature_help)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition)
	vim.keymap.set("n", "<c-w>d", function() vim.cmd("botright vsplit | norm gd") end)
	vim.keymap.set("n", "gD", vim.lsp.buf.type_definition)
	vim.keymap.set("n", "<c-w>D", function() vim.cmd("botright vsplit | norm gD") end)
	vim.keymap.set("n", "<c-c>", vim.lsp.buf.code_action)
EOF
endif
" }}}
