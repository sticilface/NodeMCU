-- NOTE add = nil to some variables to release the memory!

k={}
function k.run()

print("wifi. config...")
    srv=net.createServer(net.TCP) 
    tmr.alarm(1,90000,0, function() file.open("sleep.txt", "w+") file.close() node.restart() end )
    
    local function lstf(t) if t then
    buf = " " ; checked = " checked"
     for k,_ in pairs(t) 
          do 
          --buf = buf .. "  " .. k 
          buf = buf .. '<input type="radio" name="ssid" value="' .. k .. '"' ..checked .. '>' .. k .. '<br/>\n'
          checked = ""
          end 
     end 
    end


if (wifi.getmode() == 2) then buf = '<input type="radio" name="ssid" value="AP" checked > AP mode set to station to enable scanning <br/>\n' else wifi.sta.getap(lstf) end

  local function checkips()

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
   
     local apple = "false"
    
    conn:on("receive",function(conn,payload) 
      --timer.stop(1)
    if (string.find(payload, "POST /chz HTTP") or apple == "true") then
     --print(payload)
    local ssid, key, mode = string.gmatch(payload, "ssid=(.*)&key=(.*)&mode=(.*)")()

    if ssid and key and mode then -- TODO verify ssid and key more effectively
      apple = "false"

     if (wifi.getmode() ~= mode) then 
          if mode ~= "1" then wifi.setmode(mode) 
          elseif mode == "1" then 
          changemode = "yes" 
          end
          end
      if (mode == "1" or mode == "3") then   
      wifi.sta.config(ssid, key)
      wifi.sta.connect()
      checkips()          
      end
      
      conn:send('HTTP/1.1 200 OK\n\n') 
      conn:send('<head> <meta http-equiv="refresh" content="10;url=/"> </head>')
      conn:send('<html><body><h2>Done!... please wait a few (10) seconds ..</body></html>')
      conn:on("sent",function(conn) conn:close() end)
      else
      apple = "true"
    end
       
    elseif string.find(payload, "GET /wifi HTTP") then
    
    checkips()
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Wifi Configuration</h1><BR>")
    conn:send("Wifi Mode : " .. wifi.getmode() .. "<BR>")
    conn:send("Station IP address :" .. staip .. "<BR>")
    conn:send("AP IP address :" .. apip .. "<BR>")
    conn:send('<h2>Choose a wifi access point to join</h2><p><form method="post" action="chz">')
    conn:send(buf)
    buf = nil
    conn:send('<br/>Pass key: <input type="textarea" name="key"><br/>')
    conn:send("<h2> Choose wifi Mode: </h2>")   
    conn:send('<input type="radio" name="mode" value="3" checked >AP + Station <input type="radio" name="mode" value="2" > AP only <input type="radio" name="mode" value="1" >Station <br>')
    conn:send('<br/><input type="submit" value="Submit"></form></p>')
    conn:send("</html></body>")
  
  else
    
    checkips()
    conn:send("HTTP/1.1 200 OK\n\n")
    conn:send("<html><body>")
    conn:send("<h1>Andrew Melvin's ESP Config Page: IP <a href=http://"..staip..">" .. staip .. "</a></h1><BR>")
    conn:send('<b>1. Configure wifi...<a href="/wifi">click here</a></b><BR>')
    conn:send("</html></body>")
    conn:on("sent",function(conn) conn:close() end)
  
    end  
      end) 
 
  conn:on("sent",function(conn) conn:close() end)
  
  if (changemode == "yes" and wifi.sta.status() == 5) then 
  --print(wifi.sta.status())
  tmr.alarm(0, 1000, 0, function() wifi.setmode(1) changemode = "no" 
  
  end)
  else wifi.setmode(oldmode)
  
   end 
    
    end)

  return nil
end

return k
   
 
