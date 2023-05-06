vim-bitoai
----

https://user-images.githubusercontent.com/15710584/236500940-12b82393-a7f5-4eb7-8369-ebcaacc2c0cd.mp4

## Install

1. install the bito cli

https://github.com/gitbito/CLI

2. install vim plugin

```
Plug 'zhenyangze/vim-bitoai'
```

3. change config

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
