function! s:onExit(job_id, status, event) dict
  if a:status == 0 && self.auto_close
    execute 'silent! bd! '.self.buffer_nr
  endif
  call self.callback(a:status == 0)
endfunction

function! npm#run(cmd, cwd, callback, auto_close)
  let old_cwd = getcwd()
  execute 'lcd ' . a:cwd
  if exists('*termopen')
    execute 'belowright 5new'
    setl winfixheight
    setl norelativenumber
    call termopen(a:cmd, {
          \ 'on_exit': function('s:onExit'),
          \ 'buffer_nr': bufnr('%'),
          \ 'callback': a:callback,
          \ 'auto_close': a:auto_close
          \})
    execute 'normal! G'
    execute 'wincmd p'
  else
    execute '!'.a:cmd
  endif
  execute 'lcd ' . old_cwd
endfunction

function! npm#run_command(cmd, ...)
  function! Callback(cmd, succeed)
    if a:succeed
      echohl MoreMsg | echon a:cmd . ' succeed' | echohl None
    endif
  endfunction
  let cwd = fnamemodify(findfile('package.json', '.;'), ':p:h')
  let auto_close = get(a:000, 0, v:true)
  call npm#run(a:cmd, cwd, function('Callback', [a:cmd]), auto_close)
endfunction

function! npm#iterm_tabopen(dir)
  call s:osascript(
    \ 'tell application "iTerm2"',
    \   'tell current window',
    \     'create tab with default profile',
    \     'tell current session',
    \       'delay 0.1',
    \       'write text "cd '.s:escape(a:dir).'"',
    \       'write text "clear"',
    \     'end tell',
    \   'end tell',
    \ 'end tell')
endfunction

function! npm#projects()
  let folders = get(g:, 'npm_project_folders', [])
  let res = []
  for folder in folders
    for path in split(glob(folder.'/*'), "\n")
      if isdirectory(path)
        let info = s:getPackageInfo(path)
        call add(res, {
          \ 'name': get(info, 'name', ''),
          \ 'description': get(info, 'description', ''),
          \ 'directory': path,
          \})
      endif
    endfor
  endfor
  return res
endfunction

function! s:escape(cmd)
  let str = substitute(a:cmd, "'", "''", 'g')
  return escape(str, '"')
endfunction

function! s:osascript(...) abort
  let args = join(map(copy(a:000), '" -e ".shellescape(v:val)'), '')
  call  s:system('osascript'. args)
  return !v:shell_error
endfunction

function! s:system(cmd)
  let output = system(a:cmd)
  if v:shell_error && output !=# ""
    echohl Error | echon output | echohl None
    return
  endif
  return output
endfunction

function! s:getPackageInfo(path)
  let file = a:path . '/package.json'
  if !filereadable(file) | return {} | endif
  try
    let obj = json_decode(readfile(file))
  catch /.*/
    echoerr 'Decode error for '. file
    return {}
  endtry
  if !has_key(obj, 'name') | return {} | endif
  return obj
endfunction
