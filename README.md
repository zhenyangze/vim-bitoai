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
if !exists("g:vim_bito_promote_{command}")
    let g:vim_bito_promote_{command} = "your promote"
endif

" if should select code
command! -range -nargs=0 BitoAi{Command} :call BitoAiSelected('{command}')
```
should replace the `{command}` with your self
