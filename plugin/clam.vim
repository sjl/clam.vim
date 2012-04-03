" ============================================================================
" File:        clam.vim
" Description: A simple little shell.
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT/X11
" ============================================================================


" Init {{{

if !exists('g:clam_debug') && (exists('loaded_clam') || &cp)
    finish
endif

let loaded_clam = 1

"}}}
" Function {{{

function! s:Execlam(command)
    " Build the actual command string to execute
    let command = join(map(split(a:command), 'expand(v:val)'))

    " Find any already-open clam windows for this command.
    let winnr = bufwinnr('^' . command . '$')

    " Open the new window (or move to an existing one).
    if winnr < 0
        silent! execute 'botright vnew ' . fnameescape(command)
    else
        silent! execute winnr . 'wincmd w'
    endif

    " Set some basic options for the output window.
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber

    " Actually run the command, placing its output in the current window.
    echo 'Executing: ' . command
    silent! execute 'silent %!'. command

    " When closing this buffer in any way (like :quit), jump back to the original window.
    silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''

    " Map <localleader>r to "refresh" the command (call it again).
    silent! execute 'nnoremap <silent> <buffer> <localleader>r :call <SID>Execlam(''' . command . ''')<cr>'

    " Map <localleader>p to "pipe" the buffer into a new command.
    silent! execute 'nnoremap <buffer> <LocalLeader>p ggVG!'

    " Highlight ANSI color codes if the AnsiEsc plugin is present.
    if exists("g:loaded_AnsiEscPlugin")
        silent! execute 'AnsiEsc'
    endif

    silent! redraw

    echo 'Shell command executed: ' . command
endfunction

" }}}
" Command {{{

command! -complete=shellcmd -nargs=+ Clam call s:Execlam(<q-args>)

" }}}
