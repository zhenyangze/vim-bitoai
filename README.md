vim-bitoai
----

## Install

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
if !exists("g:vim_bito_promote_command")
    let g:vim_bito_promote_command = "your promote"
endif

" if should select code
command! -range -nargs=0 BitoAiCommand :call BitoAiSelected('command')
```
should replace the `command` with your self
