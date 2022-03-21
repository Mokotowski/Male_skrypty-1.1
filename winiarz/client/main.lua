

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local JobBlips                = {}
local publicBlip = false
local CzyJest                 	= false
ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)

	end)
end

function OpenwiniarzActionsMenu()
	
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
			title    = _U('cloakroom'),
			align    = 'center',
			elements = {
				{label = 'Ubranie Cywilne', value = 'citizen_wear'},
				{label = 'Ubranie Robocze', value = 'winiarz_wear'},
				{label = 'Zarządzanie firmą', value = 'boss_actions'},
			},
		},
		function(data, menu)

			menu.close()
			
			if data.current.value == 'boss_actions' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and PlayerData.job.grade_name == 'boss' then
				TriggerEvent('esx_society:openBossMenuhype2', 'winiarz', function(data, menu)
					menu.close()
				end)
			end
			
			if data.current.value == 'boss_actions' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and PlayerData.job.grade_name == 'recrue' then
				TriggerEvent("pNotify:SendNotification", {text = "Nie jesteś szefem firmy", type = "error", timeout = 3000, layout = "centerLeft"})
			end
			
			if data.current.value == 'citizen_wear' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			if data.current.value == 'winiarz_wear' then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
					else
						TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
					end
				end)
			end

			CurrentAction     = 'winiarz_actions_menu'
			CurrentActionData = {}
		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenVehicleSpawnerMenu()



				local model = 'bison2'
		
				ESX.Game.SpawnVehicle(model, Config.Zones.VehicleSpawnPoint.Pos, 257.32, function(vehicle)
					local playerPed = GetPlayerPed(-1)
					TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
				end)




				CurrentAction     = 'vehicle_spawner_menu'
				CurrentActionData = {}

			end








RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	blips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	deleteBlips()
	blips()
end)

AddEventHandler('esx_winiarz:hasEnteredMarker', function(zone)
	local playerPed = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn(player,false)
	
	if zone == 'Winogrono' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'raisin_harvest'
		ESX.ShowAdvancedNotification('Zrywanie', 'Winiarz', '~g~[E] ~y~aby zrywac winogrona', 'CHAR_DOM', 8)

		CurrentActionData = {zone= zone}
	end

	if zone == 'Winogrono2' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'raisin_harvest'
		ESX.ShowAdvancedNotification('Zrywanie', 'Winiarz', '~g~[E] ~y~aby zrywac winogrona', 'CHAR_DOM', 8)
		CurrentActionData = {zone= zone}
	end
		
	if zone == 'Miasz' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'vine_traitement'
		ESX.ShowAdvancedNotification('Przetwarzanie', 'Winiarz', '~g~[E] ~y~aby uzyskac miasz z winorgon', 'CHAR_DOM', 8)
		CurrentActionData = {zone= zone}
	end
	
	if zone == 'Wino' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'vine_traitement2'
		ESX.ShowAdvancedNotification('Przetwarzanie', 'Winiarz', '~g~[E] ~y~aby rozpaczac fermentacje wina', 'CHAR_DOM', 8)
		CurrentActionData = {zone= zone}
	end

	if zone == 'SellFarm' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'farm_resell'
		ESX.ShowAdvancedNotification('Sprzedawanie', 'Winiarz', '~g~[E] ~y~aby sprzedac wino', 'CHAR_DOM', 8)
		CurrentActionData = {zone = zone}
	end

	if zone == 'winiarzronActions' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' and not IsPedInAnyVehicle(playerPed, false) then
		CurrentAction     = 'winiarz_actions_menu'
		ESX.ShowAdvancedNotification('Szatnia', 'Winiarz', '~g~[E] ~y~aby skorzystac z szatni', 'CHAR_DOM', 8)
		CurrentActionData = {}
	end
  
	if zone == 'VehicleSpawner' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		CurrentAction     = 'vehicle_spawner_menu'
		ESX.ShowAdvancedNotification('Wyciaganie samochodu', 'Winiarz', '~g~[E] ~y~aby pobrac samochod', 'CHAR_DOM', 8)
		CurrentActionData = {}
	end
		
	if zone == 'VehicleDeleter' and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then

		local playerPed = GetPlayerPed(-1)
		local coords    = GetEntityCoords(playerPed)
		
		if IsPedInAnyVehicle(playerPed,  false) then

			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = coords.x,
				y = coords.y,
				z = coords.z
			})

			if distance ~= -1 and distance <= 1.0 then

				CurrentAction     = 'delete_vehicle'
				ESX.ShowAdvancedNotification('Chowanie Samochodu', 'Winiarz', '~g~[E] ~y~aby schowac samochod', 'CHAR_DOM', 8)
				CurrentActionData = {vehicle = vehicle}

			end
		end
	end
