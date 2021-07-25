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

CreateThread(function()
	-- Create the menu
	JayMenu.CreateMenu("radiowheel", "Radio Favourites", function() return CloseRadioMenu() end)
    JayMenu.SetSubTitle("radiowheel", "Hidden Stations")
	
	for i = 0, GetNumUnlockedRadioStations() do
		radioStations[GetRadioStationName(i)] = 0
	end
	
	-- Load the KVPs on resource start and populate the table
	for station, kvp in pairs(radioStations) do
		local kvpString = resourceKVPKey .. station
		if GetResourceKvpInt(kvpString) == 1 then
			radioStations[station] = 1
			Citizen.InvokeNative(0x4CAFEBFA21EC188D, station, true) -- SetRadioStationIsVisible
		end
	end
	
	-- While the menu is open
	while true do
		Wait(0)
		if JayMenu.IsMenuOpened("radiowheel") then
			for station, kvp in pairs(radioStations) do
				if kvp == 1 then
					if JayMenu.SpriteButton(GetLabelText(station), "commonmenu", "shop_box_blank", "shop_box_blankb") then
						radioStations[station] = 0
						Citizen.InvokeNative(0x4CAFEBFA21EC188D, station, false) -- SetRadioStationIsVisible
					end
				else
					if JayMenu.SpriteButton(GetLabelText(station), "commonmenu", "shop_box_tick", "shop_box_tickb") then
						radioStations[station] = 1
						Citizen.InvokeNative(0x4CAFEBFA21EC188D, station, true) -- SetRadioStationIsVisible
					end
				end
			end
			JayMenu.Display()
		end
	end
end)