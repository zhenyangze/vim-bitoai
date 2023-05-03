if exists('g:loaded_vim_bito')
    finish
endif
let g:loaded_vim_bito = 1

let g:vim_bito_plugin_path = fnamemodify(expand('<sfile>:p:h'), ':p')

if !exists('g:vim_bito_path')
    let g:vim_bito_path = "bito"
endif

if !exists('g:vim_bito_command')
    let g:vim_bito_command = "AsyncRun -mode=term -close=0 -pos=right -raw"
endif

if !exists('g:vim_bito_promote_append')
    let g:vim_bito_promote_append = ""
endif

if !exists("g:vim_bito_promote_generate")
    let g:vim_bito_promote_generate = "Please Generate Code"
endif

if !exists("g:vim_bito_promote_unit")
    let g:vim_bito_promote_unit = "Please Generate Unit Test Code"
endif


if !exists("g:vim_bito_promote_explain")
    let g:vim_bito_promote_explain = "What does that code do"
endif

if !exists("g:vim_bito_promote_comment")
    let g:vim_bito_promote_comment = "Generate a comment for this method, explaining the parameters and output"
endif

if !exists("g:vim_bito_promote_improve")
    let g:vim_bito_promote_improve = "Rewrite this code with performance improvements"
endif

if !exists("g:vim_bito_promote_check")
    let g:vim_bito_promote_check = "Identify potential issues that would find in this code"
endif


function! BitoAiGenerate()
    let l:input = input("Bito Promote：")

    if l:input == ""
        echo "Please Input Context!"
        return
    endif
    call BitoAiExec('generate', l:input)
endfunction

function! BitoAiSelected(promote)
    let l:start = getpos("'<")[1]
    let l:end = getpos("'>")[1]
    let l:lines = getline(l:start, l:end)
    let l:text = join(l:lines, "\n")

    if l:text == ""
        return
    endif
    call BitoAiExec(a:promote, l:text)
endfunction

function! BitoAiExec(promote, input)
    let l:tempFile = tempname()
    call writefile(split(a:input, "\n"), l:tempFile)

    let l:common_content = readfile(g:vim_bito_plugin_path . '/templates/common.txt')
    if exists('g:vim_bito_promote_' . a:promote)
        let l:promote = execute('echo g:vim_bito_promote_' . a:promote) . g:vim_bito_promote_append
    else
        echomsg "Undefined variable: g:vim_bito_promote_" . a:promote
        return
    endif

    let l:replaced_content = []
    for line in l:common_content
        let l:replaced_line = substitute(line, '{{:promote:}}', l:promote, '')
        call add(l:replaced_content, l:replaced_line)
    endfor

    let l:templatePath = tempname()
    call writefile(l:replaced_content, l:templatePath)

    let l:bitoaiPath = g:vim_bito_path

    let cmd = l:bitoaiPath . " -p " . l:templatePath . " -f " . l:tempFile
    exec g:vim_bito_command . " " . cmd
endfunction

command! -nargs=0 BitoAiGenerate :call BitoAiGenerate()
command! -range -nargs=0 BitoAiUnit :call BitoAiSelected('unit')
command! -range -nargs=0 BitoAiExplain :call BitoAiSelected('explain')
command! -range -nargs=0 BitoAiComment :call BitoAiSelected('comment')
command! -range -nargs=0 BitoAiImprove :call BitoAiSelected('improve')
command! -range -nargs=0 BitoAiCheck :call BitoAiSelected('check')
