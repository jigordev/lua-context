# lua-context

`lua-context` is a Lua library designed to facilitate context management in both synchronous and asynchronous environments. It provides a structured way to handle setup, execution, and teardown of operations within a defined context.

## Features

- **Context management**: Define custom contexts for operations with lifecycle methods.
- **Synchronous execution**: Use `with` to run functions within a synchronous context.
- **Asynchronous execution**: Use `awith` to run functions within an asynchronous context using coroutines.
- **Context decoration**: Extend existing contexts with additional behavior using `decorate`.

## Installation

To use `lua-context`, you need to have `middleclass` installed. You can install it via LuaRocks:

```sh
luarocks install middleclass
```

Then, require `lua-context` in your Lua script:

```lua
local lctx = require("lctx")
```

## Usage

### Defining a Context

A context is defined by creating a class that extends `Context` or `AsyncContext`. You can override lifecycle methods to customize the behavior.

#### Synchronous Context

```lua
local MyContext = class("MyContext", lctx.Context)

function MyContext:_start()
    print("Starting context")
end

function MyContext:_finish()
    print("Finishing context")
end

function MyContext:_on_success(result)
    print("Operation succeeded with result:", result)
end

function MyContext:_on_error(err)
    print("Operation failed with error:", err)
end
```

#### Asynchronous Context

```lua
local MyAsyncContext = class("MyAsyncContext", lctx.AsyncContext)

function MyAsyncContext:_astart()
    return coroutine.create(function()
        print("Starting async context")
    end)
end

function MyAsyncContext:_afinish()
    return coroutine.create(function()
        print("Finishing async context")
    end)
end

function MyAsyncContext:_on_success(result)
    print("Async operation succeeded with result:", result)
end

function MyAsyncContext:_on_error(err)
    print("Async operation failed with error:", err)
end
```

### Running Functions within a Context

#### Synchronous Execution

```lua
local my_context = MyContext:new()

lctx.with(my_context, function(ctx)
    print("Running operation within context")
    return "Success"
end)
```

#### Asynchronous Execution

```lua
local my_async_context = MyAsyncContext:new()

lctx.awith(my_async_context, function(ctx)
    print("Running async operation within context")
    return "Async Success"
end)
```

### Decorating a Context

You can add additional behavior to a context using the `decorate` method.

```lua
local my_context = MyContext:new()

local decorated_context = lctx.decorate(my_context, function(ctx)
    function ctx:_start()
        print("Decorator start")
        self.__index._start(self)
    end

    function ctx:_finish()
        print("Decorator finish")
        self.__index._finish(self)
    end
end)

lctx.with(decorated_context, function(ctx)
    print("Running decorated operation within context")
    return "Decorated Success"
end)
```

## API

### `with(context, func)`

Executes `func` within the provided `context`. Handles the context lifecycle (start, success, error, finish).

- `context`: An instance of a class extending `Context`.
- `func`: A function to execute within the context.

### `awith(context, func)`

Executes `func` within the provided `context` asynchronously. Handles the context lifecycle (start, success, error, finish) using coroutines.

- `context`: An instance of a class extending `AsyncContext`.
- `func`: A function to execute within the context.

### `decorate(context, decorator_func)`

Creates a new context by applying `decorator_func` to the provided `context`.

- `context`: An instance of a class extending `Context`.
- `decorator_func`: A function that takes a context and adds additional behavior.

## License

`lua-context` is released under the MIT License. See the [LICENSE](LICENSE) file for details.