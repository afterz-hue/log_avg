repeat task.wait(1) until game:IsLoaded()
repeat task.wait(1) until type(_G.Horst_SetDescription) == "function"

local Players = game:GetService("Players")
local player  = Players.LocalPlayer

-- HOOK Horst_SetDescription (ป้องกันกลับ default)
local originalSetDescription = _G.Horst_SetDescription
local currentLockedText = ""
local lastShownText = ""

local function isHorstDefaultText(text)
    if type(text) ~= "string" then return false end
    if text:find("Level%s*:%s*") and text:find("Gems%s*:%s*") and text:find("Gold%s*:%s*") then
        return true
    end
    return false
end

_G.Horst_SetDescription = function(text)
    if isHorstDefaultText(text) then
        if currentLockedText ~= "" and originalSetDescription then
            pcall(originalSetDescription, currentLockedText)
        end
        return
    end

    currentLockedText = tostring(text or "")
    if originalSetDescription then
        pcall(originalSetDescription, currentLockedText)
    end
end

-- ICE QUEEN CACHE (จำข้ามแมพ)
getgenv().SeenIceQueenAny   = getgenv().SeenIceQueenAny   or false
getgenv().SeenIceQueenShiny = getgenv().SeenIceQueenShiny or false

local function persistCache()
    if not queue_on_teleport then return end
    local code = ([[
        getgenv().SeenIceQueenAny   = %s
        getgenv().SeenIceQueenShiny = %s
    ]]):format(tostring(getgenv().SeenIceQueenAny), tostring(getgenv().SeenIceQueenShiny))
    queue_on_teleport(code)
end

local TARGET_NAME = "Ice Queen (Release)"
local function scanCacheForIceQueen()
    local foundAny, foundShiny = false, false
    local ok, err = pcall(function()
        local handler = rawget(_G, "UnitWindowHandler") or _G.UnitWindowHandler or UnitWindowHandler
        if not handler or not handler._Cache then return end
        for _, v in pairs(handler._Cache) do
            if v and v.UnitData and v.UnitData.Name == TARGET_NAME then
                foundAny = true
                if v.UnitData.Rarity == "Shiny" or v.UnitData.Shiny == true then
                    foundShiny = true
                end
            end
        end
    end)
    if not ok then warn("[AVG HORST LOG] scanCacheForIceQueen error:", err) end
    return foundAny, foundShiny
end

local function scanInventoryForIceQueenAny()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    local ok, hasAny = pcall(function()
        local windows    = pg:FindFirstChild("Windows")
        local globalInv  = windows    and windows:FindFirstChild("GlobalInventory")
        local holder     = globalInv  and globalInv:FindFirstChild("Holder")
        local left       = holder     and holder:FindFirstChild("LeftContainer")
        local fakeScroll = left       and left:FindFirstChild("FakeScrollingFrame")
        local items      = fakeScroll and fakeScroll:FindFirstChild("Items")
        local cache      = items      and items:FindFirstChild("CacheContainer")
        if not cache then return false end
        for _, guiItem in ipairs(cache:GetChildren()) do
            if not guiItem:IsA("GuiObject") then continue end
            local main = guiItem:FindFirstChild("Container")
            main = main and main:FindFirstChild("Holder")
            main = main and main:FindFirstChild("Main")
            if not main then continue end
            local nameLabel =
                main:FindFirstChild("UnitName")
                or main:FindFirstChild("Name")
                or main:FindFirstChild("Title")
            if not (nameLabel and nameLabel:IsA("TextLabel")) then continue end
            local unitName = (nameLabel.Text or ""):gsub("^%s*(.-)%s*$", "%1")
            if unitName == TARGET_NAME then
                return true
            end
        end
        return false
    end)
    if not ok then
        warn("[AVG HORST LOG] scanInventoryForIceQueenAny error:", hasAny)
        return false
    end
    return hasAny
end

local function recomputeIceQueenStatus()
    local foundAny, foundShiny = scanCacheForIceQueen()
    if not foundAny then
        if scanInventoryForIceQueenAny() then
            foundAny = true
        end
    end
    if foundAny then getgenv().SeenIceQueenAny = true end
    if foundShiny then getgenv().SeenIceQueenShiny = true end
    persistCache()
    return foundAny, foundShiny
end

local UPDATE_EVERY = 5
task.spawn(function()
    while task.wait(UPDATE_EVERY) do
        local gems     = player:GetAttribute("Gems")         or 0
        local presents = player:GetAttribute("Presents26")   or 0
        local rerolls  = player:GetAttribute("TraitRerolls") or 0
        local level    = player:GetAttribute("Level")        or 0

        local placeId = game.PlaceId
        if placeId == 16146832113  -- LOBBY
           or placeId == 18219125606  -- AFK
        then
            recomputeIceQueenStatus()
        end

        local hasAny   = getgenv().SeenIceQueenAny
        local hasShiny = getgenv().SeenIceQueenShiny
        local iceLabel, iceIcon
        if hasAny then
            if hasShiny then
                iceLabel = "SHINY"
                iceIcon  = "✨✅"
            else
                iceLabel = "NORMAL"
                iceIcon  = "✅"
            end
        else
            iceLabel = "NONE"
            iceIcon  = "❌"
        end

        local text = string.format(
            "💎 Gems : %s   🎁 Box : %s   🎲 Reroll : %s   🆙 Lv : %s   👑 Ice Queen : %s %s",
            gems,
            presents,
            rerolls,
            level,
            iceLabel,
            iceIcon
        )

        -- ถ้าข้อมูลใหม่ต่างจากครั้งก่อนถึงจะส่ง Horst log
        if text ~= lastShownText then
            lastShownText = text
            currentLockedText = text
            pcall(_G.Horst_SetDescription, text)
        end
    end
end)