local P=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local H=game:GetService("HttpService")
local old=P:FindFirstChild("TWC_Record") if old then old:Destroy() end
local G=Instance.new("ScreenGui") G.Name="TWC_Record" G.ResetOnSpawn=false G.DisplayOrder=10020 G.Parent=P
local function ui(c,text,x,y,w,h)
 local o=Instance.new(c) o.Text=text o.Position=UDim2.fromOffset(x,y) o.Size=UDim2.fromOffset(w,h)
 o.BackgroundColor3=Color3.fromRGB(25,40,58) o.TextColor3=Color3.new(1,1,1) o.TextSize=14 o.TextWrapped=true o.Parent=G return o
end
local label=ui("TextLabel","กำลังเก็บข้อมูล UI • เปิดเมนูแรงค์ได้เลย",8,170,276,46)
local copy=ui("TextButton","คัดลอกข้อมูล",8,218,190,32)
local close=ui("TextButton","ปิด",202,218,82,32)
local history,last,ids={},{},{} local nextId=0 local current={}
local function path(o)
 local a={} while o and o~=P do table.insert(a,1,o.Name) o=o.Parent end return table.concat(a,"/")
end
local function visible(o)
 while o and o~=P do
  if o:IsA("GuiObject") and not o.Visible then return false end
  if o:IsA("ScreenGui") and not o.Enabled then return false end
  o=o.Parent
 end return o==P
end
local function short(t)
 local ok,n=pcall(utf8.offset,t,151) return ok and n and t:sub(1,n-1) or t
end
local function scan()
 local rows={} local live={}
 for _,o in ipairs(P:GetDescendants()) do
  local name=path(o)
  if not o:IsDescendantOf(G) and not name:find("TWC_",1,true) and not name:find("DailySpin",1,true)
   and not name:lower():find("chat",1,true) and (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) then
   if not ids[o] then nextId=nextId+1 ids[o]=nextId end
   local id=ids[o] local show=visible(o) local text=short(o.Text)
   live[id]=true
   if show then
    local parent=o local clickable
    while parent and parent~=P do if parent:IsA("GuiButton") then clickable=path(parent) break end parent=parent.Parent end
    local row={id=id,path=name,text=text,class=o.ClassName,button=clickable,x=math.floor(o.AbsolutePosition.X),y=math.floor(o.AbsolutePosition.Y)}
    if #rows<180 then table.insert(rows,row) end
    if last[id] and (last[id].text~=text or not last[id].visible) and text~="" and not text:match("^[%d%.]+$") and not o:IsA("TextBox") then
     table.insert(history,{path=name,text=text,button=clickable})
    end
   end
   last[id]={text=text,visible=show}
  end
 end
 for o,id in pairs(ids) do if not live[id] then ids[o]=nil last[id]=nil end end
 while #history>80 do table.remove(history,1) end
 current=rows
end
copy.Activated:Connect(function()
 local ok,err=pcall(function()
  scan()
  local data=H:JSONEncode({version=2,placeId=game.PlaceId,current=current,changes=history})
  assert(type(setclipboard)=="function","setclipboard unavailable") setclipboard(data)
  label.Text="คัดลอกแล้ว • วางข้อมูลกลับมาในแชต"
 end)
 if not ok then label.Text=tostring(err) end
end)
close.Activated:Connect(function() G:Destroy() end)
task.spawn(function()
 while G.Parent do
  local ok,err=pcall(scan)
  if not ok then label.Text=tostring(err) end
  task.wait(0.3)
 end
end)
