--New init.lua AMELVIN.... wifi config

if file.open("sleep.txt") then  -- we're already configured
  file.close()
  file.remove("sleep.txt")
  f=require("f")
  f.run()
  --dofile("f.lua")
else
  k=require("smart-ip-5")
  oldmode = wifi.getmode()
  wifi.setmode(wifi.STATIONAP)    -- coding around nil result to first call issue
  k.run() 
  k = nil
  --smart-ip-5 = nil -- joinme entry point
  --dofile("smart-ip-5.lu")
end -- wifi config