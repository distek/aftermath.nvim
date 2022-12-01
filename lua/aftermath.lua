local M = {}

M.HookTable = {}
M.AllRequestedEvents = {}

M.EventList = {}

local function init()
    for _, v in ipairs(M.AllRequestedEvents) do
        vim.api.nvim_create_autocmd(v, {
            pattern = { "*" },
            group = "Aftermath",

            callback = function(args)
                table.insert(M.EventList, args.event)
            end
        })
    end
end

function M.addHook(hook)
    table.insert(M.HookTable, hook)

    -- if hook's event is not already in M.AllRequestedEvents, add it
    for _, v in ipairs(M.AllRequestedEvents) do
        if v == hook.event then
            return
        end
    end
    table.insert(M.AllRequestedEvents, hook.event)
end

function M.removeHook(id)
    for i, v in ipairs(M.HookTable) do
        if v.id == id then
            table.remove(M.HookTable, i)
        end
    end
end

local function findKey(key, table)
    for _, v in ipairs(table) do
        if v == key then
            return true
        end
    end
    return false
end

function M.setup(config)
    init()

    vim.api.nvim_create_augroup("Aftermath", {
        clear = true
    })

    vim.api.nvim_create_autocmd("VimEnter", {
        pattern = {
            "*"
        },

        group = "Aftermath",

        callback = function()
            local timer = vim.loop.new_timer()
            timer:start(0, 50, vim.schedule_wrap(function()
                for _, v in ipairs(M.HookTable) do
                    if findKey(v.event, M.EventList) then
                        v.run()
                    end
                end

                M.EventList = {}
            end))
        end
    })
end

return M
