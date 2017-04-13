---------------------------------
-- This is application code

-----------------
-- Functions

function waitForWiFi()

   tmr.alarm (2, 500, tmr.ALARM_SEMI, function ( )
      if wifi.ap.getip ( ) == nil then
         print ("Waiting for Wifi setup")
      else
         tmr.stop (1)
         tmr.unregister(1)
         print ("The module MAC address is: " .. wifi.ap.getmac ( ))
         print ("Config done, IP is " .. wifi.ap.getip ( ))
         --dofile("dns.lc");
         
      end
   end)
end


local function connectionHandler (conn)   

   conn:on ("receive",
      function (connectionSoket, request_data)
         print(request_data)

         -- prepare response
         file.open("index.html")
            web_page=file.read()
         file.close() 
         
         if web_page  == nil then
            web_page = "Page not found"
         end
         
         OK_response = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"

         -- close connection after sending data
         connectionSoket:on("sent", function ()
            connectionSoket:close()
         end)   
         
         connectionSoket:send(OK_response..web_page)
         
      end)
end


----------------------
----------------------
-- Main program

-- AcessPoint configuration
cfg={}
cfg.ssid="VOTE SYSTEM";
cfg.channel=9
cfg.auth=AUTH_OPEN
wifi.ap.config(cfg)
wifi.setphymode(wifi.PHYMODE_G)
wifi.setmode (wifi.SOFTAP)

waitForWiFi()

-- print clients list for each new connected client
wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
    print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
end)

-- crate server
svr = net.createServer (net.TCP)
svr:listen (80, connectionHandler)
