" Pluggins {{{
" Install Vim Plug if not installed and installs plugins on first launch
if empty(glob('~\AppData\Local\nvim\autoload\plug.vim'))
  silent !curl -fLo ~\AppData\Local\nvim\autoload\plug.vim  --create-dirs
     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   autocmd VimEnter * PlugInstall
endif

call plug#begin()
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Snippets and syntax
  Plug 'honza/vim-snippets' " Generic snippets
  Plug 'sheerun/vim-polyglot' " Generic syntax
  Plug 'OrangeT/vim-csharp' " C# and cshtml syntax
  Plug 'chrisbra/csv.vim' " CSV files

  " Fixes
  Plug 'bfrg/vim-qf' " Fixes issues with built in quick fix menu
  Plug 'tpope/vim-repeat' " Repeat with . sequences that use pluggins

  " Must have plugins
  Plug 'tpope/vim-eunuch' " Gives unix like comands to vim
  Plug 'tpope/vim-surround' " Change/Add surrounding character
  Plug 'tomtom/tcomment_vim' " Toggle comments
  Plug 'pgdouyon/vim-evanesco' " Clears search highlighting on move

  Plug 'JessicaKMcIntosh/TagmaTasks'

  Plug 'scrooloose/nerdtree'
  Plug 'jistr/vim-nerdtree-tabs'
  Plug 'junegunn/fzf'
  Plug 'wincent/ferret'
  Plug 'chriskempson/base16-vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  Plug 'majutsushi/tagbar'

  Plug 'jceb/vim-orgmode'
call plug#end()

" }}}

" Settings {{{
" Remap leader to space is not working
let mapleader = " "
let maplocalleader = " "

" Indentation
set ai et sw=2 ts=2 sts=2

" Misc
set mouse=a
set spellfile=~/spell/en.utf-8.add
noswapfile

" UI
set background=dark
set list
set listchars=tab:>~,nbsp:_,trail:.,extends:>,precedes:<
set cursorline

" Custom keys as todo

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun


" No wrapping and line numbers
set nowrap
set number

" Sane window splitting
set splitbelow
set splitright

" Folding
function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction
set foldtext=MyFoldText()
set foldlevel=2

" Search
set hlsearch
set ignorecase
set incsearch
set smartcase

if has("termguicolors")
  set t_Co=256
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
"}}}

" Plugin settings {{{
" NERDTree
let NERDTreeWinPos="right"
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
let NERDTreeMinimalMenu=1

" FZF
let $FZF_DEFAULT_COMMAND = 'dir /s/b'
let g:fzf_colors = {
            \'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine'],
            \ 'bg+':     ['bg', 'Normal'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'CursorLine'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment']
            \}

let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()'}

" Ferret
" let g:FerretExecutable='ag' " Apparently cannot be enabled on windows as it
" breaks the job

" Coc
set hidden

" Tagbar
let g:tagbar_left=1

" TagmaTasks
let g:TagmaTasksMarks = 0
let g:TagmaTasksTokens = ['FIXME', 'TODO', 'NOTE', 'XXX', 'COMBAK']
let g:TagmaTasksAutoUpdate = 0


" Coc extensions
call coc#add_extension(
      \'coc-json',
      \'coc-tsserver',
      \'coc-sh',
      \'coc-python',
      \'coc-word',
      \'coc-emoji',
      \'coc-marketplace',
      \'coc-pairs',
      \'coc-emmet',
      \'coc-snippets',
      \'coc-jest',
      \'coc-prettier',
      \'coc-eslint',
      \'coc-omnisharp',
      \'coc-css',
      \'https://github.com/dsznajder/vscode-es7-javascript-react-snippets'
      \)

" }}}

" Functions {{{
" Needed for coc bindings {{{
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
"}}}

" dos2unix ^M
fun! Dos2unixFunction()
    let _s=@/
    let l = line(".")
    let c = col(".")
    try
        set ff=unix
        w!
        "%s/\%x0d$//e
    catch /E32:/
        echo "Sorry, first save the file."
    endtry
    let @/=_s
    call cursor(l, c)
