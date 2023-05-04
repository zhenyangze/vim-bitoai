if exists('g:loaded_vim_bito')
    finish
endif
let g:loaded_vim_bito = 1
let g:vim_bito_plugin_path = fnamemodify(expand('<sfile>:p:h'), ':p')
 " Set default values for variables if they don't exist
let g:vim_bito_path = get(g:, 'vim_bito_path', "bito")
let g:vim_bito_command = get(g:, 'vim_bito_command', "AsyncRun -mode=async -close=0 -pos=right -raw")
let g:vim_bito_promote_append = get(g:, 'vim_bito_promote_append', "")
let g:vim_bito_promote_generate = get(g:, 'vim_bito_promote_generate', "Please Generate Code")
let g:vim_bito_promote_generate_unit = get(g:, 'vim_bito_promote_generate_unit', "Please Generate Unit Test Code")
let g:vim_bito_promote_explain = get(g:, 'vim_bito_promote_explain', "What does that code do")
let g:vim_bito_promote_generate_comment = get(g:, 'vim_bito_promote_generate_comment', "Generate a comment for this method, explaining the parameters and output")
let g:vim_bito_promote_check_performance = get(g:, 'vim_bito_promote_check_performance', "Check code for performance issues, explain the issues, and rewrite code if possible")
let g:vim_bito_promote_check = get(g:, 'vim_bito_promote_check', "Identify potential issues that would find in this code, explain the issues, and rewrite code if possible")
let g:vim_bito_promote_check_security = get(g:, 'vim_bito_promote_check_security', "Check code for security issues, explain the issues, and rewrite code if possible")
let g:vim_bito_promote_readable = get(g:, 'vim_bito_promote_readable', "Organize the code to be more human readable")
let g:vim_bito_promote_check_style = get(g:, 'vim_bito_promote_check_style', "Check code for style issues, explain the issues, and rewrite code if possible")
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
    let cmd = l:bitoaiPath . ' -p ' . shellescape(l:templatePath) . ' -f ' . shellescape(l:tempFile)
    exec g:vim_bito_command . ' ' . cmd
endfunction

command! -nargs=0 BitoAiGenerate :call BitoAiGenerate()
command! -range -nargs=0 BitoAiGenerateUnit :call BitoAiSelected('generate_unit')
command! -range -nargs=0 BitoAiGenerateComment :call BitoAiSelected('generate_comment')
command! -range -nargs=0 BitoAiCheck :call BitoAiSelected('check')
command! -range -nargs=0 BitoAiCheckSecurity :call BitoAiSelected('check_security')
command! -range -nargs=0 BitoAiCheckStyle :call BitoAiSelected('check_style')
command! -range -nargs=0 BitoAiCheckPerformance :call BitoAiSelected('check_performance')
command! -range -nargs=0 BitoAiReadable :call BitoAiSelected('readable')
command! -range -nargs=0 BitoAiExplain :call BitoAiSelected('explain')
