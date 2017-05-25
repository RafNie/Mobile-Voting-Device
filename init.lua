--This file is init.lua
local IDLE_AT_STARTUP_MS = 4500;

tmr.alarm(1,IDLE_AT_STARTUP_MS,0,function()
    dofile("application.lua")
end) 
