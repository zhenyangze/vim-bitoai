" ---------------------------------------------------------------------------------------------------
" Ensure the plugin is only loaded once to avoid multiple invocations.
" ---------------------------------------------------------------------------------------------------
if exists('g:loaded_vim_bito')
    finish
endif

" ---------------------------------------------------------------------------------------------------
" Register markdown as a language for treesitter in Neovim for better syntax highlighting.
" ---------------------------------------------------------------------------------------------------
if has('nvim')
    lua vim.treesitter.language.register('markdown', 'bito')
endif

" This variable ensures the plugin is loaded only once.

" This variable ensures the plugin is loaded only once.
let g:loaded_vim_bito = 1

" ---------------------------------------------------------------------------------------------------
" Set default configuration and paths.
" ---------------------------------------------------------------------------------------------------
let g:bito_buffer_name_prefix = get(g:, 'bito_buffer_name_prefix', 'bito_history_')

" Get the directory path where this Vim script resides. Useful when accessing
" other related files or templates in the same directory.

" Get the directory path where this Vim script resides. Useful when accessing
" other related files or templates in the same directory.
let g:vim_bito_plugin_path = fnamemodify(expand('<sfile>:p:h'), ':p')

" Set default prompts for Bito interactions. These can be customized by users
" in their vimrc to suit their needs.

" Set default prompts for Bito interactions. These can be customized by users
" in their vimrc to suit their needs.
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

" ---------------------------------------------------------------------------------------------------
" Main function to generate code. It prompts the user for context and interfaces with Bito.
" ---------------------------------------------------------------------------------------------------
function! BitoAiGenerate()
    " Prompt the user for input.
    " Prompt the user for input.
    let l:input = input("Bito prompt：")

    " If no input is provided, show an error message and return.
    " If no input is provided, show an error message and return.
    if l:input == ""
        echo "Please Input Context!"
        return
    endif

    " Execute the Bito command with the 'generate' prompt.

    " Execute the Bito command with the 'generate' prompt.
    call BitoAiExec('generate', l:input)
endfunction

" ---------------------------------------------------------------------------------------------------
" Utility function to work on a selected range, sending it to Bito for processing.
" ---------------------------------------------------------------------------------------------------
function! BitoAiSelected(prompt)
    " Get the start and end line numbers of the selected text.
    " Get the start and end line numbers of the selected text.
    let l:start = getpos("'<")[1]
    let l:end = getpos("'>")[1]

    " Fetch the lines from the start to the end of the selection.

    " Fetch the lines from the start to the end of the selection.
    let l:lines = getline(l:start, l:end)
    let l:text = join(l:lines, "\n")

    " If there's no selected text, simply return.
    " If there's no selected text, simply return.
    if l:text == ""
        return
    endif

    " Execute the Bito command using the provided prompt.

    " Execute the Bito command using the provided prompt.
    call BitoAiExec(a:prompt, l:text)
endfunction

" ---------------------------------------------------------------------------------------------------
" Core function to interact with Bito. Manages input files, templates, and the Bito executable.
" ---------------------------------------------------------------------------------------------------
function! BitoAiExec(prompt, input)
    " Write the input to a temporary file for Bito to process.
    " Write the input to a temporary file for Bito to process.
    let l:tempFile = tempname()
    call writefile(split(a:input, "\n"), l:tempFile)

    " Load the appropriate Bito template based on the prompt.

    " Load the appropriate Bito template based on the prompt.
    let l:common_content = readfile(g:vim_bito_plugin_path . '/templates/common.txt')
    if (a:prompt == "generate")
        let l:common_content = readfile(g:vim_bito_plugin_path . '/templates/generate.txt')
    endif

    " Fetch the correct Bito prompt based on the given argument.

    " Fetch the correct Bito prompt based on the given argument.
    if exists('g:vim_bito_prompt_' . a:prompt)
        let l:prompt = execute('echo g:vim_bito_prompt_' . a:prompt) . ' ' . g:vim_bito_prompt_append
    else
        echomsg "Undefined variable: g:vim_bito_prompt_" . a:prompt
        return
    endif

    " Replace placeholders in the Bito template with the actual values.
    " Replace placeholders in the Bito template with the actual values.
    let l:replaced_content = []
    for line in l:common_content
        let l:replaced_line = substitute(line, '{{:prompt:}}', l:prompt, '')
        call add(l:replaced_content, l:replaced_line)
    endfor

    " Write the replaced content to another temporary file.
    " Write the replaced content to another temporary file.
    let l:templatePath = tempname()
    call writefile(l:replaced_content, l:templatePath)

    " Run Bito using the constructed templates and the input file.
    " Run Bito using the constructed templates and the input file.
    let l:cmdList = [g:vim_bito_path, '-p', l:templatePath, '-f', l:tempFile]
    if has('nvim')
        let job = jobstart(l:cmdList, {
                    \ 'on_stdout': 'BiAsyncCallback',
                    \ 'on_exit': 'BitoJobExit',
                    \ 'stdin': 'null'
                    \ })
    else
        let job = job_start(l:cmdList, {
                    \ 'out_cb': 'BiAsyncCallback',
                    \ 'exit_cb': 'BitoJobExit',
                    \ 'in_io': 'null'
                    \ })
    endif
