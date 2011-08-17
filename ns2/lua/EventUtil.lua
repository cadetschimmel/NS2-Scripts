
local dummyFunc = function()end
//force the creation of the hook table
Event.Hook("a", dummyFunc)

local HookTable = debug.getregistry()["Event.HookTable"]

setmetatable(HookTable, {
__index = function(self, key) 
	RawPrint(key)
	return rawget(self, key)
end
})

Event.RemoveHook = function(event, hook)
  
  local hookList = HookTable[event]

  if(not hookList) then
    RawPrint("There are no hooks set for an event named %s", event)
   return false
  end
  
  for i,hookEntry in ipairs(hookList) do
    if(hook == hookEntry) then
      table.remove(hookList, i)   

      if(#hookList == 0) then
        HookTable[event] = nil
      end
     return true
    end
  end
  
  return false
end

Event.RemoveHook("a", dummyFunc)