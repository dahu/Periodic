" Vim global plugin for short description
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Version:	0.1
" Description:	Long description.
" License:	Vim License (see :help license)
" Location:	plugin/periodic.vim
" Website:	https://github.com/dahu/periodic
"
" See periodic.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help periodic

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_periodic")
      \ || v:version < 700
      \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_periodic = 1

" Commands: {{{1
command! -nargs=* Periodic call periodic#add(<f-args>)

augroup Periodic
  au!
  au InsertLeave,CursorMoved,CursorHold * call periodic#show_periodically()
augroup END

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