endfun


" Centered floating window {{{
" Creates a floating window with a most recent buffer to be used
function! CreateCenteredFloatingWindow()
    let width = float2nr(&columns * 0.6)
    let height = float2nr(&lines * 0.6)
    let top = ((&lines - height) / 2) - 2
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = "╭" . repeat("─", width - 2) . "╮"
    let mid = "│" . repeat(" ", width - 2) . "│"
    let bot = "╰" . repeat("─", width - 2) . "╯"
    let lines = [top] + repeat([mid], height - 2) + [bot]
    let s:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:buf, 0, -1, v:true, lines)
    call nvim_open_win(s:buf, v:true, opts)
    set winhl=Normal:Floating

    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    call nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    autocmd BufWipeout <buffer> call CleanupBuffer(s:buf)
    tnoremap <buffer> <silent> <Esc> <C-\><C-n><CR>:call DeleteUnlistedBuffers()<CR>
endfunction

function! CleanupBuffer(buf)
    if bufexists(a:buf)
        silent execute 'bwipeout! '.a:buf
    endif
endfunction

function! DeleteUnlistedBuffers()
    for n in nvim_list_bufs()
        if ! buflisted(n)
            let name = bufname(n)
            if name == '[Scratch]' ||
              \ matchend(name, ":bash") ||
              \ matchend(name, ":lazygit") ||
              \ matchend(name, ":tmuxinator-fzf-start.sh")
                call CleanupBuffer(n)
            endif
        endif
    endfor
endfunction

" When term starts, auto go into insert mode
autocmd TermOpen * startinsert

" Turn off line numbers etc
autocmd TermOpen * setlocal listchars= nonumber norelativenumber

" Close fzf with escape
autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
" Open in vertical split as it is more of a pneumonic
autocmd! FileType fzf tnoremap <buffer> <c-h> <c-x>


function! OnTermExit(job_id, code, event) dict
    if a:code == 0
        call DeleteUnlistedBuffers()
    endif
endfunction

function! ToggleTerm(cmd)
    if empty(bufname(a:cmd))
        call CreateCenteredFloatingWindow()
        call termopen(a:cmd, { 'on_exit': function('OnTermExit') })
    else
        call DeleteUnlistedBuffers()
    endif
endfunction
" }}}


" Views {{{
let g:skipview_files = [
            \ '[EXAMPLE PLUGIN BUFFER]'
            \ ]
function! MakeViewCheck()
    if has('quickfix') && &buftype =~ 'nofile'
        " Buffer is marked as not a file
        return 0
    endif
    if empty(glob(expand('%:p')))
        " File does not exist on disk
        return 0
    endif
    if len($TEMP) && expand('%:p:h') == $TEMP
        " We're in a temp dir
        return 0
    endif
    if len($TMP) && expand('%:p:h') == $TMP
        " Also in temp dir
        return 0
    endif
    if index(g:skipview_files, expand('%')) >= 0
        " File is in skip list
        return 0
    endif
    return 1
endfunction
"}}}

" }}}

" Autocommands {{{
augroup vimrcAutoView
  autocmd!
  " Autosave & Load Views.
  " autocmd BufWritePost,BufLeave,WinLeave * if MakeViewCheck() | mkview | endif
  " autocmd BufWinEnter * if MakeViewCheck() | silent loadview | endif
augroup end

augroup folds
  autocmd!
  autocmd FileType cs setlocal foldmethod=indent
  autocmd FileType vim setlocal foldmethod=marker
augroup end

" TODO: Change this to use filetype
augroup Indentation
  autocmd!
  autocmd FileType cs setlocal sw=4 ts=4 sts=4
  autocmd FileType cucumber setlocal sw=2 ts=2 sts=2 noet
augroup end


function! TODOComments() abort
  syn match MyTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|COMBAK|XXX)/
        \ containedin=.*Comment,vimCommentTitle
  hi link MyTodo Todo
