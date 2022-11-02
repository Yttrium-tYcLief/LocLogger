local frame = CreateFrame("FRAME", "LocLogger")
frame:RegisterEvent("ADDON_LOADED")

LL_INTERVAL = 1
local LL_INTERVAL_DEFAULT = 1
LL_PRECISION = 2
local LL_PRECISION_DEFAULT = 2
LL_CULLDUPE = true
local LL_CULLDUPE_DEFAULT = true
LL_ENABLED = true
LL_DATA = ""
local LL_LOGGING = false
local posX = 0
local posY = 0
local lastX = 0
local lastY = 0

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition

local format = format

local function eventHandler(self, event, arg1, ...)
	if event == "ADDON_LOADED" then
		if arg1 == "LocLogger" then
			print("|cffFFFF00" .. arg1 .. "|r" .. " - Loaded")
		end
		return
	end
	
	if LL_ENABLED == false then
		return
	end
end

frame:SetScript("OnEvent", eventHandler)

SLASH_LOCLOGGER1 = "/loc"

SlashCmdList.LOCLOGGER = function(input)
	input = string.lower(input)
    input = string.trim(input, " ")

    local commands = {}
    for c in string.gmatch(input, "([^%s]+)") do
        table.insert(commands, c)
    end

    local mainCommand = commands[1]
    local subCommand = commands[2]
    
	if mainCommand == "start" then
        LL_DATA = ""
		LL_LOGGING = true
        C_Timer.After(LL_INTERVAL, LocLogger.WriteCoords)
		print("LocLogger: Logging started")
		return
	elseif mainCommand == "stop" then
		LL_LOGGING = false
		print("LocLogger: Logging stopped, use '/loc output' to obtain data")
		return
	elseif mainCommand == "cull" then
		LL_CULLDUPE = not LL_CULLDUPE
		local word = "Not culling duplicate locations"
		if LL_CULLDUPE then
			word = "Culling duplicate locations"
		end
		print("LocLogger: " .. word)
		return
	elseif mainCommand == "interval" then
    
        if not subCommand then
            if LL_INTERVAL == 1 then
                print("LocLogger: Interval is currently " .. LL_INTERVAL .. " second")
            else
                print("LocLogger: Interval is currently " .. LL_INTERVAL .. " seconds")
            end
            return
        end
        
        if subCommand ~= nil then
            if subCommand == "reset" then
                LL_INTERVAL = LL_INTERVAL_DEFAULT
                print("LocLogger: Interval reset to " .. LL_INTERVAL .. " second")
                return
            end
            
            local conversionTry = tonumber(subCommand)
            if conversionTry then -- We've got an ID
                LL_INTERVAL = conversionTry
                if LL_INTERVAL == 1 then
                    print("LocLogger: Interval set to " .. LL_INTERVAL .. " second")
                else
                    print("LocLogger: Interval set to " .. LL_INTERVAL .. " seconds")
                end
                return
            end
        end
		return
	elseif mainCommand == "precision" then
    
        if not subCommand then
            if LL_PRECISION == 1 then
                print("LocLogger: Precision is currently " .. LL_PRECISION .. " decimal place")
            else
                print("LocLogger: Precision is currently " .. LL_PRECISION .. " decimal places")
            end
            return
        end
        
        if subCommand ~= nil then
            if subCommand == "reset" then
                LL_PRECISION = LL_PRECISION_DEFAULT
                print("LocLogger: Precision reset to " .. LL_PRECISION .. " decimal places")
                return
            end
            
            local conversionTry = tonumber(subCommand)
            if conversionTry then -- We've got an ID
                LL_PRECISION = conversionTry
                if LL_PRECISION == 1 then
                    print("LocLogger: Precision set to " .. LL_PRECISION .. " decimal place")
                else
                    print("LocLogger: Precision set to " .. LL_PRECISION .. " decimal places")
                end
                return
            end
        end
		return
	elseif mainCommand == "reset" then
        LL_INTERVAL = LL_INTERVAL_DEFAULT
        LL_PRECISION = LL_PRECISION_DEFAULT
        LL_CULLDUPE = LL_CULLDUPE_DEFAULT
        print("LocLogger: All settings reset to default")
        return
	elseif mainCommand == "output" then
        StaticPopup_Show("LOCLOG_OUTPUT",LL_DATA)
        return
	elseif mainCommand == "help" or mainCommand == "" or not mainCommand then
		print("LocLogger Commands:")
		print("|cffFFFF00/loc start|r" .. " - Start coordinate logging")
		print("|cffFFFF00/loc stop|r" .. " - Stop coordinate logging")
		print("|cffFFFF00/loc output|r" .. " - Open editbox with current log session data")
		print("|cffFFFF00/loc interval #|r" .. " - Set logging interval in seconds, default 1")
		print("|cffFFFF00/loc precision #|r" .. " - Set coordinate decimal places, default 2")
		print("|cffFFFF00/loc cull|r" .. " - Enable/Disable duplicate location culling")
		print("|cffFFFF00/loc reset|r" .. " - Reset all settings to default")
        print("Use 'reset' as a setting argument to reset to default")
		return
	else
		print("LocLogger: Invalid command, try '/loc help' to get a list of available commands")
		return
	end
end

function LocLogger:AddData(words)
    LL_DATA = LL_DATA .. words
    --SendChatMessage(words, (IsInRaid() and "RAID") or (IsInGroup() and "PARTY"))
    return
end

function LocLogger:WriteCoords()
    if not LL_LOGGING then
        -- we terminate early if logging was disabled after this cycle was scheduled but prior to it running
        return
    end
    
    local isInInstance, instanceType = IsInInstance()
    if isInInstance and "pvp" ~= instanceType then -- dont write coords in raids
        LL_LOGGING = false
		print("LocLogger: Instance detected, disabling logging")
        return
    end
    
    local mapID
    local position
    
    -- Player position
    mapID = GetBestMapForUnit("player")
    
    if mapID then
        position = GetPlayerMapPosition(mapID, "player")
        if position then
            if position.x ~= 0 and position.y ~= 0 and (position.x ~= lastX or position.y ~= lastY) then
                -- if culling is enabled, then we write these coords to memory to compare against the next loop
                -- if these coords ever match, we don't print to chat
                if LL_CULLDUPE then
                    lastX = position.x
                    lastY = position.y
                else
                    lastX = 0
                    lastY = 0
                end
                
                -- convert to human readable coords
                posX = position.x * 100
                posY = position.y * 100 
                
                -- trim to user specified decimal length
                local precision = "%.".. LL_PRECISION .."f"
                
                LocLogger:AddData(format("\{" .. precision .. "," .. precision .. "\},", posX, posY))
            end
        end
    end
    
    C_Timer.After(LL_INTERVAL, LocLogger.WriteCoords)
end

-- Register the popup dialog
StaticPopupDialogs["LOCLOG_OUTPUT"] = {
    text = "LocLogger Output",
    button2 = CLOSE,
    hasEditBox = true,
    editBoxWidth = 280,

    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,

    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,

    OnShow = function(self)
        local data = self.text.text_arg1;
        
        self.editBox:SetText("\{"..data.."\}");
        self.editBox:SetFocus();
        self.editBox:HighlightText();
    end,

    whileDead = true,
    hideOnEscape = true
}