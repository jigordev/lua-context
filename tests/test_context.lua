local class = require("middleclass")
local lctx = require("lctx")

local function test_with_success()
    local TestContext = class("TestContext", lctx.Context)

    function TestContext:_start()
        self.started = true
    end

    function TestContext:_finish()
        self.finished = true
    end

    function TestContext:_on_success(result)
        self.success = true
    end

    function TestContext:_on_error(err)
        self.error = true
    end

    local context = TestContext:new()
    lctx.with(context, function(ctx)
        assert(ctx.started, "Context should be started")
        return "success"
    end)

    assert(context.success, "Context should handle success")
    assert(context.finished, "Context should be finished")
end

local function test_with_error()
    local TestContext = class("TestContext", lctx.Context)

    function TestContext:_start()
        self.started = true
    end

    function TestContext:_finish()
        self.finished = true
    end

    function TestContext:_on_success(result)
        self.success = true
    end

    function TestContext:_on_error(err)
        self.error = true
    end

    local context = TestContext:new()
    lctx.with(context, function(ctx)
        assert(ctx.started, "Context should be started")
        error("test error")
    end)

    assert(context.error, "Context should handle error")
    assert(context.finished, "Context should be finished")
end

local function test_async_with_success()
    local TestAsyncContext = class("TestAsyncContext", lctx.AsyncContext)

    function TestAsyncContext:_start()
        self.started = true
    end

    function TestAsyncContext:_finish()
        self.finished = true
    end

    function TestAsyncContext:_on_success(result)
        self.success = true
    end

    function TestAsyncContext:_on_error(err)
        self.error = true
    end

    local context = TestAsyncContext:new()
    lctx.awith(context, function(ctx)
        assert(ctx.started, "AsyncContext should be started")
        return "success"
    end)

    assert(context.success, "AsyncContext should handle success")
    assert(context.finished, "AsyncContext should be finished")
end

local function test_async_with_error()
    local TestAsyncContext = class("TestAsyncContext", lctx.AsyncContext)

    function TestAsyncContext:_start()
        self.started = true
    end

    function TestAsyncContext:_finish()
        self.finished = true
    end

    function TestAsyncContext:_on_success(result)
        self.success = true
    end

    function TestAsyncContext:_on_error(err)
        self.error = true
    end

    local context = TestAsyncContext:new()
    lctx.awith(context, function(ctx)
        assert(ctx.started, "AsyncContext should be started")
        error("test error")
    end)

    assert(context.error, "AsyncContext should handle error")
    assert(context.finished, "AsyncContext should be finished")
end

local function test_decorate()
    local TestContext = class("TestContext", lctx.Context)

    local context = TestContext:new()
    local decorated = lctx.decorate(context, function(ctx)
        ctx.decorated = true
    end)

    assert(decorated.decorated, "Context should be decorated")
end

local function runtests()
    test_with_success()
    test_with_error()
    test_async_with_success()
    test_async_with_error()
    test_decorate()
    print("All tests passed successfully!")
end

runtests()