endfunction


" ---------------------------------------------------------------------------------------------------
" Functions to manage the buffer for Bito outputs.
" ---------------------------------------------------------------------------------------------------
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

" Initialize a global variable for the job status
let g:bito_jobs_opened = {}

function! BitoJobExit(job_id, exit_status, event_type)
    " If the job has not been opened in a buffer before, jump to it
    if !get(g:bito_jobs_opened, a:job_id, 0)
        let l:buf_no = s:BitoAiFindBufferNo(a:job_id)
        call win_gotoid(bufwinid(l:buf_no))
    endif

    " Cleanup: remove the job_id from the global tracking
    unlet g:bito_jobs_opened[a:job_id]
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
    " Mark the job as having received data
    let g:bito_jobs_opened[a:job_id] = 1
endfunction


" ---------------------------------------------------------------------------------------------------
" Vim commands for easy access to Bito functionalities.
" ---------------------------------------------------------------------------------------------------

" Define a command for generating code with Bito.
" This doesn't take any arguments and is a straightforward way to prompt the user and generate code.
command! -nargs=0 BitoAiGenerate :call BitoAiGenerate()

" Define a command for generating code with Bito for a selected range in 'unit' mode.
" This uses the range provided by the user to determine the text to use as input for Bito.

" Define a command for generating code with Bito for a selected range in 'unit' mode.
" This uses the range provided by the user to determine the text to use as input for Bito.
command! -range -nargs=0 BitoAiGenerateUnit :call BitoAiSelected('generate_unit')

" Define a command for generating code comments with Bito for a selected range.

" Define a command for generating code comments with Bito for a selected range.
command! -range -nargs=0 BitoAiGenerateComment :call BitoAiSelected('generate_comment')

" Define a command for checking code with Bito for a selected range.

" Define a command for checking code with Bito for a selected range.
command! -range -nargs=0 BitoAiCheck :call BitoAiSelected('check')

" Define a command for checking code security with Bito for a selected range.

" Define a command for checking code security with Bito for a selected range.
command! -range -nargs=0 BitoAiCheckSecurity :call BitoAiSelected('check_security')

" Define a command for checking code style with Bito for a selected range.

" Define a command for checking code style with Bito for a selected range.
command! -range -nargs=0 BitoAiCheckStyle :call BitoAiSelected('check_style')

" Define a command for checking code performance with Bito for a selected range.

" Define a command for checking code performance with Bito for a selected range.
command! -range -nargs=0 BitoAiCheckPerformance :call BitoAiSelected('check_performance')

" Define a command for making code more readable with Bito for a selected range.

" Define a command for making code more readable with Bito for a selected range.
command! -range -nargs=0 BitoAiReadable :call BitoAiSelected('readable')

" Define a command for explaining code with Bito for a selected range.

" Define a command for explaining code with Bito for a selected range.
command! -range -nargs=0 BitoAiExplain :call BitoAiSelected('explain')
