call plug#begin()
Plug 'Flying-Toast/quark.vim'
Plug 'tpope/vim-fugitive'
if has("nvim")
	Plug 'neovim/nvim-lspconfig'
endif
call plug#end()

if has("nvim")
	set shada="NONE"
	set laststatus=3
else
	set viminfo=
endif
set clipboard=unnamedplus
set completeopt=noinsert,menuone
set notermguicolors
set nowrap
set nu rnu
set path=**
set shm+=I
set title
set titlestring=vi\ %f

let mapleader = ","
colorscheme quark

func CommandAbbrev(from, to)
	execute "cabbrev " . a:from . " <c-r>=getcmdpos() == 1 && getcmdtype() == ':' ? '" . a:to . "' : '" . a:from . "'<cr>"
endfunc
call CommandAbbrev("f", "find")
call CommandAbbrev("man", "Man")
call CommandAbbrev("gr", "GrepCw")
call CommandAbbrev("er", "DiagQuickfix")

command! -bar -nargs=1 GrepCw execute "silent grep! " <q-args> | cw
command! DiagQuickfix lua vim.diagnostic.setloclist()

" normal
nnoremap <esc> <cmd>nohl<cr>
nnoremap <leader>s <cmd>call StripTrailingWhitespace()<cr>
nnoremap <leader>t <cmd>terminal<cr>i
" nvo
noremap <space> :
noremap gf gF
noremap gF gf
" insert
inoremap <expr> <c-n> pumvisible() <bar><bar> &omnifunc == "" ? "<c-n>" : "<c-x><c-o>"
" terminal
tnoremap <esc> <c-\><c-n>

autocmd FileType * setlocal formatoptions=q
autocmd FileType qf setlocal cursorline
autocmd FileType qf noremap <buffer> <cr> <cr><c-w>p
autocmd TermOpen * setlocal nonu nornu
if has("nvim")
	autocmd TextYankPost * silent! lua vim.highlight.on_yank()
endif

" visible trailing whitespace
hi TrailingWhitespace ctermfg=3 ctermbg=1
autocmd BufWinEnter,InsertLeave,TermOpen * call TrailingWhitespaceWinChange()
autocmd InsertEnter * match none TrailingWhitespace

hi! link i3ConfigError NONE

func TrailingWhitespaceWinChange()
	if &buftype == "terminal" || &buftype == "nofile"
		match none TrailingWhitespace
	else
		match TrailingWhitespace /\s\+$/
	endif
endfunc

func StripTrailingWhitespace()
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
	echo "Trimmed " . l:nsubbed . " line(s)"
endfunc

if has("nvim")
	hi ErrorLineNr ctermfg=1
	hi WarningLineNr ctermfg=3
	sign define DiagnosticSignError text= numhl=ErrorLineNr
	sign define DiagnosticSignWarn text= numhl=WarningLineNr
	sign define DiagnosticSignHint text=
	sign define DiagnosticSignInfo text=
	sign define DiagnosticSignOk text=
lua <<EOF
	local lspconfig = require("lspconfig")

	vim.diagnostic.config {
		virtual_text = false,
		underline = false,
		signs = true,
	}

	local on_attach = function(client, bufnr)
		vim.bo.omnifunc="v:lua.vim.lsp.omnifunc"
	end
	lspconfig.rust_analyzer.setup { on_attach=on_attach }
	lspconfig.clangd.setup { on_attach=on_attach }

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help, {
			close_events = { "CursorMoved" }
		}
	)

	vim.keymap.set("n", "<c-a>", vim.lsp.buf.hover)
	vim.keymap.set("i", "<c-h>", vim.lsp.buf.signature_help)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition)
	vim.keymap.set("n", "gD", vim.lsp.buf.type_definition)
	vim.keymap.set("n", "<c-c>", vim.lsp.buf.code_action)
EOF
endif
