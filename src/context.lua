local class = require("middleclass")

local lctx = {}

local Context = class("Context")

function Context:_start() end

function Context:_finish() end

function Context:_on_success(result) end

function Context:_on_error(err) error("Context error: " .. tostring(err)) end

local AsyncContext = class("AsyncContext", Context)

function AsyncContext:_astart()
    return coroutine.create(function()
        self:_start()
    end)
end

function AsyncContext:_afinish()
    return coroutine.create(function()
        self:_finish()
    end)
end

function lctx.with(context, func)
    if not context.class or not context:isInstanceOf(Context) then
        error("Context is not subclass of Context.")
    end

    context:_start()

    local success, result = pcall(func, context)
    if not success then
        context:_on_error(result)
    else
        context:_on_success(result)
    end

    context:_finish()

    return result
end

function lctx.awith(context, func)
    if not context.class or not context:isInstanceOf(AsyncContext) then
        error("Context is not subclass of AsyncContext.")
    end

    local co = coroutine.create(function()
        local success, result = pcall(func, context)
        if not success then
            context:_on_error(result)
        else
            context:_on_success(result)
        end

        coroutine.yield(context:_afinish())

        return result
    end)

    coroutine.resume(context:_astart())

    local status, finisher = coroutine.resume(co)
    if status and coroutine.status(finisher) == "suspended" then
        coroutine.resume(finisher)
    end

    return select(2, coroutine.resume(co))
end

function lctx.decorate(context, decorator_func)
    if not context.class or not context:isInstanceOf(Context) then
        error("Context is not subclass of Context.")
    end

    local decorated_context = setmetatable({}, { __index = context })

    decorator_func(decorated_context)

    return decorated_context
end

lctx.Context = Context
lctx.AsyncContext = AsyncContext

return lctx
