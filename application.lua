---------------- main program
--Configuration Access Point WiFi
print("WiFi Configuration...")
ipcfg = {}
ipcfg.ip="192.168.1.1"
ipcfg.netmask="255.255.255.0"
ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg) 
cfg={}
cfg.ssid="vote.com"
cfg.pwd="vote.com"
cfg.max=1
wifi.ap.config(cfg) 
wifi.setmode(wifi.SOFTAP)

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
cnt = 25
red=nil
green=nil
blue=1
alreadyoff=0
--------------------

--LED config
pwm.setup(5,100,0) 
pwm.setup(6,100,0) 
pwm.setup(7,100,0)
pwm.start(5) 
pwm.start(6) 
pwm.start(7)
-------------------------

--placing a server
if sv then                
    print("server already is placed") 
else                      
    print("placing the server")
    sv = net.createServer(net.TCP, 30)
end
------------------------

--authentication system
function random(usernumber,read)
    if read==nil then
        read=0
    end
    local pinfile=' '
    local a=0
    local b=0
    if read==1 then
        file.open("pins.txt")
        pinfile=file.read()
        file.close()
        for k,v in pairs(user) do user[k]=0 end
        for i=usernumber, 1,-1 do
            b,a=string.find(pinfile,'\n')
            user[tonumber(string.sub(pinfile,1,b-1))]=1
            pinfile=string.sub(pinfile,a+1,string.len(pinfile))
        end
    else        
        math.randomseed( tmr.now() )
        while b~=usernumber
        do
            a=math.random(10000,99999)
            if user[a] == nil then
                user[a]=1
                b=b+1
            end
        end
        for k,v in pairs(user) do pinfile=k..'\n'..pinfile end
        file.remove("pins.txt")
        file.open("pins.txt","w+")
        file.write(pinfile)
        file.close()
    end 
    --for k,v in pairs(user) do print(k.." "..v) end
    collectgarbage("collect")    
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
        errormes="Vote counted"
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
    else
        errormes="Vote not counted"           
    end
    collectgarbage("collect")
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
        wifi.ap.config(cfg) 
        adminstart=2
    end
    if button=="RANDOM" or button=="READ+FROM+FILE" then
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
                if button=="READ+FROM+FILE" then 
                    random(usernumber,1)
                    adminstart=1
                else
                    random(usernumber)
                    adminstart=1
                end
            else
                errormes="Number of users has to be between 0 and 8"
            end
        end
    end
    collectgarbage("collect")
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
        send(sck,1)
        alreadysent=1
    end
    if string.find(data, "results.html") then
        send(sck,4)
        alreadysent=1
    end
    if string.find(data, "result_final.html") then
        send(sck,2)
        alreadysent=1
    end 
    if string.find(data, "script.js") then
        send(sck,3)
        alreadysent=1
    end
    if alreadysent==0 then
        send(sck)
    end 
    collectgarbage("collect")       
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
        for k,v in pairs(user) do piny=k.."<br>"..piny end
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
    if voted==1 or voted==4 then
        file.open("results.html")
        page=file.read()
        file.close()
        if ((math.max(yesnumber,nonumber))>(usernumber*threshold/100)) then
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
        elseif yesnumber+nonumber==usernumber then
            if page  == nil then
                page = "<html><h1>ERROR</h1></html>"                       
            end
            page = string.gsub(page, "#TT", title)
            page = string.gsub(page, "#LG", yesnumber+nonumber)
            page = string.gsub(page, "#LT", yesnumber)
            page = string.gsub(page, "#LN", nonumber)
            page = string.gsub(page, "#W", "Voting threshold not achieved")    
        else
            local a
            local b
            page = string.gsub(page, "#TT", title)
            b,a=string.find(page,'<div id="result">')
            b=string.find(page,"</div>")            
            page=string.gsub(page,string.sub(page,a+1,b-1),"Voting is still ongoing")
        end
        if voted==4 then
            page=string.gsub(page,"#ERROR"," ")
        else
            page=string.gsub(page,"#ERROR",errormes..'<br>')
            errormes=" "
        end
    end
    if voted==2 then
        if ((math.max(yesnumber,nonumber))>(usernumber*threshold/100)) then
            file.open("result_final.html")
            page=file.read()
            file.close()
            if page  == nil then
                page = "<html><h1>ERROR</h1></html>"                       
            end
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
        elseif yesnumber+nonumber==usernumber then
            file.open("result_final.html")
            page=file.read()
            file.close()
            if page  == nil then
                page = "<html><h1>ERROR</h1></html>"                       
            end
            page = string.gsub(page, "#LG", yesnumber+nonumber)
            page = string.gsub(page, "#LT", yesnumber)
            page = string.gsub(page, "#LN", nonumber)
            page = string.gsub(page, "#W", "Voting threshold not achieved")
        else
            page="Voting is still ongoing"
        end
    end
    if voted==3 then
        file.open("script.js")
        page=file.read()
        file.close()
    end
    sck:on("sent", function(sck) sck:close() end)    
    sck:send(page)
    collectgarbage("collect")
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
function falling ()
    if red and green and blue==nil then
        pwm.setduty(5,cnt*40)
        pwm.setduty(6,cnt*8)
        pwm.setduty(7,0)
    else
        if alreadyoff==0 then
            pwm.setduty(5,0)
            pwm.setduty(6,0)
            alreadyoff=1
        end
        if red then
            pwm.setduty(5,cnt*40)
        else
            pwm.setduty(5,0)
        end
        if green then
            pwm.setduty(6,cnt*40)
        else
            pwm.setduty(6,0)
        end
        if blue then
            pwm.setduty(7,cnt*40)
        else
            pwm.setduty(7,0)
        end
    end
    cnt = cnt-1
    if cnt==0 then
        tmr.stop(2)        
        cnt = 25
        tmr.alarm(2,100,1,rising)
    end
end
function rising()
    if red and green and blue==nil then
        pwm.setduty(5,1000-cnt*40)
        pwm.setduty(6,200-cnt*8)
        pwm.setduty(7,0)
    else
        if alreadyoff==0 then
            pwm.setduty(5,0)
            pwm.setduty(6,0)
            alreadyoff=1
        end
        if red then
            pwm.setduty(5,1000-cnt*40)
        else
            pwm.setduty(5,0)
        end
        if green then
            pwm.setduty(6,1000-cnt*40)
        else
            pwm.setduty(6,0)
        end
        if blue then
            pwm.setduty(7,1000-cnt*40)
        else
            pwm.setduty(7,0)
        end
    end
    cnt = cnt-1
    if cnt==0 then
        tmr.stop(2)        
        cnt = 25
        tmr.alarm(2,100,1,falling)
    end
end
function colourchange()
    if adminstart==2 then
        if ((math.max(yesnumber,nonumber))>(usernumber*threshold/100)) then
            if yesnumber>nonumber then
                red=nil
                green=1
                blue=nil
            elseif yesnumber<nonumber then
                red=1
                green=nil
                blue=nil
            else
                red=1
                green=1
                blue=1                
            end
        else
            red=1
            green=1
            blue=nil            
        end 
    end           
end
tmr.alarm(2,100,1,rising)
tmr.alarm(1,500,1,colourchange)
-----------------------

--safety
print("End of the code")
