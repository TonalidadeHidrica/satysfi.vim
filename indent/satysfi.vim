" Vim indent file
" Language:     SATySFi
" Author:       Masaki Hara <ackie.h.gmai@gmail.com>
" Date:         February 21, 2018
" File Types:   satysfi
" Version:      1
" Notes:

" This indent file is experimental under g:satysfi_indent.
if !exists("g:satysfi_indent") || g:satysfi_indent == 0
 finish
endif

" Only load this indent file when no other was loaded.
if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nocindent
setlocal expandtab
setlocal indentexpr=GetSATySFiIndent()
setlocal indentkeys+=0=and,0=constraint,0=else,0=end,0=if,0=in,0=let,0=let-block,0=let-inline,0=let-math,0=let-mutable,0=let-rec,0=then,0=type,0=val,0=with,0=\|>,0\|,0},0],0),0<>>
setlocal nolisp
setlocal nosmartindent

" Only define the function once.
if exists("*GetSATySFiIndent")
 finish
endif

" Ignoring patterns
let s:ignore_for_prog = 'synIDattr(synID(line("."), col("."), 0), "name") !~ "satysfiProg"'

" Indent pairs
function! s:FindPair(pstart, pmid, pend)
  call search(a:pend, 'W')
  return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', s:ignore_for_prog))
endfunction
function! s:FindPairBefore(pstart, pmid, pend)
  return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', s:ignore_for_prog))
endfunction

function! s:ProgIndent()
  " Search for the previous non-empty line
  " Lines starting with |> are also ignored
  call cursor(v:lnum, 1)
  let llnum = search('^\s*\%(|>\)\@![^ \t\r\n%]', 'bWn')
  call cursor(v:lnum, 1)
  if llnum == 0
    " 0 indent at the top
    return 0
  endif

  " Previous line and its indentation
  let lline = substitute(getline(llnum), '%.*', '', '')
  let lindent = indent(llnum)

  if lline =~ '^\s*@[a-z][-a-zA-Z0-9]*:'
    " 0 indent just below the headers
    return 0
  endif

  " Current line
  let line = getline(v:lnum)
  if line =~ '^\s*\%(let\|let-block\|let-inline\|let-math\|let-mutable\|let-rec\)\>'
    " It is either a let-in or a toplevel/module-level let.
    if lline =~ '\<in\s*$'
      " Align let-ins same
      return lindent
    elseif lline =~ '\<\%(not\|mod\|if\|then\|else\|let\|let-rec\|and\|fun\|before\|while\|do\|let-mutable\|match\|with\|when\|as\|type\|of\|module\|struct\|sig\|val\|direct\|constraint\|let-inline\|let-block\|let-math\|controls\|command\)\s*$'
      " Seems to be let-in
      return lindent + shiftwidth()
    elseif lline =~ '\%([a-zA-Z][-a-zA-Z0-9]*\|[0-9]\+\.\?\|[])}`]\|\S>\)\s*$'
      " Seems to be the toplevel let
      " TODO: deal with modules
      return 0
    else
      " Seems to be let-in
      return lindent + shiftwidth()
    endif
  elseif line =~ '^\s*type\>'
    " Toplevel or module-level type
    " TODO: deal with modules
    return 0
  elseif line =~ '^\s*and\>'
    " let-rec/and or type/and
    " TODO: deal with paths
    let let_line = search('\<\%(let\|let-block\|let-inline\|let-math\|let-mutable\|let-rec\)\>', 'bWn')
    let type_line = search('\<type\>', 'bWn')
    if let_line >= type_line
      return s:FindPairBefore('\<\%(let\|let-block\|let-inline\|let-math\|let-mutable\|let-rec\)\>', '', '\<in\>')
    else
      " TODO: deal with modules
      return 0
    endif
  elseif line =~ '^\s*module\>'
    " Toplevel or module-level module definition
    " TODO: deal with modules
    return 0
  elseif line =~ '^\s*do\>'
    " while-do
    return s:FindPair('\<while\>', '', '\<do\>')
  elseif line =~ '^\s*then\>'
    " if-then-else
    return s:FindPairBefore('\<if\>', '', '\<else\>')
  elseif line =~ '^\s*else\>'
    " if-then-else
    return s:FindPair('\<if\>', '', '\<else\>')
  elseif line =~ '^\s*->'
    " fun ->
    return s:FindPair('\<fun\>', '', '->')
  elseif line =~ '^\s*|>' && lline =~ '|>'
    " Align |> same
    return match(lline, '|>')
  elseif line =~ '^\s*in\>'
    return s:FindPair('\<\%(let\|let-block\|let-inline\|let-math\|let-mutable\|let-rec\)\>', '', '\<in\>')
  elseif line =~ '^\s*|'
    return lindent
  elseif line =~ '^\s*)'
    return s:FindPair('(', '', ')')
  elseif line =~ '^\s*]'
    return s:FindPair('\[', '', '\]')
  else
    return lindent + shiftwidth()
  endif
  return -1
endfunction

function! s:VertIndent()
  return -1
endfunction

function! s:HorzIndent()
  return -1
endfunction

function! s:MathIndent()
  return -1
endfunction

function! GetSATySFiIndent()
  call cursor(v:lnum, 1)
  let synname = synIDattr(synID(line("."), col("."), 0), "name")
  if synname =~ '^satysfiProg' || synname == ''
    return s:ProgIndent()
  elseif synname =~ '^satysfiVert'
    return s:VertIndent()
  elseif synname =~ '^satysfiHorz'
    return s:HorzIndent()
  elseif synname =~ '^satysfiMath'
    return s:MathIndent()
  endif
  return -1
endfunction