end)

AddEventHandler('esx_winiarz:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	
	if (zone == 'Pszenica') and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		TriggerServerEvent('esx_winiarz:stopHarvest')
	end  
	
	if (zone == 'Pszenica2') and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		TriggerServerEvent('esx_winiarz:stopHarvest')
	end

	if (zone == 'Chleb') and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		TriggerServerEvent('esx_winiarz:stopTransform')
	end
 
	if (zone == 'Maka') and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		TriggerServerEvent('esx_winiarz:stopTransform2')
	end
	
	if (zone == 'SellFarm') and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
		TriggerServerEvent('esx_winiarz:stopSell')
	end
	CurrentAction = nil
end)




function deleteBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
		RemoveBlip(JobBlips[i])
		JobBlips[i] = nil
		end
	end
end

-- Create Blips
function blips()

	
    if PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then

		for k,v in pairs(Config.BlipJablka)do
			if v.Type == -1 then
				local blip2 = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite (blip2, 85)
				SetBlipDisplay(blip2, 4)
				SetBlipScale  (blip2, 1.5)
				SetBlipColour (blip2, 19)
				SetBlipAsShortRange(blip2, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.Name)
				EndTextCommandSetBlipName(blip2)
				table.insert(JobBlips, blip2)
			end
		end


		for k,v in pairs(Config.BlipPomarancze)do
			if v.Type == 27 then
				local blip3 = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite (blip3, 85)
				SetBlipDisplay(blip3, 4)
				SetBlipScale  (blip3, 1.5)
				SetBlipColour (blip3, 73)
				SetBlipAsShortRange(blip3, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.Name)
				EndTextCommandSetBlipName(blip3)
				table.insert(JobBlips, blip3)
			end
		end


		for k,v in pairs(Config.BlipReszta)do
			if v.Type == 32 then
				local blip4 = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

				SetBlipSprite (blip4, 85)
				SetBlipDisplay(blip4, 4)
				SetBlipScale  (blip4, 1.5)
				SetBlipColour (blip4, 75)
				SetBlipAsShortRange(blip4, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.Name)
				EndTextCommandSetBlipName(blip4)
				table.insert(JobBlips, blip4)
			end
		end
	end
end


-- Display markers
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)


-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_winiarz:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_winiarz:hasExitedMarker', LastZone)
			end
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and PlayerData.job ~= nil and PlayerData.job.name == 'winiarz' then
				if CurrentAction == 'raisin_harvest' then
					TriggerServerEvent('esx_winiarz:startHarvest', CurrentActionData.zone)
				end

				if CurrentAction == 'vine_traitement' then
					TriggerServerEvent('esx_winiarz:startTransform2', CurrentActionData.zone)
				end
				
				if CurrentAction == 'vine_traitement2' then
					TriggerServerEvent('esx_winiarz:startTransform', CurrentActionData.zone)
				end
				
				if CurrentAction == 'farm_resell' then
					TriggerServerEvent('esx_winiarz:startSell', CurrentActionData.zone)
				end
				
				if CurrentAction == 'winiarz_actions_menu' then
					OpenwiniarzActionsMenu()
				end
				if CurrentAction == 'vehicle_spawner_menu' then
					OpenVehicleSpawnerMenu()
				end
				if CurrentAction == 'delete_vehicle' then

					if Config.EnableSocietyOwnedVehicles then
						local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
						TriggerServerEvent('esx_society:putVehicleInGarage', 'winiarz', vehicleProps)
					end

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
				end

				CurrentAction = nil
				

			end
		end
	end