endfunction

augroup TODOHighlighting
  autocmd!
  autocmd FileType * call TODOComments()
augroup end

function! MyHighlights() abort
  hi ColorColumn guibg=#2d2d2d ctermbg=246
  hi Folded guibg=#2d2d2d ctermbg=246
  " Popup menu with default colorscheme look normal
  hi Pmenu guibg=#2d2d2d ctermbg=246
endfunction

augroup MyColors
    autocmd!
    autocmd ColorScheme default call MyHighlights()
augroup END
colorscheme base16-onedark

augroup AutoSource
  autocmd!
  " autocmd BufWritePost $MYVIMRC nested source $MYVIMRC
  autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup end
" }}}

" Mappings {{{
map <silent> <S-Insert> "+p
imap <silent> <S-Insert> <Esc>"+pa

" Nav quickfix
nnoremap <up> :cprev<cr>
nnoremap <down> :cnext<cr>


" Tagbar
noremap <leader>b :Tagbar<CR>

" Change instances of word undercursor
nnoremap c* *Ncgn

" Split movement
nnoremap <C-h> <C-W>h
nnoremap <C-j> <C-W>j
nnoremap <C-l> <C-W>l
nnoremap <C-k> <C-W>k

" Move split
nnoremap <leader>H <C-w>H
nnoremap <leader>L <C-w>L
nnoremap <leader>J <C-w>J
nnoremap <leader>K <C-w>K


" Scrolling binds
noremap <m-l> zl
noremap <m-h> zh
noremap <m-j> <c-e>
noremap <m-k> <c-y>

" Create splits
nnoremap c<C-j> :split Below<CR>
nnoremap c<C-l> :vsplit Right<CR>
nnoremap c<C-h> :aboveleft vsp Left<CR>
nnoremap c<C-k> :above split Above<CR>

" Resize with arrow keys and ctrl
nnoremap <C-Left> :vertical resize -5<CR>
nnoremap <C-Right> :vertical resize +5<CR>
nnoremap <C-Down> :resize -5<CR>
nnoremap <C-Up>   :resize +5<CR>

nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>wq :wq<CR>


" Nerdtree opens with ctrl + n
nnoremap <C-n> :NERDTreeTabsToggle<CR>:doau FocusGained<CR>

" Open FZF with ctrl-p
nnoremap <C-p> :FZF<cr>



" Y yanks to end of line like it should
nnoremap Y y$

" Coc
" Tab and shift tab to nav
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Show documentation
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> gh :call <SID>show_documentation()<CR>

" Coc format
nnoremap <silent> <Leader>d :call CocAction('format')<CR>

" CR expand
inoremap <silent> <expr> <cr>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ "\<C-g>u\<CR>"

" Expand snip with tab
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
let g:coc_snippet_next = '<tab>'

" Ctrl j and k next and previous stop
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

" Coc list errors
nnoremap <silent> <leader>cl :<C-u>CocList diagnostics<CR>

" Ctrl space like vscode
inoremap <silent><expr> <c-space> coc#refresh()

" Orginize imports
nnoremap <silent> <leader>or :call     CocAction('runCommand', 'editor.action.organizeImport')<CR>
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" CocCommands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>

"Code action leader a
xmap <leader>a  <Plug>(coc-codeaction-selected)<cr>
nmap <leader>a  <Plug>(coc-codeaction-selected)<cr>

"Coc rename symbol
nmap <leader>rn <Plug>(coc-rename)

" Better visual block indentation changing
" FIXME: Backdenting is not working as expected on windows
vnoremap < <gv
vnoremap > >gv

" Regen ctags
 map <Leader>rt :!ctags --extra=+f -R *<CR><CR>

nmap <Leader>t :Term<CR>
"}}}

" Commands {{{
command! RmTrail %s/\s\+$//e
command! Notes e ~/notes.org
command! Breakline :g/^/norm gww
com! Dos2Unix keepjumps call Dos2unixFunction()
com! Term call ToggleTerm('powershell')
" }}}
