vim-bitoai
----

https://user-images.githubusercontent.com/15710584/236500940-12b82393-a7f5-4eb7-8369-ebcaacc2c0cd.mp4

## Install

1. install the bito cli

`https://github.com/gitbito/CLI`

2. install and setup vim-plug (plugin manager)

`https://github.com/junegunn/vim-plug`

3. install vim plugin from inside vim

```
Plug 'vim-bitoai'
```

4. change config

```
" will show in buffers list
let g:bito_buffer_name_prefix = get(g:, 'bito_buffer_name_prefix', 'bito_history_')

" if your bito cli is not sys command, you should change the bito path
let g:vim_bito_path = get(g:, 'vim_bito_path', "bito")

" can change all the result of boti ,like: "Please translate the comment into chinses", "Please write the comment in chinses
let g:vim_bito_prompt_append = get(g:, 'vim_bito_prompt_append', "")
```



## *Usage*

- BitoAiGenerate
- BitoAiGenerateUnit
- BitoAiGenerateComment
- BitoAiCheck
- BitoAiCheckSecurity
- BitoAiCheckStyle
- BitoAiCheckPerformance
- BitoAiReadable
- BitoAiExplain



## Custom

```
if !exists("g:vim_bito_prompt_{command}")
    let g:vim_bito_prompt_{command} = "your prompt"
endif

" if should select code
command! -range -nargs=0 BitoAi{Command} :call BitoAiSelected('{command}')
```
should replace the `{command}` with your self

## Optional Hotkeys 
Add these to your vimrc using 
`vim ~/.vimrc`

```
call plug#begin('~/.vim/plugged')
Plug '~/Desktop/vim-bitoai'
call plug#end()

" Bito Vim Integration Key Bindings

" Generate code
xnoremap G :<C-U>BitoAiGenerate<CR>

" Generate code for a selected range in 'unit' mode
xnoremap U :<C-U>BitoAiGenerateUnit<CR>

" Generate code comments for a selected range
xnoremap C :<C-U>BitoAiGenerateComment<CR>

" Check code for potential issues for a selected range
xnoremap K :<C-U>BitoAiCheck<CR>

" Check code security for a selected range
xnoremap X :<C-U>BitoAiCheckSecurity<CR>

" Check code style for a selected range
xnoremap S :<C-U>BitoAiCheckStyle<CR>

" Check code performance for a selected range
xnoremap P :<C-U>BitoAiCheckPerformance<CR>

" Make code more readable for a selected range
xnoremap R :<C-U>BitoAiReadable<CR>

" Explain
xnoremap E :<C-U>BitoAiExplain<CR>
```

Example Usage of HotKeys:

1. Open a file: `vim create_doc_overview.sh`

2. Press `v` to enter visual mode.

3. Highlight text using the `arrow keys`

4. With Caps Lock ON, press `E` to explain the highlighted code.
