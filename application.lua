---------- main program
--Configuration Access Point WiFi
print("WiFi Configuration...")
ipcfg = {}
ipcfg.ip="192.168.1.1"
ipcfg.netmask="255.255.255.0"
ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg) 
cfg={}
cfg.ssid="KAmodLSM303"
cfg.pwd="12345678"
wifi.ap.config(cfg) 
wifi.setmode(wifi.SOFTAP)
cfg.max=1
adminstart=0
----------------------

--Global variables
user={} --Uers table
yesnumber=0
nonumber=0
usernumber=0
title=" "
errormes=" "
threshold=0
--------------------

--placing a server
if sv then                
    print("server already is placed") 
else                      
    print("placing the server")
    sv = net.createServer(net.TCP, 30)
end
------------------------

--authentication system
function random(usernumber)
    local a=0
    local b=0
    math.randomseed( tmr.now() )
    while b~=usernumber
    do
        a=math.random(10000,99999)
        if user[a] == nil then
            user[a]=1
            b=b+1
        end
    end
     
end     
------------------------

--not important who votes, important who count the vote
function votescounting(data)
    local pin=0
    local d=0
    local c=0
    d,c=string.find(data,"&usr=")
    d=string.find(data, " HTTP")
    if c then
        pin=string.sub(data, c+1,d)
    end
    pin=tonumber(pin)
    if user[pin]==1 then
        i=string.find(data, "v=YES")
        if i then
            yesnumber=yesnumber+1
            print("YES: "..yesnumber)
            user[pin]="yes"
        end
        i=string.find(data, "v=NO")
        if i then
            nonumber=nonumber+1
            print("NO: "..nonumber)
            user[pin]="no"
        end  
        print(pin.." voted "..user[pin])  
    end
    
end
---------------------------

--Admin Settings analysis
function adminanalysis(data)
    local dat=" "
    local d=0
    local c=0
    local button=" "
    local buff=" "
    dat=data    
    d,c=string.find(dat,"v=")
    d=string.find(dat, " HTTP")
    button=string.sub(dat, c+1,d-1)    
    if button=="START" then
        cfg.max=usernumber
        adminstart=2
    end
    if button=="RANDOM" then
        d,c=string.find(dat,"XTITLEX=")
        d=string.find(dat, "&XUSERNUMBERX=")
        title=string.sub(dat, c+1,d-1)
        dat=string.sub(dat,d)
        d=0
        title=string.gsub(title, "+", " ")
        while(string.find(title, "%%", d)) do           
            c,d=string.find(title, "%%",d)
            buff=string.sub(title, c+1,c+2)
            title=string.gsub(title,"%%"..buff,string.char(tonumber(buff, 16)))
        end    
        d,c=string.find(dat,"&XUSERNUMBERX=")
        d=string.find(dat, "&XTHRESHOLDX")
        usernumber=tonumber(string.sub(dat, c+1,d-1))
        dat=string.sub(dat,d)
        d,c=string.find(dat,"XTHRESHOLDX=")
        d=string.find(dat, "&v=")
        threshold=tonumber(string.sub(dat, c+1,d-1))
        --print(title.." "..usernumber.." "..threshold.." ".. button)
        if usernumber and threshold and title then
            if usernumber<=8 and usernumber>0 then
                random(usernumber)
                adminstart=1
            else
                errormes="Number of users has to be between 0 and 8"
            end
        end
    end
end
----------------------------

--service events - connection through port 80
function receiver(sck, data)
    local i
    local j
    local alreadysent
    alreadysent=0
    if string.find(data,"favicon")==nil then    
        print(data)
    end
    i,j=string.find(data, "\n")
    data=string.sub(data, 1,j)  
    if adminstart==0 or adminstart==1 then  
        if string.find(data, "admin.html") then
            adminanalysis(data)
        end
        if string.find(data, "admin1.html") then
            adminanalysis(data)
        end
    end   
    if string.find(data, "index.html") then
        votescounting(data)
        if ((math.max(yesnumber,nonumber))>(usernumber*threshold/100)) then
            send(sck,1)
            alreadysent=1
        end
    end 
    if alreadysent==0 then
        send(sck)
    end        
end
----------------------

--sending pages
function send(sck,voted)
    if voted==nil then
        voted=0
    end
   -- local pack={}
    local piny=" "
    local page=nil
   -- local response= "HTTP/1.1 200 OK \r\nContent-Type: text/html\r\n\r\n"  
    if adminstart==0 then          
        file.open("admin.html")
        page=file.read()
        file.close()
        if page  == nil then
            page = "<html><h1>ERROR</h1></html>"                       
        end
        page = string.gsub(page,"#ERROR", errormes)     
    end
    if adminstart==1 then
        file.open("admin1.html")
        page=file.read()
        file.close()
        if page  == nil then
            page = "<html><h1>ERROR</h1></html>"                       
        end
        for k,v in pairs(user) do piny=piny.."<br>"..k end
        page=string.gsub(page,"#P",piny)
        page = string.gsub(page, "#TT", title)
        page = string.gsub(page, "#LU", usernumber)
    end
    if adminstart==2 then
        file.open("index.html")
        page=file.read()
        file.close()
        if page  == nil then
            page = "<html><h1>ERROR</h1></html>"                       
        end
        page = string.gsub(page, "#TT", title)
       -- pack=response..site
    end
    if voted==1 then
        file.open("results.html")
        page=file.read()
        file.close()
        if page  == nil then
            page = "<html><h1>ERROR</h1></html>"                       
        end
        page = string.gsub(page, "#TT", title)
        page = string.gsub(page, "#LG", yesnumber+nonumber)
        page = string.gsub(page, "#LT", yesnumber)
        page = string.gsub(page, "#LN", nonumber)
        if yesnumber>nonumber then
            page = string.gsub(page, "#W", "YES")
        elseif nonumber>yesnumber then
            page = string.gsub(page, "#W", "NO")
        else
            page = string.gsub(page, "#W", "DRAW")
        end
       -- pack=response..site
    end
    sck:on("sent", function(sck) sck:close() end)    
    sck:send(page)  
end  
-----------------------

--listening on port 80
if sv then
  sv:listen(80, function(conn)
    conn:on("receive", receiver)    
    end)
end
------------------------

--LED
gpio.mode(0, gpio.OUTPUT)        
ledon = 1                        
tmr.alarm(0, 1000, 1,            
  function ()
    if ledon == 0 then            
      gpio.write(0, gpio.HIGH)
      ledon = 1
    else                         
      gpio.write(0, gpio.LOW)
      ledon = 0
    end
  end
)
-------------------------

--safety
print("End of the code")
