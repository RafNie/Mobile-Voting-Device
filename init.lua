--This file is init.lua
local IDLE_AT_STARTUP_MS = 4000;

tmr.alarm(1,IDLE_AT_STARTUP_MS,0,function()
    dofile("application.lua") --Write your program name in dofile
end)
