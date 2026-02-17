repeat task.wait(1)until game:IsLoaded()repeat task.wait(1)until type(_G.Horst_SetDescription)=="function"
local a=game:GetService("Players")
local b=a.LocalPlayer
local c=_G.Horst_SetDescription
local d=""
local e=""
local function f(g)if type(g)~="string"then return false end;if g:find("Level%s*:%s*")and g:find("Gems%s*:%s*")and g:find("Gold%s*:%s*")then return true end;return false end;_G.Horst_SetDescription=function(h)if f(h)then if d~=""and c then pcall(c,d)end;return end;d=tostring(h or"")if c then pcall(c,d)end end
getgenv().SeenIceQueenAny=getgenv().SeenIceQueenAny or false
getgenv().SeenIceQueenShiny=getgenv().SeenIceQueenShiny or false
local function i()if not queue_on_teleport then return end;local j=([[getgenv().SeenIceQueenAny = %s getgenv().SeenIceQueenShiny = %s]]):format(tostring(getgenv().SeenIceQueenAny),tostring(getgenv().SeenIceQueenShiny))queue_on_teleport(j)end
local k="Ice Queen (Release)"
local function l()local m,n=false,false;local o,errmsg=pcall(function()local p=rawget(_G,"UnitWindowHandler")or _G.UnitWindowHandler or UnitWindowHandler;if not p or not p._Cache then return end;for _,q in pairs(p._Cache)do if q and q.UnitData and q.UnitData.Name==k then m=true;if q.UnitData.Rarity=="Shiny"or q.UnitData.Shiny==true then n=true end end end end)if not o then warn("[AVG HORST LOG] scanCacheForIceQueen error:",errmsg)end;return m,n end
local function r()local s=b:FindFirstChild("PlayerGui")if not s then return false end;local o,t=pcall(function()local u=s:FindFirstChild("Windows")local v=u and u:FindFirstChild("GlobalInventory")local w=v and v:FindFirstChild("Holder")local x=w and w:FindFirstChild("LeftContainer")local y=x and x:FindFirstChild("FakeScrollingFrame")local z=y and y:FindFirstChild("Items")local A=z and z:FindFirstChild("CacheContainer")if not A then return false end;for _,B in ipairs(A:GetChildren())do if not B:IsA("GuiObject")then continue end;local C=B:FindFirstChild("Container")C=C and C:FindFirstChild("Holder")C=C and C:FindFirstChild("Main")if not C then continue end;local D=C:FindFirstChild("UnitName")or C:FindFirstChild("Name")or C:FindFirstChild("Title")if not(D and D:IsA("TextLabel"))then continue end;local E=(D.Text or""):gsub("^%s*(.-)%s*$","%1")if E==k then return true end end;return false end)if not o then warn("[AVG HORST LOG] scanInventoryForIceQueenAny error:",t)return false end;return t end
local function F()local G,H=l()if not G then if r()then G=true end end;if G then getgenv().SeenIceQueenAny=true end;if H then getgenv().SeenIceQueenShiny=true end;i()return G,H end
local I=5;task.spawn(function()while task.wait(I)do local J=b:GetAttribute("Gems")or 0;local K=b:GetAttribute("Presents26")or 0;local L=b:GetAttribute("TraitRerolls")or 0;local M=b:GetAttribute("Level")or 0;local N=game.PlaceId;if N==16146832113 or N==18219125606 then F()end;local O=getgenv().SeenIceQueenAny;local P=getgenv().SeenIceQueenShiny;local Q,R;if O then if P then Q="SHINY"R="✨✅"else Q="NORMAL"R="✅"end else Q="NONE"R="❌"end;local S=string.format("💎 Gems : %s   🎁 Box : %s   🎲 Reroll : %s   🆙 Lv : %s   👑 Ice Queen : %s %s",J,K,L,M,Q,R)
if S~=e then e=S;d=S;pcall(_G.Horst_SetDescription,S)end end end)
