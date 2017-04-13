--This file is init.lua
local WAIT_AT_STARTUP_MS = 4000;

tmr.alarm(1, WAIT_AT_STARTUP_MS, tmr.ALARM_SINGLE, function()
    dofile("application.lua") --Write your program name in dofile
end)
