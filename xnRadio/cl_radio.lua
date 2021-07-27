local resourceKVPKey = "xnRadio_" -- Resource KVP string, it's best to leave it as this name so every server the player plays on that has this resource has the same favourites
local radioStations = {}

-- Command to open the station menu
RegisterCommand("radio", function(source, args)
	JayMenu.OpenMenu("radiowheel")
end)

-- Update the KVPs when the menu closes
function CloseRadioMenu()
	UpdateKVPs()
	return true
end

function UpdateKVPs()
	for station, kvp in pairs(radioStations) do
		local kvpString = resourceKVPKey .. station
		SetResourceKvpInt(kvpString, kvp)
	end
end

local waitTime = 100
CreateThread(function()
	-- Create the menu
	JayMenu.CreateMenu("radiowheel", "Radio Favourites", function() return CloseRadioMenu() end)
    JayMenu.SetSubTitle("radiowheel", "Hidden Stations")
	
	-- Get all the radio stations
	for i = 0, GetNumUnlockedRadioStations() - 1 do
		radioStations[GetRadioStationName(i)] = 0
	end
	
	-- Load the KVPs on resource start and populate the table
	for station, _ in pairs(radioStations) do
		local kvpString = resourceKVPKey .. station
		if GetResourceKvpInt(kvpString) == 1 then
			radioStations[station] = 1
			SetRadioStationIsVisible(station, false)
		end
	end
	
	-- While the menu is open
	while true do
		Wait(waitTime)
		waitTime = 100
		if JayMenu.IsMenuOpened("radiowheel") then
			waitTime = 0
			for station, kvp in pairs(radioStations) do
				if kvp == 1 then
					if JayMenu.SpriteButton(GetLabelText(station), "commonmenu", "shop_box_tick", "shop_box_tickb") then
						radioStations[station] = 0
						SetRadioStationIsVisible(station, true)
					end
				else
					if JayMenu.SpriteButton(GetLabelText(station), "commonmenu", "shop_box_blank", "shop_box_blankb") then
						radioStations[station] = 1
						SetRadioStationIsVisible(station, false)
					end
				end
			end
			JayMenu.Display()
		end
	end
end)