local resourceKVPKey = "xnRadio_" -- Resource KVP string, it's best to leave it as this name so every server the player plays on that has this resource has the same favourites
local radioStations = {}

local mediaPlayerTracks = {
	{ label = "PIM_USBMIXNO", tracklist = "TUNER_AP_SILENCE_MUSIC" },
	{ label = "PIM_USBMIX0", tracklist = "TUNER_AP_MIX3_PARTA" },
	{ label = "PIM_USBMIX1", tracklist = "TUNER_AP_MIX3_PARTB" },
	{ label = "PIM_USBMIX2", tracklist = "TUNER_AP_MIX3_PARTC" },
	{ label = "PIM_USBMIX3", tracklist = "TUNER_AP_MIX3_PARTD" },
	{ label = "PIM_USBMIX4", tracklist = "TUNER_AP_MIX1" },
	{ label = "PIM_USBMIX5", tracklist = "TUNER_AP_MIX2" }
}

if GetGameBuildNumber() >= 2545 then
	table.insert(mediaPlayerTracks, { label = "PIM_USBMIX7", tracklist = "RADIO_AP_DRE" })
	table.insert(mediaPlayerTracks, { label = "PIM_USBMIX9", tracklist = "FIXER_AP_DSCVRBl_MIX_1" })
	table.insert(mediaPlayerTracks, { label = "PIM_USBMIX10", tracklist = "FIXER_AP_DSCVRBl_MIX_2" })
end

local mediaPlayerLabels = {}
for i, track in ipairs(mediaPlayerTracks) do
	mediaPlayerLabels[i] = GetLabelText(track.label)
	-- concat any label over 15 characters
	if #mediaPlayerLabels[i] > 20 then
		mediaPlayerLabels[i] = string.sub(mediaPlayerLabels[i], 1, 20).."..."
	end
end
local mediaPlayerIndex = 1

-- Command to open the station menu
RegisterCommand("radio", function(source, args)
	DoMenuThread()
	JayMenu.OpenMenu("radioMenu")
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

function SetMediaPlayerTrack(old, new)
	if old then
		LockRadioStationTrackList("RADIO_36_AUDIOPLAYER", old)
	end

	UnlockRadioStationTrackList("RADIO_36_AUDIOPLAYER", new)
	ForceRadioTrackListPosition("RADIO_36_AUDIOPLAYER", new, math.random(0, 13) * 60000)
end

function DoMenuThread()
	Citizen.CreateThread(function ()
		while JayMenu.IsMenuOpened("radioMenu") or JayMenu.IsMenuOpened("hiddenStations") do
			Wait(0)
			if JayMenu.IsMenuOpened("radioMenu") then
				JayMenu.ComboBox("Media Player", mediaPlayerLabels, mediaPlayerIndex, mediaPlayerIndex, function (currentIndex, selectedIndex)
					if mediaPlayerIndex ~= currentIndex then
						SetMediaPlayerTrack(mediaPlayerTracks[mediaPlayerIndex].tracklist, mediaPlayerTracks[currentIndex].tracklist)
						SetResourceKvpInt(resourceKVPKey.."usbIndex", currentIndex)
						mediaPlayerIndex = currentIndex
					end
				end)
				JayMenu.MenuButton("Hide Stations", "hiddenStations")

				JayMenu.Display()
			elseif JayMenu.IsMenuOpened("hiddenStations") then
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
end

CreateThread(function()
	LockRadioStation("RADIO_36_AUDIOPLAYER", false)
  UnlockRadioStationTrackList("RADIO_36_AUDIOPLAYER", "TUNER_AP_SILENCE_MUSIC")

	-- Create the menu
	JayMenu.CreateMenu("radioMenu", "xnRadio", function() return CloseRadioMenu() end)
    JayMenu.SetSubTitle("radioMenu", "Radio Options")

	JayMenu.CreateSubMenu("hiddenStations", "radioMenu", "Hide Stations")
	
	-- Get all the radio stations
	for i = 0, GetNumUnlockedRadioStations() - 1 do
		radioStations[GetRadioStationName(i)] = 0
	end

	local usbIndexKVP = GetResourceKvpInt(resourceKVPKey.."usbIndex")
	if usbIndexKVP ~= 0 then
		if usbIndexKVP > #mediaPlayerTracks then --? incase they join a lower build server, we just reset this to 1, without applying the kvp until they change the radio again, that way it preserves their choice on a server with the newer build
			usbIndexKVP = 1
		end
		mediaPlayerIndex = usbIndexKVP
		SetMediaPlayerTrack("TUNER_AP_SILENCE_MUSIC", mediaPlayerTracks[usbIndexKVP].tracklist)
	end
	
	-- Load the KVPs on resource start and populate the table
	for station, _ in pairs(radioStations) do
		local kvpString = resourceKVPKey .. station
		if GetResourceKvpInt(kvpString) == 1 then
			radioStations[station] = 1
			SetRadioStationIsVisible(station, false)
		end
	end
end)
