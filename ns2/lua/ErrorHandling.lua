local function UnsafeDispatcher(func, eh, ...)
  return true, func(...)
end

local function CreateDispatcher(argCount)
  
  if(decoda_output) then
		return UnsafeDispatcher
	end
  
	local code = [[
	  local xpcall = ...
    
	  local method, ARGS
	  local function call() return method(ARGS) end
    
	  local function dispatch(func, eh, ...)
	    method = func
	  	ARGS = ...
	  	return xpcall(call, eh)
	  end
    
	  return dispatch
	]]

	local ARGS = {}
	for i = 1, argCount do
	  ARGS[i] = "arg"..i 
	end
	
	code = code:gsub("ARGS", table.concat(ARGS, ", "))
	return assert(loadstring(code, "Xpcall Dispatcher["..argCount.."]"))(xpcall)
end

local Dispatchers = setmetatable({  
  [0] = function(func, eh)
    return xpcall(func, eh)
  end,
  }, 
  
  {__index = function(self, argCount)
	  local dispatcher = CreateDispatcher(argCount)
	  rawset(self, argCount, dispatcher)
	  return dispatcher
  end}
)


function xpcall2(func, eh, ...)
  return Dispatchers[select('#', ...)](func, eh, ...)
end

function PrintStackTrace(err) 
	Shared.Message(debug.traceback(err, 1))
end

function SafeCall(func, ...)
  return xpcall2(func, PrintStackTrace, ...)
end