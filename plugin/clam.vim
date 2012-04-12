" ============================================================================
" File:        clam.vim
" Description: A simple little shell plugin.
" Maintainer:  Steve Losh <steve@stevelosh.com>
" License:     MIT/X11
" ============================================================================


" Init {{{

if !exists('g:clam_debug') && (exists('loaded_clam') || &cp)
    finish
endif

let loaded_clam = 1

if !exists('g:clam_autoreturn') " {{{
    let g:clam_autoreturn = 1
endif " }}}

if !exists('g:clam_winpos') "{{{
    let g:clam_winpos = 'vertical botright'
endif "}}}

"}}}
" Functions {{{

function! s:GoToClamBuffer(command) " {{{
    let buffer_name = fnameescape(a:command)

    " Find any already-open clam windows for this command.
    let winnr = bufwinnr('^' . buffer_name . '$')

    " Open the new window (or move to an existing one).
    if winnr < 0
        silent! execute g:clam_winpos . ' new ' . buffer_name
    else
        silent! execute winnr . 'wincmd w'
    endif
endfunction " }}}
function! s:ConfigureCurrentClamBuffer(command) " {{{
    " Set some basic options for the output window.
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber

    if g:clam_autoreturn
        " When closing this buffer in any way (like :quit), jump back to the original window.
        silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
    endif

    " Map <localleader>r to "refresh" the command (call it again).
    silent! execute 'nnoremap <silent> <buffer> <localleader>r :call <SID>Execlam(''' . a:command . ''')<cr>'

    " Map <localleader>p to "pipe" the buffer into a new command.
    silent! execute 'nnoremap <buffer> <LocalLeader>p ggVG!'

    " Highlight ANSI color codes if the AnsiEsc plugin is present.
    if exists("g:loaded_AnsiEscPlugin")
        silent! execute 'AnsiEsc'
    endif
endfunction " }}}
function! s:ReplaceCurrentBuffer(contents) " {{{
    normal! ggdG
    call append(0, split(a:contents, '\v\n'))
endfunction " }}}

function! s:ExeclamVisual(command) range " {{{
    let old_z = @z

    normal! gv"zy
    call s:Execlam(a:command, @z)

    let @z = old_z
endfunction " }}}
function! s:ExeclamNormal(ranged, l1, l2, command) " {{{
    if a:ranged
        let lines = getline(a:l1, a:l2)
        let stdin = join(lines, "\n") . "\n"

        call s:Execlam(a:command, stdin)
    else
        call s:Execlam(a:command)
    endif
endfunction " }}}
function! s:Execlam(command, ...) " {{{
    " Build the actual command string to execute
    let command = join(map(split(a:command), 'expand(v:val)'))

    " Run the command
    echo 'Executing: ' . command

    if a:0 == 0
        let result = system(command)
    elseif a:0 == 1
        let result = system(command, a:1)
    else
        echom "Invalid number of arguments passed to Execlam()!"
        return
    endif

    call s:GoToClamBuffer(command)
    call s:ConfigureCurrentClamBuffer(command)

    call s:ReplaceCurrentBuffer(result)

    silent! redraw

    echo 'Shell command executed: ' . command
endfunction " }}}

" }}}
" Command {{{

command! -range=0 -complete=shellcmd -nargs=+ Clam call s:ExeclamNormal(<count>, <line1>, <line2>, <q-args>)
command! -range=% -complete=shellcmd -nargs=+ ClamVisual call s:ExeclamVisual(<q-args>)

" }}}
