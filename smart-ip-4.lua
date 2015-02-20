print("welcome to Andrew's ESP")
       -- A simple http server willy
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
  function checkips()

      if wifi.sta.getip() == nil then 
     staip = "Not Connected" 
     else staip = wifi.sta.getip()
    end 
    
    if wifi.ap.getip() == nil then 
     apip = "Not Connected" 
     else apip = wifi.ap.getip()
    end 
    
  end
    
    srv:listen(80,function(conn) --conn:on("receive", function()
     apple = "false"
    
    conn:on("receive",function(conn,payload) 

    if (string.find(payload, "POST /chz HTTP") or apple == "true") then

    local ssid, key = string.gmatch(payload, "ssid=(.*)&key=(.*)")()

    if ssid and key then -- TODO verify ssid and key more effectively
      apple = "false"
      wifi.sta.config(ssid, key)
      wifi.sta.connect()
      staip = wifi.sta.getip()
      conn:send('HTTP/1.1 200 OK\n\n') 
      conn:send('<head> <meta http-equiv="refresh" content="5;url=/"> </head>')
      conn:send('<html><body><h2>Done! Joining... please wait a few seconds ..</body></html>')
      conn:on("sent",function(conn) conn:close() end)
      else
      apple = "true"
    end


    
    elseif string.find(payload, "GET /wifi HTTP") then
  --elseif (path == "/wifi") then  
 checkips()

    --print("else arguement") 
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Wifi Configuration</h1><BR>")
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
  
  elseif string.find(payload, "GET /ip HTTP") then
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>New IP address is " .. staip .. "</h1><BR>")
    conn:send('<b><a href="/">click here</a></b><BR>')
    conn:send("</html></body>")
    conn:on("sent",function(conn) conn:close() end)
  else
    
checkips()
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Andrew Melvin's ESP Main Page: IP " .. staip .. "</h1><BR>")
    conn:send('<b>1. Configure wifi...<a href="/wifi">click here</a></b><BR>')
    conn:send("</html></body>")
    conn:on("sent",function(conn) conn:close() end)
  
  
    end
    
      end) 
      
      
  conn:on("sent",function(conn) conn:close() end)
    
  --end)
    end)

   
 
