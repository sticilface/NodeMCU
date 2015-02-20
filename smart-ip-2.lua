print("welcome to Andrew's ESP")
       -- A simple http server
    srv=net.createServer(net.TCP) 
    
    function lstf(t) if t then
    buf = "" ; checked = " checked"
     for k,_ in pairs(t) 
          do 
          --buf = buf .. "  " .. k 
          buf = buf .. '<input type="radio" name="ssid" value="' .. k .. '"' ..checked .. '>' .. k .. '<br/>\n'
          checked = ""
          end 
     end 
     -- buf = string.gsub(wifiform, "_ITEMS_", buf)
     --print(buf)
    end

   -- local wifiform = [=[<h2>Choose a wifi access point to join</h2><p><form method="POST" action="chz">_ITEMS_<br/>Pass key: <input type="textarea" name="key"><br/><br/><input type="submit" value="Submit"></form></p>]=]


wifi.sta.getap(lstf)

--tmr.alarm(0, 60000, 1, function() wifi.sta.getap(lstf) print("scan called") end )

     
     if staip == null then staip = "None" end
     if apip == null then apip = "None" end
    
    srv:listen(80,function(conn) --conn:on("receive", function()

    
    conn:on("receive",function(conn,payload) 
     -- if string.find(payload, "POST /chz HTTP") then

     --print("processing web request: ", payload:sub(1, 11))
    print(payload)
    local _, _, method, path, vars = string.find(payload, "([A-Z]+) (.+)?(.+) HTTP");
    if (method ~= null) then print("Method = : "..method) end
    if (path ~= null) then print("path = : "..path) end
    if (vars ~= null) then print("vars = : "..vars) end
  if (vars ~= nill) then 
    ssid, key = string.gmatch(vars, "ssid=(.*)&key=(.*)")()
    print("SSID and KEY FOUND")
    --print("ssid "..ssid)
    --print("key " .. key)
    if ssid and key then -- TODO verify ssid and key more effectively
      --wifi.setmode(wifi.STATION)
      print("SSID:" .. ssid)
      print("key:" .. key)
      --wifi.sta.config(ssid, key)
      --wifi.sta.connect()
      conn:send("HTTP/1.1 200 OK\n\n <html><body><h2>Done! Joining...</h2></body></html>")
      --conn:on("sent", finish)
      conn:on("sent",function(conn) conn:close() end)
    end
    
  elseif (path == "/wifi") then  
 
    staip = wifi.sta.getip()
    apip = wifi.ap.getip()
    print("else arguement") 
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Served from Andrew's ESP8266</h1><BR>")
    conn:send("NODE.CHIPID : " .. node.chipid() .. "<BR>")
    conn:send("NODE.HEAP : " .. node.heap() .. "<BR>")
    conn:send("TMR.NOW : " .. tmr.now() .. "<BR>")
    conn:send("Wifi Mode : " .. wifi.getmode() .. "<BR>")
    conn:send("Station IP address :" .. staip .. "<BR>")
    conn:send("AP IP address :" .. apip .. "<BR>")
    conn:send('<h2>Choose a wifi access point to join</h2><p><form method="GET" action="chz">')
    conn:send(buf)
    conn:send('<br/>Pass key: <input type="textarea" name="key"><br/><br/><input type="submit" value="Submit"></form></p>')
    conn:send("</html></body>")
  else
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Main Page</h1><BR>")
  

    end
    
      end) 
      
      
  conn:on("sent",function(conn) conn:close() end)
    
  --end)
    end)

   
 
