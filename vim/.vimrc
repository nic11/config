" 2-space indentation
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Enable mouse support in all modes
set mouse=a

if ! has('clipboard')
  echo "no clipboard support"
endif

" set clipboard+=unnamed
" set paste
" set go+=a

" set clipboard=unnamed,unnamedplus

function! s:has_wl_clipboard() abort
  return executable('wl-copy') && executable('wl-paste')
endfunction

augroup wl-clipboard-paste
  autocmd!
"   autocmd FocusLost * :call system('wl-copy', @+)
  autocmd FocusGained * if s:has_wl_clipboard()
        \ | let @+ = system('wl-paste -n')
        \ | endif
augroup END

augroup wl-clipboard-sync
  autocmd!
  autocmd TextYankPost * if s:has_wl_clipboard()
        \ | call system('wl-copy', v:event.regcontents)
        \ | endif
  autocmd InsertEnter * if s:has_wl_clipboard()
        \ | let @+ = system('wl-paste -n')
        \ | endif
augroup END

" set relativenumber
set number relativenumber

" Highlight the current line
set cursorline
hi CursorLine cterm=NONE ctermbg=236 guibg=#2f2f2f

" Basic good-to-have settings
syntax on
filetype plugin indent on
set termguicolors
set background=dark

set ruler

set fileformats=unix,dos
set fileformat=unix

set hlsearch

" /usr/share/vim/vim91/defaults.vim
" Only do this part when Vim was compiled with the +eval feature.
if 1

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":autocmd! vimStartup"
  augroup vimStartup
    autocmd!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim), for a commit or rebase message
    " (likely a different one than last time), and when using xxd(1) to filter
    " and edit binary files (it transforms input files back and forth, causing
    " them to have dual nature, so to speak) or when running the new tutor
    autocmd BufReadPost *
      \ let line = line("'\"")
      \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
      \      && index(['xxd', 'gitrebase', 'tutor'], &filetype) == -1
      \      && !&diff
      \ |   execute "normal! g`\""
      \ | endif

    " Set the default background for putty to dark. Putty usually sets the
    " $TERM to xterm and by default it starts with a dark background which
    " makes syntax highlighting often hard to read with bg=light
    " undo this using:  ":au! vimStartup TermResponse"
    autocmd TermResponse * if v:termresponse == "\e[>0;136;0c" | set bg=dark | endif
  augroup END

  " Quite a few people accidentally type "q:" instead of ":q" and get confused
  " by the command line window.  Give a hint about how to get out.
  " If you don't like this you can put this in your vimrc:
  " ":autocmd! vimHints"
  augroup vimHints
    au!
    autocmd CmdwinEnter *
	  \ echohl Todo |
	  \ echo gettext('You discovered the command-line window! You can close it with ":q".') |
	  \ echohl None
  augroup END

endif
