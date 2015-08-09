" Vim library for the tardy timer
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" Description:	Periodic job scheduler within Vim
" License:	Vim License (see :help license)
" Location:	autoload/periodic.vim
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

if exists("g:loaded_lib_periodic")
      \ || v:version < 700
      \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_lib_periodic = 1

" Vim Script Information Function: {{{1
function! periodic#info()
  let info = {}
  let info.name = 'periodic'
  let info.version = 1.0
  let info.description = 'The Tardy Timer'
  let info.dependencies = []
  return info
endfunction

" Private Functions: {{{1

let g:periodic_delta = 60

function! s:periodic_delta()
  if exists('b:periodic_delta')
    return b:periodic_delta
  elseif exists('w:periodic_delta')
    return w:periodic_delta
  elseif exists('t:periodic_delta')
    return t:periodic_delta
  else
    return g:periodic_delta
  endif
endfunction

" Library Interface: {{{1

" optional 4th argument is 'period' in minutes
"   well, period * g:periodic_delta
function! periodic#job(name, type, command, ...)
  let obj = {}
  " default to a 1 minute period
  let period = a:0 ? a:1 : 1
  let [obj.name, obj.type, obj.period, obj.command] = [a:name, a:type, period, a:command]
  return obj
endfunction

let s:periodic_job_types = ['system', 'exe', 'expr', 'string']
let s:periodic_jobs = {}

function! periodic#add(name, type, command, ...)
  let period = a:0 ? str2nr(a:1) : 1
  let job = periodic#job(a:name, a:type, a:command, period)
  if ! (has_key(job, 'name') && has_key(job, 'type')) && has_key(job, 'command')
    throw 'periodic#add: invalid job object: ' . string(job)
  endif
  if index(s:periodic_job_types, job.type) == -1
    throw 'periodic#add: invalid job type: ' . job.type
  else
    let s:periodic_jobs[job.name] = {'job' : job, 'last' : 0}
  endif
  return job
endfunction

function! periodic#del(job)
  let job = a:job
  if type(job) == type('')
    let job_name = job
  elseif type(job) == type({})
    let job_name = job.name
  else
    throw 'periodic#del: invalid job object: ' . string(job)
  endif
  call remove(s:periodic_jobs, job_name)
endfunction

function! periodic#list()
  let list = []
  for j in values(s:periodic_jobs)
    call add(list, [j.last, j.job.name, j.job.type, j.job.period, j.job.command])
  endfor
  echom string(list)
endfunction

function! periodic#jobs(time, delta)
  let jobs = filter(copy(s:periodic_jobs), '(a:time - v:val.last) > (v:val.job.period * a:delta)')
  for j in values(jobs)
    let s:periodic_jobs[j.job.name].last = a:time
  endfor
  return map(values(jobs), 'v:val.job')
endfunction

function! periodic#periodically()
  let time = localtime()
  let delta = s:periodic_delta()
  let results = []
  for job in periodic#jobs(time, delta)
    if job.type == 'system'
      silent! let result = system(job.command)
      if v:shell_error != 0
        let result = '[fail] ' . result
      endif
    elseif job.type == 'exe'
      let result = '[ok]'
      try
        silent! exe job.command
      catch /.*/
        let result = v:errmsg
      endtry
    elseif job.type == 'expr'
      silent! let result = eval(job.command)
    elseif job.type == 'string'
      silent! let result = string(job.command)
    else
      throw 'periodic#execute: Unknown job type=' . job.type
    endif
    call add(results, job.command . ' => ' . result)
    unlet result
  endfor
  return results
endfunction

function! periodic#show_periodically()
  let results = periodic#periodically()
  let now = strftime("%H:%M") . ' - '
  for r in results
    if type(r) == type('')
      echom now . r
    else
      echom now . string(r)
    endif
  endfor
endfunction

" Teardown:{{{1
"reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