end)





--3D
function DrawText3D(x, y, z, text, scale)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

  SetTextScale(scale, scale)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextEntry("STRING")
  SetTextCentre(1)
  SetTextColour(255, 255, 255, 255)
  SetTextOutline()

  AddTextComponentString(text)
  DrawText(_x, _y)

  local factor = (string.len(text)) / 270
  DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end


RegisterNetEvent('winiarz:procenty')
AddEventHandler('winiarz:procenty', function()
  CzyJest = true
    while (CzyJest) do
      Citizen.Wait(8)
      local playerPed = PlayerPedId()
      local coords = GetEntityCoords(playerPed)
      DrawText3D(coords.x, coords.y, coords.z+0.1,'Pracuje...' , 0.4)
      DrawText3D(coords.x, coords.y, coords.z, TimeLeft .. '~g~%', 0.4)
    end
end)


  function procent(time)
	TriggerEvent('winiarz:procenty')
	TimeLeft = 0
	repeat
	TimeLeft = TimeLeft + 1
	Citizen.Wait(time)
	until(TimeLeft == 100)
	CzyJest = false
	cooldownclick = false
  end

function animka1()
	local dict = "anim@heists@ornate_bank@grab_cash_heels"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "grab", 8.0, 8.0, 10000, 1, 0, false, false, false)
end

function animka2()
	local dict = "amb@prop_human_bum_bin@idle_b"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "idle_d", 8.0, 8.0, 10000, 1, 0, false, false, false)
end

function animka3()
	local dict = "amb@prop_human_bum_bin@idle_b"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "idle_d", 8.0, 8.0, 10000, 1, 0, false, false, false)
end

function animka4()
	local dict = "mini@repair"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
	Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "fixed_a_ped", 8.0, 8.0, 10000, 1, 0, false, false, false)
end




RegisterNetEvent('esx_winiarz:startHarvest2')
AddEventHandler('esx_winiarz:startHarvest2', function()

	FreezeEntityPosition(PlayerPedId(), true)
	animka1()
	TriggerServerEvent('esx_winiarz:startHarvest3')
	procent(95)
	FreezeEntityPosition(PlayerPedId(), false)
	HasAlreadyEnteredMarker, LastZone = true, currentZone

end)




RegisterNetEvent('esx_winiarz:startTransform3')
AddEventHandler('esx_winiarz:startTransform3', function()

	FreezeEntityPosition(PlayerPedId(), true)
	animka2()
	TriggerServerEvent('esx_winiarz:startTransform4')
	procent(95)
	FreezeEntityPosition(PlayerPedId(), false)
	HasAlreadyEnteredMarker, LastZone = true, currentZone

end)



RegisterNetEvent('esx_winiarz:startTransform5')
AddEventHandler('esx_winiarz:startTransform5', function()

	FreezeEntityPosition(PlayerPedId(), true)
	animka3()
	TriggerServerEvent('esx_winiarz:startTransform6')
	procent(95)
	FreezeEntityPosition(PlayerPedId(), false)
	HasAlreadyEnteredMarker, LastZone = true, currentZone

end)



RegisterNetEvent('esx_winiarz:startSell2')
AddEventHandler('esx_winiarz:startSell2', function()

	FreezeEntityPosition(PlayerPedId(), true)
	animka3()
	TriggerServerEvent('esx_winiarz:startSell3')
	procent(95)
	FreezeEntityPosition(PlayerPedId(), false)
	HasAlreadyEnteredMarker, LastZone = true, currentZone

end)