local M = {}

M.HookTable = {}
M.AllRequestedEvents = {}

M.EventList = {}

local function findKey(key, table)
    for _, v in ipairs(table) do
        if v == key then
            return true
        end
    end

    return false
end

function M.addHook(hook)
    table.insert(M.HookTable, hook)

    -- if hook's event is not already in M.AllRequestedEvents, add it
    if type(hook.event) == "string" then
        if not findKey(hook.event, M.AllRequestedEvents) then
            table.insert(M.AllRequestedEvents, hook.event)
        end
        return
    end

    if type(hook.event) == "table" then
        for _, event in ipairs(hook.event) do
            if not findKey(event, M.AllRequestedEvents) then
                table.insert(M.AllRequestedEvents, event)
            end
        end
    end
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
                    if type(v.event) == "string" then
                        if findKey(v.event, M.EventList) then
                            v.run()
                        end
                    end

                    if type(v.event) == "table" then
                        for _, event in ipairs(v.event) do
                            if findKey(event, M.EventList) then
                                v.run()
                            end
                        end
                    end
                end

                M.EventList = {}
            end))
        end
    })

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

return M
