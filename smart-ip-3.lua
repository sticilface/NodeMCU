print("welcome to Andrew's ESP")
       -- A simple http server
    srv=net.createServer(net.TCP) 
    
    function lstf(t) if t then
    buf = " " ; checked = " checked"
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
    staip = wifi.sta.getip()
    apip = wifi.ap.getip()
     
     if staip == nil then staip = "None" end
     if apip == nil then apip = "None" end
    
    srv:listen(80,function(conn) --conn:on("receive", function()
     apple = "false"
    
    conn:on("receive",function(conn,payload) 
    print("1")
    print(payload)
    print("2")
    if (string.find(payload, "POST /chz HTTP") or apple == "true") then
     print("3")
    --print("processing web request: ", payload:sub(1, 11))
     --print(payload)
    local ssid, key = string.gmatch(payload, "ssid=(.*)&key=(.*)")()
    print("4")
    --print("SSID and KEY FOUND")
    --print("ssid "..ssid)
    --print("key " .. key)
    if ssid and key then -- TODO verify ssid and key more effectively
    apple = "false"
    print("5")
      print(ssid.."  " .. key)
      --wifi.setmode(wifi.STATION)
      --print("SSID:" .. ssid)
      --print("key:" .. key)
      wifi.sta.config(ssid, key)
      wifi.sta.connect()
      --tmr.delay(10000000)
      staip = "nodone" -- wifi.sta.getip()
      --if staip == nil then staip = "Please refresh..." end 
      conn:send("HTTP/1.1 200 OK\n\n <html><body><h2>Done! Joining... IP is .. " .. staip .. " </h2></body></html>")
      --conn:on("sent", finish)
      conn:on("sent",function(conn) conn:close() end)
      else
      apple = "true"
    end
    
    else
  --elseif (path == "/wifi") then  
 

    --print("else arguement") 
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Served from Andrew's ESP8266</h1><BR>")
    conn:send("NODE.CHIPID : " .. node.chipid() .. "<BR>")
    conn:send("NODE.HEAP : " .. node.heap() .. "<BR>")
    conn:send("TMR.NOW : " .. tmr.now() .. "<BR>")
    conn:send("Wifi Mode : " .. wifi.getmode() .. "<BR>")
    conn:send("Station IP address :" .. staip .. "<BR>")
    conn:send("AP IP address :" .. apip .. "<BR>")
    conn:send('<h2>Choose a wifi access point to join</h2><p><form method="post" action="chz">')
    conn:send(buf)
    conn:send('<br/>Pass key: <input type="textarea" name="key"><br/><br/><input type="submit" value="Submit"></form></p>')
    conn:send("</html></body>")
  --else
    --conn:send("HTTP/1.1 200 OK\n\n")
    --conn:send("<html><body>")
    --conn:send("<h1>Main Page</h1><BR>")
  

    end
    
      end) 
      
      
  conn:on("sent",function(conn) conn:close() end)
    
  --end)
    end)

   
 
