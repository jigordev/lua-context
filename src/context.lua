local class = require("middleclass")

local lctx = {}

-- Define the base Context class
local Context = class("Context")

-- Hook method called at the start of context execution
function Context:_start() end

-- Hook method called at the end of context execution
function Context:_finish() end

-- Hook method called when an operation succeeds
function Context:_on_success(result) end

-- Hook method called when an error occurs, throwing an error with the message
function Context:_on_error(err) error("Context error: " .. tostring(err)) end

-- Define AsyncContext class, which inherits from Context for asynchronous operations
local AsyncContext = class("AsyncContext", Context)

-- Method to asynchronously start the context
function AsyncContext:_astart()
    return coroutine.create(function()
        self:_start()
    end)
end

-- Method to asynchronously finish the context
function AsyncContext:_afinish()
    return coroutine.create(function()
        self:_finish()
    end)
end

-- Function to execute a function within a context lifecycle
function lctx.with(context, func)
    -- Check if the provided context is an instance of Context
    if not context.class or not context:isInstanceOf(Context) then
        error("Context is not subclass of Context.")
    end

    context:_start()

    -- Execute the function within a protected call and handle the result
    local success, result = pcall(func, context)
    if not success then
        context:_on_error(result)
    else
        context:_on_success(result)
    end

    context:_finish()

    -- Return the result of the function
    return result
end

-- Function to execute a function asynchronously within a context lifecycle
function lctx.awith(context, func)
    -- Check if the provided context is an instance of AsyncContext
    if not context.class or not context:isInstanceOf(AsyncContext) then
        error("Context is not subclass of AsyncContext.")
    end

    -- Create a coroutine for executing the function
    local co = coroutine.create(function()
        local success, result = pcall(func, context)
        if not success then
            context:_on_error(result)
        else
            context:_on_success(result)
        end

        -- Yield to allow the context to finish asynchronously
        coroutine.yield(context:_afinish())

        return result
    end)

    -- Start the context asynchronously
    coroutine.resume(context:_astart())

    -- Resume the coroutine to start the function execution
    local status, finisher = coroutine.resume(co)
    if status and coroutine.status(finisher) == "suspended" then
        coroutine.resume(finisher)
    end

    -- Return the result from the coroutine
    return select(2, coroutine.resume(co))
end

-- Decorate a context object with additional functionality
function lctx.decorate(context, decorator_func)
    -- Ensure the context is an instance of Context
    if not context.class or not context:isInstanceOf(Context) then
        error("Context is not subclass of Context.")
    end

    -- Create a new context object that references the original
    local decorated_context = setmetatable({}, { __index = context })

    -- Apply the decorator function to the new context
    decorator_func(decorated_context)

    return decorated_context
end

-- Attach classes to lctx for external use
lctx.Context = Context
lctx.AsyncContext = AsyncContext

-- Return the module
return lctx