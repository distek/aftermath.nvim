# aftermath.nvim

_(Not sure if this will actually turn in to anything.)_

This started due to how events are handled in vim/neovim. I wanted a way to assign autocmds that run _after_ an event has finished. For some events such as WinClosed, the event is triggered prior to the window actually being closed, causing issues if you plan on interacting with the window that is to be focused.

## Installation

Your favorite plugin manager in the typical way:
- Packer:
```
use {
    'distek/aftermath.nvim',
    config = function()
        require('aftermath').setup()
    end
}
```

- Plug:
```
Plug 'distek/aftermath.nvim'
```

## Usage
Require `addHook` and add whatever you'd like.

This example adds a hook to run after `VimResized` is complete to ensure the width of [nvim-ide](https://github.com/ldelossa/nvim-ide)'s components are set back to a desired width:
```lua
local addHook = require('aftermath').addHook

addHook({
    -- id to be used with removeHook(id) should that be desired
    id = "auto-size-nvim-ide-components",
    
    -- description is purely for you, can be excluded (maybe something in the future)
    desc = "Automatically resize (horizontally) nvim-ide components when vim is resized",
    
    -- on which event to fire _after_
    event = "VimResized",
    
    -- callback function
    run = function()
        for _, v in ipairs(vim.api.nvim_list_wins()) do
            local name = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(v))
            if string.find(name, "component://*") then
                vim.api.nvim_win_set_width(v, 30)
                break
            end
            if string.find(name, "term://*") then
                vim.api.nvim_win_set_height(0, 20)
            end
        end
    end
})
```
