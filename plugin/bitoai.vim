if exists('g:loaded_vim_bito')
    finish
endif
let g:loaded_vim_bito = 1
let g:bito_buffer_name_prefix = get(g:, 'bito_buffer_name_prefix', 'bito_history_')
let g:vim_bito_plugin_path = fnamemodify(expand('<sfile>:p:h'), ':p')
" Set default values for variables if they don't exist
let g:vim_bito_path = get(g:, 'vim_bito_path', "bito")
let g:vim_bito_prompt_append = get(g:, 'vim_bito_prompt_append', "")
let g:vim_bito_prompt_generate = get(g:, 'vim_bito_prompt_generate', "Please Generate Code")
let g:vim_bito_prompt_generate_unit = get(g:, 'vim_bito_prompt_generate_unit', "Please Generate Unit Test Code")
let g:vim_bito_prompt_explain = get(g:, 'vim_bito_prompt_explain', "What does that code do")
let g:vim_bito_prompt_generate_comment = get(g:, 'vim_bito_prompt_generate_comment', "Generate a comment for this method, explaining the parameters and output")
let g:vim_bito_prompt_check_performance = get(g:, 'vim_bito_prompt_check_performance', "Check code for performance issues, explain the issues, and rewrite code if possible")
let g:vim_bito_prompt_check = get(g:, 'vim_bito_prompt_check', "Identify potential issues that would find in this code, explain the issues, and rewrite code if possible")
let g:vim_bito_prompt_check_security = get(g:, 'vim_bito_prompt_check_security', "Check code for security issues, explain the issues, and rewrite code if possible")
let g:vim_bito_prompt_readable = get(g:, 'vim_bito_prompt_readable', "Organize the code to be more human readable")
let g:vim_bito_prompt_check_style = get(g:, 'vim_bito_prompt_check_style', "Check code for style issues, explain the issues, and rewrite code if possible")
function! BitoAiGenerate()
    let l:input = input("Bito prompt：")

    if l:input == ""
        echo "Please Input Context!"
        return
    endif
    call BitoAiExec('generate', l:input)
endfunction

function! BitoAiSelected(prompt)
    let l:start = getpos("'<")[1]
    let l:end = getpos("'>")[1]
    let l:lines = getline(l:start, l:end)
    let l:text = join(l:lines, "\n")

    if l:text == ""
        return
    endif
    call BitoAiExec(a:prompt, l:text)
endfunction

function! BitoAiExec(prompt, input)
    let l:tempFile = tempname()
    call writefile(split(a:input, "\n"), l:tempFile)
    let l:common_content = readfile(g:vim_bito_plugin_path . '/templates/common.txt')
    if (a:prompt == "generate")
        let l:common_content = readfile(g:vim_bito_plugin_path . '/templates/generate.txt')
    endif
    if exists('g:vim_bito_prompt_' . a:prompt)
        let l:prompt = execute('echo g:vim_bito_prompt_' . a:prompt) . ' ' . g:vim_bito_prompt_append
    else
        echomsg "Undefined variable: g:vim_bito_prompt_" . a:prompt
        return
    endif

    let l:replaced_content = []
    for line in l:common_content
        let l:replaced_line = substitute(line, '{{:prompt:}}', l:prompt, '')
        call add(l:replaced_content, l:replaced_line)
    endfor

    let l:templatePath = tempname()
    call writefile(l:replaced_content, l:templatePath)

    let l:cmdList = [g:vim_bito_path, '-p', l:templatePath, '-f', l:tempFile]
    if has('nvim')
        let job = jobstart(l:cmdList, {'on_stdout': 'BiAsyncCallback'})
    else
        let job = job_start(l:cmdList, {'out_cb': 'BiAsyncCallback', 'in_io': 'null'})
    endif

endfunction

function! s:BitoAiFindBufferNo(job_id)
    let l:buf_list = tabpagebuflist()
    let l:buf_no = 0
    let s:bito_buffer_name = g:bito_buffer_name_prefix . a:job_id

    for buf in l:buf_list
        if getbufvar(buf, '&filetype') == 'bito' && bufname(buf) == s:bito_buffer_name
            let l:buf_no = buf
            break
        endif
    endfor

    if l:buf_no == 0
        exec 'vs ' . s:bito_buffer_name
        execute 'set filetype=bito'
        setlocal norelativenumber swapfile bufhidden=hide
        setlocal buftype=nofile
        let l:buf_no = bufnr("%")
    endif

    return l:buf_no
endfunction

function! BiAsyncCallback(job_id, data, ...)
    let g:bito_job_list = get(g:, 'bito_job_list', {})
    let g:bito_job_list[a:job_id] = get(g:bito_job_list, a:job_id, 1)

    let l:buf_no = s:BitoAiFindBufferNo(a:job_id)

    if has('nvim')
        let l:line_text = get(getbufline(l:buf_no, g:bito_job_list[a:job_id]), 0, '')
        for line in range(1, len(a:data))
            if line == 1
                call setbufline(l:buf_no, g:bito_job_list[a:job_id], l:line_text . a:data[line - 1])
            else
                call appendbufline(l:buf_no, '$',  a:data[line - 1])
                let g:bito_job_list[a:job_id] = g:bito_job_list[a:job_id] + 1
            endif
        endfor
    else
        call appendbufline(l:buf_no, '$', a:data)
    endif
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
