local QBCore = exports[Config.Core]:GetCoreObject()

PlayerJob = {}
local Targets, Props, Blips, CraftLock = {}, {}, {},  false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job if PlayerJob.onduty then for k, v in pairs(Config.Locations) do if PlayerData.job.name == v.job then TriggerServerEvent("QBCore:ToggleDuty") end end end end)
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo onDuty = PlayerJob.onduty end)
RegisterNetEvent('QBCore:Client:SetDuty', function(duty) onDuty = duty end)
AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
	QBCore.Functions.GetPlayerData(function(PlayerData)	PlayerJob = PlayerData.job for k, v in pairs(Config.Locations) do if PlayerData.job.name == v.job then onDuty = PlayerJob.onduty end end end)
end)

CreateThread(function()
	local propTable = {}
	if Config.Locations[1].zoneEnable then	-- [[ Main Location ]] --
		local loc = Config.Locations[1]
		local bossroles = {}
		for grade in pairs(QBCore.Shared.Jobs[loc.job].grades) do
			if QBCore.Shared.Jobs[loc.job].grades[grade].isboss == true then
				if bossroles[loc.job] then
					if bossroles[loc.job] > tonumber(grade) then bossroles[loc.job] = tonumber(grade) end
				else bossroles[loc.job] = tonumber(grade)	end
			end
		end
		if loc.zones then
			JobLocation = PolyZone:Create(loc.zones, { name = loc.label, debugPoly = Config.Debug })
			JobLocation:onPlayerInOut(function(isPointInside)
				if PlayerJob.name == loc.job then
					if loc.autoClock and loc.autoClock.enter then if isPointInside and not onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
					if loc.autoClock and loc.autoClock.exit then if not isPointInside and onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
				end
			end)
		end
		if loc.blip then Blips[#Blips+1] = makeBlip({coords = loc.blip, sprite = loc.blipsprite or 106, col = loc.blipcolor, scale = loc.blipscale, disp = loc.blipdisp, category = nil, name = loc.label}) end
		if loc.MLO == "GN" then
			propTable[#propTable+1] = { prop = "prop_food_bs_tray_02", coords = vec4(-1193.36, -895.44, 14.1+1.03, 305.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_tray_01", coords = vec4(-1194.52, -893.83, 14.1+1.03, 305.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_tray_01", coords = vec4(-1192.41, -896.84, 14.1+1.03, 305.0) }

			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1196.68, -902.19, 13.9+1.03, 180.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1196.31, -901.9, 13.9+1.03, 180.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1196.5, -902.09, 13.9+1.03, 300.0) }

			--Targets
			--Stash/Shops
			Targets["BShelf"] =
			exports['qb-target']:AddBoxZone("BShelf", vec3(-1195.29, -897.51, 13.97), 3.0, 1.0, { name="BShelf", heading = 35.0, debugPoly=Config.Debug, minZ = 13.7, maxZ = 14.77, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1195.29, -897.51, 13.97) }, },
					distance = 2.0 })
			Targets["BFridge"] =
			exports['qb-target']:AddBoxZone("BFridge", vec3(-1201.31, -901.69, 13.97-1), 3.8, 0.6, { name="BFridge", heading = 35.0, debugPoly=Config.Debug, minZ = 13.0, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_fridge"], job = Config.Locations[1].job, id = "BSFridge", coords = vec3(-1201.31, -901.69, 13.97) }, },
					distance = 1.5 })

			Targets["BStore"] =
			exports['qb-target']:AddBoxZone("BStore", vec3(-1198.5, -904.02, 13.97-1), 0.4, 1.4, { name="BStore", heading = 213.65, debugPoly=Config.Debug, minZ = 12.97, maxZ = 15.37, },
				{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = Config.Locations[1].job, id = "BSShop", shop = Config.Items, coords = vec3(-1198.5, -904.02, 13.97) }, },
					distance = 1.5 })
			Targets["BBag"] =
			exports['qb-target']:AddBoxZone("BBag", vec3(-1196.52, -902.07, 13.97-1), 0.7, 0.5, { name="BBag", heading = 305.0, debugPoly=Config.Debug, minZ = 12.97, maxZ = 14.57, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, }, },
					distance = 2.0 })

			--Food Making
			Targets["BGrill"] =
			exports['qb-target']:AddBoxZone("BGrill", vec3(-1198.27, -895.3, 14.0-1), 0.7, 1.2, { name="BGrill", heading = 34.93, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = Config.Locations[1].job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(-1198.27, -895.3, 14.0) }, },
					distance = 1.5 })
			Targets["BFryer"] =
			exports['qb-target']:AddBoxZone("BFryer", vec3(-1200.85, -896.84, 13.97-1), 0.6, 1.6, { name="BFryer", heading = 34.0, debugPoly=Config.Debug, minZ = 12.97, maxZ = 14.57, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = Config.Locations[1].job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(-1200.85, -896.84, 13.97) }, },
					distance = 1.5 })
			Targets["BChop"] =
			exports['qb-target']:AddBoxZone("BChop", vec3(-1197.19, -898.18, 14.0-1), 0.6, 1.5, { name="BChop", heading = 213.93, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = Config.Locations[1].job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(-1197.19, -898.18, 14.0) }, },
					distance = 1.5 })
			Targets["BPrepare"] =
			exports['qb-target']:AddBoxZone("BPrepare", vec3(-1196.54, -899.28, 13.98-1), 0.6, 1.5, { name="BPrepare", heading = 34.93, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = Config.Locations[1].job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(-1196.54, -899.28, 13.98) }, },
					distance = 1.5 })
			Targets["BDrink"] =
			exports['qb-target']:AddBoxZone("BDrink", vec3(-1197.25, -894.48, 13.97), 2.0, 0.6, { name="BDrink", heading = 35.0, debugPoly=Config.Debug, minZ = 13.97, maxZ = 14.97, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1197.25, -894.48, 13.97) }, },
					distance = 1.5 })
			Targets["BDonut"] =
			exports['qb-target']:AddBoxZone("BDonut", vec3(-1196.52, -895.74, 13.97), 0.8, 0.6, { name="BDonut", heading = 35.0, debugPoly=Config.Debug, minZ = 13.97, maxZ = 15.17, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = Config.Locations[1].job, craftable = Crafting.Donut, header = Loc[Config.Lan].menu["food_cabinet"], coords = vec3(-1196.52, -895.74, 13.97) }, },
					distance = 1.5 })

			--Trays
			Targets["BTray1"] =
			exports['qb-target']:AddBoxZone("BTray1", vec3(-1194.29, -893.85, 14.2-1), 0.6, 1.0, { name="BTray1", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray1" }, },
					distance = 2.0 })

			Targets["BTray2"] =
			exports['qb-target']:AddBoxZone("BTray2", vec3(-1193.39, -895.42, 14.2-1), 0.6, 1.0, { name="BTray2", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray2" }, },
					distance = 2.0 })

			Targets["BTray3"] =
			exports['qb-target']:AddBoxZone("BTray3", vec3(-1192.39, -896.86, 14.2-1), 0.6, 1.0, { name="BTray3", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray3" }, },
					distance = 2.0 })

			--Hand Washing
			Targets["BWash1"] =
			exports['qb-target']:AddBoxZone("BWash1", vec3(-1197.61, -902.73, 13.98-1), 0.6, 0.8, { name="BWash1", heading = 300.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash2"] =
			exports['qb-target']:AddBoxZone("BWash2", vec3(-1205.24, -893.9, 13.98-1), 1.1, 0.8, { name="BWash2", heading = 122.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash3"] =
			exports['qb-target']:AddBoxZone("BWash3", vec3(-1206.01, -892.84, 13.98-1), 0.6, 0.6, { name="BWash3", heading = 122.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash4"] =
			exports['qb-target']:AddBoxZone("BWash4", vec3(-1201.96, -890.09, 13.98-1), 0.6, 0.6, { name="BWash4", heading = 122.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash5"] =
			exports['qb-target']:AddBoxZone("BWash5", vec3(-1201.16, -891.14, 13.98-1), 0.6, 0.6, { name="BWash5", heading = 122.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })

			--Payments / Clockin
			Targets["BReceipt"] =
			exports['qb-target']:AddCircleZone("BReceipt", vec3(-1194.95, -893.15, 14.15), 0.5, { name="BReceipt", debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt2"] =
			exports['qb-target']:AddCircleZone("BReceipt2", vec3(-1193.97, -894.67, 14.15), 0.5, { name="BReceipt2", debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt3"] =
			exports['qb-target']:AddCircleZone("BReceipt3", vec3(-1192.93, -896.24, 14.15), 0.5, { name="BReceipt3", debugPoly=Config.Debug, useZ=true, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BClockin"] =
			exports['qb-target']:AddBoxZone("BClockin", vec3(-1179.06, -896.32, 13.97-0.5), 0.6, 0.6, { name="BClockin", heading = 10.0, debugPoly=Config.Debug, minZ = 13.57, maxZ = 14.57, },
					{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = Config.Locations[1].job },
								{ event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
								}, distance = 2.0 })
		elseif loc.MLO == "LP" then
			--CLEAR PROPS
			CreateModelHide(vec3(-1202.76, -889.01, 14.0), 1.5, -851111464, true) CreateModelHide(vec3(-1202.76, -889.01, 14.0), 1.5, -421145003, true)

			CreateModelHide(vec3(-1199.01, -890.5, 14.0), 1.5, 1864388210, true) CreateModelHide(vec3(-1196.95, -886.98, 14.0), 1.5, 1864388210, true)
			CreateModelHide(vec3(-1191.59, -882.02, 14.86), 1.5, 1864388210, true) CreateModelHide(vec3(-1195.24, -890.98, 14.0), 1.5, 1864388210, true)
			CreateModelHide(vec3(-1186.99, -894.32, 14.86), 1.5, 1864388210, true) CreateModelHide(vec3(-1186.81, -881.8, 14.0), 1.5, 1864388210, true)
			CreateModelHide(vec3(-1188.73, -890.44, 14.0), 1.5, 1864388210, true) CreateModelHide(vec3(-1190.81, -899.94, 14.0), 1.5, 1864388210, true)
			CreateModelHide(vec3(-1182.04, -894.47, 14.0), 1.5, 1864388210, true) CreateModelHide(vec3(-1180.42, -892.44, 14.0), 1.5, 1864388210, true)
			CreateModelHide(vec3(-1186.26, -896.37, 14.0), 1.5, 1864388210, true)

			CreateModelHide(vec3(-1180.42, -892.44, 14.0), 1.5, 759729215, true) CreateModelHide(vec3(-1180.19, -893.49, 14.0), 1.5, -775118285, true)

			CreateModelHide(vec3(-1200.74, -887.44, 14.0), 1.5, 1778631864, true) CreateModelHide(vec3(-1200.34, -886.73, 14.01), 1.5, -1842599357, true)

			CreateModelHide(vec3(-1190.81, -899.94, 14.0), 1.5, 600967813, true) CreateModelHide(vec3(-1190.81, -899.94, 14.0), 1.5, 1049934319, true)
			CreateModelHide(vec3(-1190.81, -899.94, 14.0), 1.5, 443058963, true)

			CreateModelHide(vec3(-1190.81, -899.94, 14.0), 1.5, 510552540, true)

			CreateModelHide(vec3(-1187.63, -898.52, 14.0), 1.5, 510552540, true)

			CreateModelHide(vec3(-1184.18, -895.2, 14.0), 1.5, 1948359883, true) CreateModelHide(vec3(-1184.18, -895.2, 14.0), 1.5, 1388308576, true)

			CreateModelHide(vec3(-1200.69, -888.19, 14.0), 1.5, 922914566, true) CreateModelHide(vec3(-1202.72, -888.3, 14.0), 1.5, -1732499190, true)

			--ADD JOB RELATED PROPS
			propTable[#propTable+1] = { prop = "prop_food_bs_tray_02", coords = vec4(-1196.3, -890.7, 15.05, 305.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_tray_01", coords = vec4(-1195.0, -892.68, 15.05, 305.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1200.44, -896.36, 13.91+1.03, 300.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1200.44, -896.16, 13.91+1.03, 180.0) }
			propTable[#propTable+1] = { prop = "prop_food_bs_bag_04", coords = vec4(-1200.64, -896.06, 13.91+1.03, 250.0) }

			--Targets
			--Stash/Shops
			Targets["BShelf"] =
			exports['qb-target']:AddBoxZone("BShelf", vec3(-1197.75, -894.31, 14.19-1), 1.1, 4.5, { name="BShelf", heading = 123.65, debugPoly=Config.Debug, minZ = 13.0, maxZ = 14.9, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1197.75, -894.31, 14.19) }, },
					distance = 2.0 })
			Targets["BFridge"] =
			exports['qb-target']:AddBoxZone("BFridge", vec3(-1203.9, -889.75, 13.99-1), 1.2, 1.6, { name="BFridge", heading = 215.0, debugPoly=Config.Debug, minZ = 13.0, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_fridge"], job = Config.Locations[1].job, id = "BSFridge", coords = vec3(-1203.9, -889.75, 13.99) }, },
					distance = 1.5 })
			Targets["BStore"] =
			exports['qb-target']:AddBoxZone("BStore", vec3(-1205.75, -892.99, 13.99-1), 1.0, 4.5, { name="BStore", heading = 122.65, debugPoly=Config.Debug, minZ = 13.2, maxZ = 15.5, },
				{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = Config.Locations[1].job, id = "BSShop", shop = Config.Items, coords = vec3(-1205.75, -892.99, 13.99) }, },
					distance = 1.5 })
			Targets["BBag"] =
			exports['qb-target']:AddBoxZone("BBag", vec3(-1200.51, -896.17, 14.0-0.5), 0.5, 0.7, { name="BBag", heading = 304.0, debugPoly=Config.Debug, minZ = 13.6, maxZ = 14.6, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, }, },
					distance = 2.0 })

			--Food Making
			Targets["BGrill1"] =
			exports['qb-target']:AddBoxZone("BGrill1", vec3(-1200.27, -900.76, 14.0-1), 0.7, 1.2, { name="BGrill1", heading = 123.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = Config.Locations[1].job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(-1200.27, -900.76, 14.0) }, },
					distance = 1.5 })
			Targets["BGrill2"] =
			exports['qb-target']:AddBoxZone("BGrill2", vec3(-1202.64, -897.27, 14.0-1), 0.7, 1.2, { name="BGrill2", heading = 122.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = Config.Locations[1].job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(-1202.64, -897.27, 14.0) }, },
					distance = 1.5 })
			Targets["BFryer"] =
			exports['qb-target']:AddBoxZone("BFryer", vec3(-1201.4, -898.98, 13.98-1), 0.7, 2.5, { name="BFryer", heading = 123.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = Config.Locations[1].job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(-1201.4, -898.98, 13.98) }, },
					distance = 1.5 })
			Targets["BChop"] =
			exports['qb-target']:AddBoxZone("BChop", vec3(-1199.38, -902.07, 14.0-1), 0.6, 1.5, { name="BChop", heading = 123.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = Config.Locations[1].job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(-1199.38, -902.07, 14.0) }, },
					distance = 1.5 })
			Targets["BPrepare"] =
			exports['qb-target']:AddBoxZone("BPrepare", vec3(-1198.37, -898.36, 13.98-1), 1.8, 3.2, { name="BPrepare", heading = 123.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = Config.Locations[1].job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(-1198.37, -898.36, 13.98) }, },
					distance = 1.5 })
			Targets["BDrink"] =
			exports['qb-target']:AddBoxZone("BDrink", vec3(-1199.47, -895.44, 13.9953-1), 0.6, 1.7, { name="BDrink", heading = 122.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 15.0, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1199.47, -895.44, 13.9953) }, },
					distance = 1.5 })
			Targets["BDonut"] =
			exports['qb-target']:AddBoxZone("BDonut", vec3(-1203.35, -895.66, 13.9952-1), 0.7, 1.0, { name="BDonut", heading = 122.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = Config.Locations[1].job, craftable = Crafting.Donut, header = Loc[Config.Lan].menu["food_cabinet"], coords = vec3(-1203.35, -895.66, 13.9952) }, },
					distance = 1.5 })

			--Trays

			Targets["BTray1"] =
			exports['qb-target']:AddBoxZone("BTray1", vec3(-1196.3, -890.7, 14.0), 0.6, 1.0, { name="BTray1", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray1" }, },
					distance = 2.0 })

			Targets["BTray2"] =
			exports['qb-target']:AddBoxZone("BTray2", vec3(-1195.0, -892.68, 14.0), 0.6, 1.0, { name="BTray2", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray2" }, },
					distance = 2.0 })

			Targets["BTray3"] =
			exports['qb-target']:AddBoxZone("BTray3", vec3(-1193.86, -894.4, 14.0), 0.6, 1.0, { name="BTray3", heading = 215.0, debugPoly=Config.Debug, minZ = 13.5, maxZ = 14.8, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSTray3" }, },
					distance = 2.0 })

			--Hand Washing
			Targets["BWash1"] =
			exports['qb-target']:AddBoxZone("BWash1", vec3(-1197.12, -902.07, 13.98-1), 0.6, 1.0, { name="BWash1", heading = 215.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash2"] =
			exports['qb-target']:AddBoxZone("BWash2", vec3(-1198.23, -902.78, 13.98-1), 1.1, 0.8, { name="BWash2", heading = 215.65, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash3"] =
			exports['qb-target']:AddBoxZone("BWash3", vec3(-1200.7, -888.98, 14.0-1), 0.6, 0.6, { name="BWash3", heading = 34.93, debugPoly=Config.Debug, minZ = 13.2, maxZ = 14.6, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash4"] =
			exports['qb-target']:AddBoxZone("BWash4", vec3(-1198.57, -887.54, 14.0-1), 0.6, 0.6, { name="BWash4", heading = 215.0, debugPoly=Config.Debug, minZ = 13.2, maxZ = 14.6, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })

			--Payments / Clockin
			Targets["BReceipt"] =
			exports['qb-target']:AddCircleZone("BReceipt", vec3(-1196.04, -891.38, 14.15), 0.5, { name="BReceipt", debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job }, },
					distance = 1.5 })
			Targets["BReceipt2"] =
			exports['qb-target']:AddCircleZone("BReceipt2", vec3(-1194.7, -893.32, 14.15), 0.5, { name="BReceipt2", debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job, }, },
					distance = 1.5 })
			Targets["BReceipt3"] =
			exports['qb-target']:AddCircleZone("BReceipt3", vec3(-1193.42, -895.22, 14.15), 0.5, { name="BReceipt3", debugPoly=Config.Debug, useZ=true, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,}, },
					distance = 2.0 })
			Targets["BClockin"] =
			exports['qb-target']:AddBoxZone("BClockin", vec3(-1193.18, -898.13, 14.2), 0.6, 2.5, { name="BClockin", heading = 35.0, debugPoly=Config.Debug, minZ = 14.2, maxZ = 15.2, },
					{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = Config.Locations[1].job },
								{ event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
								}, distance = 2.0 })

		elseif loc.MLO == "NP" then
			--Targets
			--Stash/Shops

			Targets["BShelf"] =
			exports['qb-target']:AddBoxZone("BShelf", vec3(-1197.4, -894.58, 13.98), 1.5, 1.0, { name="BShelf", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1197.4, -894.58, 13.98) }, },
					distance = 2.0 })
			Targets["BShelf2"] =
			exports['qb-target']:AddBoxZone("BShelf2", vec3(-1198.26, -893.33, 13.98), 1.5, 1.0, { name="BShelf2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1198.26, -893.33, 13.98) }, },
					distance = 2.0 })
			Targets["BFridge"] =
			exports['qb-target']:AddBoxZone("BFridge", vec3(-1196.71, -901.79, 13.98), 1.6, 0.5, { name="BFridge", heading = 304.0, debugPoly=Config.Debug, minZ = 13.33, maxZ = 15.53, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_fridge"], job = Config.Locations[1].job, id = "BSFridge", coords = vec3(-1196.71, -901.79, 13.988) }, },
					distance = 1.5 })
			Targets["BStore"] =
			exports['qb-target']:AddBoxZone("BStore", vec3(-1205.01, -893.89, 13.98), 2.5, 0.6, { name="BStore", heading = 34.0, debugPoly=Config.Debug, minZ = 12.97, maxZ = 15.37, },
				{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = Config.Locations[1].job, id = "BSShop", shop = Config.Items, coords = vec3(-1205.01, -893.89, 13.98) }, },
					distance = 1.5 })
			Targets["BBag"] =
			exports['qb-target']:AddBoxZone("BBag", vec3(-1197.78, -891.46, 13.98), 2.1, 0.7, { name="BBag", heading = 304.0, debugPoly=Config.Debug, minZ = 13.38, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, }, },
					distance = 2.0 })
			Targets["BBag2"] =
			exports['qb-target']:AddBoxZone("BBag2", vec3(-1196.19, -905.02, 13.98), 2.5, 0.7, { name="BBag2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, }, },
					distance = 2.0 })

			--Food Makingd
			Targets["BGrill"] =
			exports['qb-target']:AddBoxZone("BGrill", vec3(-1202.8, -897.25, 13.98), 1.7, 0.7, { name="BGrill", heading = 34.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = Config.Locations[1].job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(-1202.8, -897.25, 13.98) }, },
					distance = 1.5 })
			Targets["BFryer"] =
			exports['qb-target']:AddBoxZone("BFryer", vec3(-1201.85, -898.62, 13.98), 1.7, 0.8, { name="BFryer", heading = 34.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = Config.Locations[1].job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(-1201.85, -898.62, 13.98) }, },
					distance = 1.5 })
			Targets["BChop"] =
			exports['qb-target']:AddBoxZone("BChop", vec3(-1198.33, -898.66, 13.98), 1.8, 0.6, { name="BChop", heading = 304.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = Config.Locations[1].job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(-1198.33, -898.66, 13.98) }, },
					distance = 1.5 })
			Targets["BPrepare"] =
			exports['qb-target']:AddBoxZone("BPrepare", vec3(-1199.62, -897.78, 13.98), 1.7, 0.6, { name="BPrepare", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = Config.Locations[1].job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(-1199.62, -897.78, 13.98) }, },
					distance = 1.5 })
			Targets["BDrink"] =
			exports['qb-target']:AddBoxZone("BDrink", vec3(-1199.85, -895.35, 13.98), 2.35, 0.6, { name="BDrink", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1199.85, -895.35, 13.98) }, },
					distance = 1.5 })
			Targets["BDrink2"] =
			exports['qb-target']:AddBoxZone("BDrink2", vec3(-1190.07, -904.51, 13.98), 2.35, 0.6, { name="BDrink2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1190.07, -904.51, 13.98) }, },
					distance = 1.5 })
			Targets["BDonut"] =
			exports['qb-target']:AddBoxZone("BDonut", vec3(-1203.45, -895.67, 13.98),1.5, 0.5, { name="BDonut", heading = 34.0, debugPoly=Config.Debug, minZ = 13.97, maxZ = 15.17, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = Config.Locations[1].job, craftable = Crafting.Donut, header = Loc[Config.Lan].targetinfo["food_cabinet"], coords = vec3(-1203.45, -895.67, 13.98) }, },
					distance = 1.5 })

			--Trays
			Targets["BTray1"] =
			exports['qb-target']:AddBoxZone("BTray1", vec3(-1195.88, -891.31, 14.2), 0.6, 1.0, { name="BTray1", heading = 215.0, debugPoly=Config.Debug, minZ = 14.0, maxZ = 15.35, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "Tray1" }, },
					distance = 2.0 })
			Targets["BTray2"] =
			exports['qb-target']:AddBoxZone("BTray2", vec3(-1194.99, -892.92, 14.2), 0.6, 1.1, { name="BTray2", heading = 215.0, debugPoly=Config.Debug, minZ = 14.0, maxZ = 15.35, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "Tray2" }, },
					distance = 2.0 })
			Targets["BTray3"] =
			exports['qb-target']:AddBoxZone("BTray3", vec3(-1193.88, -894.37, 14.2), 0.6, 1.0, { name="BTray3", heading = 215.0, debugPoly=Config.Debug, minZ = 14.0, maxZ = 15.35, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "Tray3" }, },
					distance = 2.0 })

			--Hand Washing
			Targets["BWash1"] =
			exports['qb-target']:AddBoxZone("BWash1", vec3(-1199.41, -886.27, 13.98), 0.6, 0.6, { name="BWash1", heading = 305.0, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash2"] =
			exports['qb-target']:AddBoxZone("BWash2", vec3(-1201.92, -887.98, 13.98), 0.6, 0.6, { name="BWash2", heading = 305.0, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash3"] =
			exports['qb-target']:AddBoxZone("BWash3", vec3(-1200.24, -901.13, 13.88), 0.8, 0.85, { name="BWash3", heading = 34.0, debugPoly=Config.Debug, minZ = 13.38, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash4"] =
			exports['qb-target']:AddBoxZone("BWash4", vec3(-1191.73, -901.48, 13.98), 0.82, 0.75, { name="BWash4", heading = 34.0, debugPoly=Config.Debug, minZ = 13.38, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })
			Targets["BWash5"] =
			exports['qb-target']:AddBoxZone("BWash5", vec3(-1181.53, -899.43, 13.98), 0.82, 0.75, { name="BWash5", heading = 34.0, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })

			--Payments / Clockin
			Targets["BReceipt"] =
			exports['qb-target']:AddBoxZone("BReceipt", vec3(-1194.23, -893.87, 13.98), 0.35, 1.0, { name="BReceipt", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })

			Targets["BReceipt2"] =
			exports['qb-target']:AddBoxZone("BReceipt2", vec3(-1195.28, -892.35, 13.98), 0.35, 1.0, { name="BReceipt2", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt3"] =
			exports['qb-target']:AddBoxZone("BReceipt3", vec3(-1196.29, -890.82, 13.98), 0.55, 1.0, { name="BReceipt3", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt4"] =
			exports['qb-target']:AddBoxZone("BReceipt4", vec3(-1192.74, -906.44, 13.98), 0.55, 1.0, { name="BReceipt4", heading = 324.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })

			Targets["BClockin"] =
			exports['qb-target']:AddBoxZone("BClockin", vec3(-1191.52, -900.58, 13.98), 1.4, 0.2, { name="BClockin", heading = 34.0, debugPoly=Config.Debug, minZ = 14.18, maxZ = 15.38, },
					{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = Config.Locations[1].job },
								}, distance = 2.0 })
			Targets["BClockin2"] =
			exports['qb-target']:AddBoxZone("BClockin2", vec3(-1178.11, -896.3, 13.98), 0.8, 0.5, { name="BClockin2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.58, },
					{ options = { { event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
					}, distance = 2.0 })
		elseif loc.MLO == "RZ" then
			propTable[#propTable+1] = { prop = "v_ret_247_donuts", coords = vec4(-1199.82, -902.03, 14.0, 120) }
			--Targets
			--Tables
			for a, x in pairs({
				vec3(-1190.89, -891.97, 14.0), vec3(-1193.43, -888.21, 14.0),
				vec3(-1194.16, -883.59, 14.0), vec3(-1191.75, -881.86, 14.0),
				vec3(-1189.08, -880.75, 14.0), vec3(-1187.23, -882.49, 14.0),
				vec3(-1187.05, -889.39, 14.0), vec3(-1183.29, -888.22, 14.0),
				vec3(-1182.18, -890.69, 14.0), vec3(-1184.38, -892.82, 14.0),
				vec3(-1186.87, -894.56, 14.0), vec3(-1189.55, -885.68, 14.0),
				vec3(-1191.73, -886.58, 14.0), vec3(-1188.62, -891.31, 14.0),
			}) do
				Targets["RZTables"..a] =
				exports ['qb-target']:AddBoxZone("RZTables"..a, vec3(x.x,x.y,x.z-1), 0.6, 0.6,
				{ name = "RZTables"..a, heading = 35, debugPoly = Config.Debug, minZ = x.z-1, maxZ = x.z+0.5, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_table"], id = "BS_Table"..a, coords = loc.xyz,},}, distance = 2.0})
			end
			--Stash/Shops

			Targets["BShelf"] =
			exports['qb-target']:AddBoxZone("BShelf", vec3(-1196.69, -895.51, 14.0), 1.5, 1.3, { name="BShelf", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1196.69, -895.51, 14.0) }, },
					distance = 2.0 })
			Targets["BShelf2"] =
			exports['qb-target']:AddBoxZone("BShelf2", vec3(-1198.53, -893.04, 14.0), 1.5, 1.3, { name="BShelf2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = Config.Locations[1].job, id = "BSShelf", coords = vec3(-1198.53, -893.04, 14.0) }, },
					distance = 2.0 })
			Targets["BStore"] =
			exports['qb-target']:AddBoxZone("BStore", vec3(-1203.45, -895.67, 13.98-1), 1.6, 0.5, { name="BStore", heading = 34.0, debugPoly=Config.Debug, minZ = 12.97, maxZ = 15.37, },
				{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = Config.Locations[1].job, id = "BSShop", shop = Config.Items, coords = vec3(-1203.45, -895.67, 13.98) }, },
					distance = 1.5 })
			Targets["BBag"] =
			exports['qb-target']:AddBoxZone("BBag", vec3(-1197.56, -894.27, 14.0-1), 1.6, 0.8, { name="BBag", heading = 34.0, debugPoly=Config.Debug, minZ = 12.97, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, },
				{ event = "jim-burgershot:shop", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_toy"], job = Config.Locations[1].job, shop = Config.Toy },},
					distance = 2.0 })
			Targets["BBag2"] =
			exports['qb-target']:AddBoxZone("BBag2", vec3(-1196.56, -904.73, 14.0-1), 2.5, 0.7, { name="BBag2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = Config.Locations[1].job, },
							{ event = "jim-burgershot:shop", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_toy"], job = Config.Locations[1].job, shop = Config.Toy },},
					distance = 2.0 })

			--Food Makingd
			Targets["BGrill"] =
			exports['qb-target']:AddBoxZone("BGrill", vec3(-1202.8, -897.25, 13.98-1), 1.7, 0.7, { name="BGrill", heading = 34.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = Config.Locations[1].job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(-1202.8, -897.25, 13.98) }, },
					distance = 1.5 })
			Targets["BFryer"] =
			exports['qb-target']:AddBoxZone("BFryer", vec3(-1201.64, -899.09, 14.0-1), 2.2, 0.8, { name="BFryer", heading = 34.0, debugPoly=Config.Debug, minZ = 13.3, maxZ = 14.5, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = Config.Locations[1].job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(-1201.64, -899.09, 14.0) }, },
					distance = 1.5 })
			Targets["BChop"] =
			exports['qb-target']:AddBoxZone("BChop", vec3(-1197.6, -899.36, 14.0-0.5), 1.8, 0.6, { name="BChop", heading = 304.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = Config.Locations[1].job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(-1197.6, -899.36, 14.0) }, },
					distance = 1.5 })
			Targets["BPrepare"] =
			exports['qb-target']:AddBoxZone("BPrepare", vec3(-1198.21, -897.82, 14.0-0.5), 1.7, 0.6, { name="BPrepare", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = Config.Locations[1].job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(-1199.82, -902.03, 14.0) }, },
					distance = 1.5 })
			Targets["BDrink"] =
			exports['qb-target']:AddBoxZone("BDrink", vec3(-1199.51, -895.58, 14.0), 2.35, 0.6, { name="BDrink", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1199.51, -895.58, 14.0) }, },
					distance = 1.5 })
			Targets["BDrink2"] =
			exports['qb-target']:AddBoxZone("BDrink2", vec3(-1189.11, -905.25, 14.0), 1.4, 0.6, { name="BDrink", heading = 35.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.78, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = Config.Locations[1].job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(-1189.11, -905.25, 14.0) }, },
					distance = 1.5 })
			Targets["BDonut"] =
			exports['qb-target']:AddBoxZone("BDonut", vec3(-1199.82, -902.03, 14.0-0.5),1.0, 0.5, { name="BDonut", heading = 34.0, debugPoly=Config.Debug, minZ = 13.97, maxZ = 15.17, },
				{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = Config.Locations[1].job, craftable = Crafting.Donut, header = Loc[Config.Lan].targetinfo["food_cabinet"], coords = vec3(-1199.82, -902.03, 14.0) }, },
					distance = 1.5 })

			--Trays
			Targets["BTray1"] =
			exports['qb-target']:AddBoxZone("BTray1", vec3(-1195.4, -892.22, 14.0), 0.6, 0.6, { name="BTray1", heading = 215.0, debugPoly=Config.Debug, minZ = 14.0, maxZ = 15.35, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "Tray1" }, },
					distance = 2.0 })
			Targets["BTray2"] =
			exports['qb-target']:AddBoxZone("BTray2", vec3(-1194.07, -894.18, 14.0), 0.6, 0.6, { name="BTray2", heading = 215.0, debugPoly=Config.Debug, minZ = 14.0, maxZ = 15.35, },
				{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "Tray2" }, },
					distance = 2.0 })

			--Hand Washing
			Targets["BWash1"] =
			exports['qb-target']:AddBoxZone("BWash1", vec3(-1197.04, -902.23, 14.0-1), 0.6, 0.6, { name="BWash1", heading = 216.5, debugPoly=Config.Debug, minZ = 13.18, maxZ = 14.38, },
				{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
					distance = 2.0 })

			--Payments / Clockin
			Targets["BReceipt"] =
			exports['qb-target']:AddBoxZone("BReceipt", vec3(-1193.38, -895.19, 14.0), 0.6, 0.6, { name="BReceipt", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })

			Targets["BReceipt2"] =
			exports['qb-target']:AddBoxZone("BReceipt2", vec3(-1194.67, -893.29, 14.0), 0.6, 0.6, { name="BReceipt2", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt3"] =
			exports['qb-target']:AddBoxZone("BReceipt3", vec3(-1196.03, -891.3, 14.0), 0.6, 0.6, { name="BReceipt3", heading = 35.0, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })
			Targets["BReceipt4"] =
			exports['qb-target']:AddBoxZone("BReceipt4", vec3(-1192.52, -906.67, 14.98-1.1), 0.6, 0.6, { name="BReceipt4", heading = 350, debugPoly=Config.Debug, minZ = 13.98, maxZ = 14.58, },
				{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = Config.Locations[1].job,
								img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" }, },
					distance = 1.5 })

			Targets["BClockin"] =
			exports['qb-target']:AddBoxZone("BClockin", vec3(-1196.8, -902.89, 14.0), 1.4, 0.2, { name="BClockin", heading = 304, debugPoly=Config.Debug, minZ = 14.18, maxZ = 15.38, },
					{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = Config.Locations[1].job },
								}, distance = 2.0 })
			Targets["BClockin2"] =
			exports['qb-target']:AddBoxZone("BClockin2", vec3(-1191.97, -901.06, 14.0), 0.8, 0.5, { name="BClockin2", heading = 34.0, debugPoly=Config.Debug, minZ = 13.78, maxZ = 14.58, },
					{ options = { { event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
					}, distance = 2.0 })
		end
	end
	--Atm Props
	propTable[#propTable+1] = { prop = "prop_atm_01", coords = vec4(-1184.53, -882.85, 13.94-0.22, 122.53) }
	propTable[#propTable+1] = { prop = "prop_atm_01", coords = vec4(-1199.6, -884.99, 13.50-0.22, 215.0) }
	propTable[#propTable+1] = { prop = "prop_bench_01a", coords = vec4(-1195.53, -878.53, 13.5, 212.0) }

	if Config.Locations[2].zoneEnable then	-- [[ GNMODS MIRROR PARK ]] --
		print("true")
		local loc = Config.Locations[2]
		local bossroles = {}
		for grade in pairs(QBCore.Shared.Jobs[loc.job].grades) do
			if QBCore.Shared.Jobs[loc.job].grades[grade].isboss == true then
				if bossroles[loc.job] then
					if bossroles[loc.job] > tonumber(grade) then bossroles[loc.job] = tonumber(grade) end
				else bossroles[loc.job] = tonumber(grade) end
			end
		end
		if loc.blip then Blips[#Blips+1] = makeBlip({coords = loc.blip, sprite = loc.blipsprite or 106, col = loc.blipcolor, scale = loc.blipscale, disp = loc.blipdisp, category = nil, name = loc.label}) end

		if loc.zones then
			JobLocation = PolyZone:Create(loc.zones, { name = loc.label, debugPoly = Config.Debug })
			JobLocation:onPlayerInOut(function(isPointInside)
				if PlayerJob.name == loc.job then
					if loc.autoClock and loc.autoClock.enter then if isPointInside and not onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
					if loc.autoClock and loc.autoClock.exit then if not isPointInside and onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
				end
			end)
		end
		--Stash/Shops
		Targets["BSMShelf"] =
		exports['qb-target']:AddBoxZone("BSMShelf", vec3(1248.35, -354.0, 68.21), 3.0, 1.0, { name="BSMShelf", heading = 75.0, debugPoly=Config.Debug, minZ = 68.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = loc.job, id = "BSMShelf", coords = vec3(1248.35, -354.0, 68.21) }, },
				distance = 2.0 })
		Targets["BSMFridge"] =
		exports['qb-target']:AddBoxZone("BSMFridge", vec3(1254.09, -346.85, 68.21), 2.9, 0.7, { name="BSMFridge", heading = 75.0, debugPoly=Config.Debug, minZ = 68.21, maxZ = 70.41 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_fridge"], job = loc.job, id = "BSMFridge", coords = vec3(1254.09, -346.85, 68.21) }, },
				distance = 1.5 })

		Targets["BSMShop"] =
		exports['qb-target']:AddBoxZone("BSMShop", vec3(1255.54, -348.84, 68.21), 2.9, 0.7, { name="BSMShop", heading = 345.0, debugPoly=Config.Debug, minZ = 68.21, maxZ = 70.41 },
			{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = loc.job, id = "BSMShop", shop = Config.Items, coords = vec3(1255.54, -348.84, 68.21) }, },
				distance = 1.5 })

		Targets["BSMBag"] =
		exports['qb-target']:AddBoxZone("BSMBag", vec3(1251.9, -358.86, 69.01), 1.0, 0.5, { name="BSMBag", heading = 75.0, debugPoly=Config.Debug, minZ=69.01, maxZ=70.01 },
			{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = loc.job, }, },
				distance = 2.0 })

		--Food Making
		Targets["BSMGrill"] =
		exports['qb-target']:AddBoxZone("BSMGrill", vec3(1253.42, -355.18, 68.21), 1.6, 0.6, { name="BSMGrill", heading = 345.0, debugPoly=Config.Debug, minZ = 68.21, maxZ = 69.41, },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = loc.job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(1253.42, -355.18, 68.21) }, },
				distance = 1.5 })
		Targets["BSMFryer"] =
		exports['qb-target']:AddBoxZone("BSMFryer", vec3(1254.32, -352.18, 68.21), 1.6, 0.6, { name="BSMFryer", heading = 345.0, debugPoly=Config.Debug, minZ = 68.21, maxZ = 69.41 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = loc.job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(1254.32, -352.18, 68.21) }, },
				distance = 1.5 })
		Targets["BSMChop"] =
		exports['qb-target']:AddBoxZone("BSMChop", vec3(1249.57, -352.28, 68.21), 0.6, 2.9, { name="BSMChop", heading = 75.0, debugPoly=Config.Debug, minZ = 68.41, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = loc.job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(1249.57, -352.28, 68.21) }, },
				distance = 1.5 })
		Targets["BSMPrepare"] =
		exports['qb-target']:AddBoxZone("BSMPrepare", vec3(1248.1, -351.95, 68.21), 0.6, 2.9, { name="BSMPrepare", heading = 75.0, debugPoly=Config.Debug, minZ = 68.41, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = loc.job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(1248.1, -351.95, 68.21) }, },
				distance = 1.5 })
		Targets["BSMDrink"] =
		exports['qb-target']:AddBoxZone("BSMDrink", vec3(1244.77, -353.21, 69.21), 0.6, 0.9, { name="BSMDrink", heading = 345.0, debugPoly=Config.Debug, minZ = 69.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = loc.job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(1244.77, -353.21, 69.21) }, },
				distance = 1.5 })
		Targets["BSMDonut"] =
		exports['qb-target']:AddBoxZone("BSMDonut", vec3(1245.5, -353.42, 69.21), 0.6, 0.6, { name="BSMDonut", heading = 345.0, debugPoly=Config.Debug, minZ = 69.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = loc.job, craftable = Crafting.Donut, header = Loc[Config.Lan].menu["food_cabinet"], coords = vec3(1245.5, -353.42, 69.21) }, },
				distance = 1.5 })

		--Trays
		Targets["BSMTray1"] =
		exports['qb-target']:AddBoxZone("BSMTray1", vec3(1248.07, -356.25, 69.21), 0.6, 1.0, { name="BSMTray1", heading = 75.0, debugPoly=Config.Debug, minZ = 69.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSMTray1" }, },
				distance = 2.0 })
		Targets["BSMTray2"] =
		exports['qb-target']:AddBoxZone("BSMTray2", vec3(1246.12, -355.72, 69.21), 0.6, 1.0, { name="BSMTray2", heading = 75.0, debugPoly=Config.Debug, minZ = 69.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSMTray2" }, },
				distance = 2.0 })
		Targets["BSMTray3"] =
		exports['qb-target']:AddBoxZone("BSMTray3", vec3(1244.31, -355.22, 69.21), 0.6, 1.0, { name="BSMTray3", heading = 75.0, debugPoly=Config.Debug, minZ = 69.21, maxZ = 70.01 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSMTray3" }, },
				distance = 2.0 })

		--Hand Washing
		Targets["BSMWash1"] =
		exports['qb-target']:AddBoxZone("BSMWash1", vec3(1239.16, -353.85, 68.2), 0.7, 0.7, { name="BSMWash1", heading = 345.0, debugPoly=Config.Debug,minZ=68.2, maxZ=69.41 },
			{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
				distance = 2.0 })
		Targets["BSMWash2"] =
		exports['qb-target']:AddBoxZone("BSMWash2", vec3(1245.36, -352.29, 68.2), 1.2, 0.7, { name="BSMWash2", heading = 75.0, debugPoly=Config.Debug, minZ=68.2, maxZ=69.41 },
			{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
				distance = 2.0 })

		--Payments / Clockin
		Targets["BSMReceipt"] =
			exports['qb-target']:AddBoxZone("BSMReceipt", vec3(1248.83, -356.41, 69.21), 0.6, 0.6, { name="BSMReceipt", heading = 345.0, debugPoly=Config.Debug, minZ = 69.26, maxZ = 70.01, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })
		Targets["BSMReceipt2"] =
			exports['qb-target']:AddBoxZone("BSMReceipt2", vec3(1246.82, -355.88, 69.21), 0.6, 0.6, { name="BSMReceipt2", heading = 345.0, debugPoly=Config.Debug, minZ = 69.26, maxZ = 70.01, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })
		Targets["BSMReceipt3"] =
			exports['qb-target']:AddBoxZone("BSMReceipt3", vec3(1245.08, -355.42, 69.21), 0.6, 0.6, { name="BSMReceipt3", heading = 345.0, debugPoly=Config.Debug, minZ = 69.26, maxZ = 70.01, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })

		Targets["BSMClockin"] =
		exports['qb-target']:AddBoxZone("BSMClockin", vec3(1249.85, -346.16, 68.71), 0.6, 0.6, { name="BSMClockin", heading = 345.0, debugPoly=Config.Debug, minZ = 69.26, maxZ = 70.01, },
				{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
							{ event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
							}, distance = 2.0 })
	end

	if Config.Locations[3].zoneEnable then -- [[ GNMODS SANDY SHORES ]] --
		local loc = Config.Locations[3]
		local bossroles = {}
		for grade in pairs(QBCore.Shared.Jobs[loc.job].grades) do
			if QBCore.Shared.Jobs[loc.job].grades[grade].isboss == true then
				if bossroles[loc.job] then
					if bossroles[loc.job] > tonumber(grade) then bossroles[loc.job] = tonumber(grade) end
				else bossroles[loc.job] = tonumber(grade) end
			end
		end
		if loc.blip then Blips[#Blips+1] = makeBlip({coords = loc.blip, sprite = loc.blipsprite or 106, col = loc.blipcolor, scale = loc.blipscale, disp = loc.blipdisp, category = nil, name = loc.label}) end
		if loc.zones then
			JobLocation = PolyZone:Create(loc.zones, { name = loc.label, debugPoly = Config.Debug })
			JobLocation:onPlayerInOut(function(isPointInside)
				if PlayerJob.name == loc.job then
					if loc.autoClock and loc.autoClock.enter then if isPointInside and not onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
					if loc.autoClock and loc.autoClock.exit then if not isPointInside and onDuty then TriggerServerEvent("QBCore:ToggleDuty") end end
				end
			end)
		end
		--Stash/Shops
		Targets["BSSShelf"] =
		exports['qb-target']:AddBoxZone("BSSShelf", vec3(1591.7, 3752.59, 34.43-1), 3.0, 1.0, { name="BSSShelf", heading = 35.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-box-open", label = Loc[Config.Lan].targetinfo["open_shelves"], job = loc.job, id = "BSSShelf", coords = vec3(1591.7, 3752.59, 34.43) }, },
				distance = 2.0 })
		Targets["BSSFridge"] =
		exports['qb-target']:AddBoxZone("BSSFridge", vec3(1600.67, 3754.59, 34.44-1), 2.9, 0.7, { name="BSSFridge", heading = 35.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_fridge"], job = loc.job, id = "BSSFridge", coords = vec3(1600.67, 3754.59, 34.44) }, },
				distance = 1.5 })

		Targets["BSSShop"] =
		exports['qb-target']:AddBoxZone("BSSShop", vec3(1600.46, 3752.17, 34.44-1), 2.9, 0.7, { name="BSSShop", heading = 306.0, debugPoly=Config.Debug, minZ = 33.63, maxZ = 35.43 },
			{ options = { { event = "jim-burgershot:Shop", icon = "fas fa-temperature-low", label = Loc[Config.Lan].targetinfo["open_storage"], job = loc.job, id = "BSSShop", shop = Config.Items, coords = vec3(1600.46, 3752.17, 34.44) }, },
				distance = 1.5 })

		Targets["BSSBag"] =
		exports['qb-target']:AddBoxZone("BSSBag", vec3(1591.43, 3746.62, 34.43-0.4), 1.0, 0.5, { name="BSSBag", heading = 36.0, debugPoly=Config.Debug, minZ = 34.03, maxZ = 35.03 },
			{ options = { { event = "jim-burgershot:client:GrabBag", icon = "fas fa-bag-shopping", label = Loc[Config.Lan].targetinfo["grab_murderbag"], job = loc.job, }, },
				distance = 2.0 })

		--Food Making
		Targets["BSSGrill"] =
		exports['qb-target']:AddBoxZone("BSSGrill", vec3(1594.89, 3748.51, 34.43-1), 1.6, 0.6, { name="BSSGrill", heading = 306.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43, },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-fire", label = Loc[Config.Lan].targetinfo["use_grill"], job = loc.job, craftable = Crafting.Grill, header = Loc[Config.Lan].menu["grill"], coords = vec3(1594.89, 3748.51, 34.43) }, },
				distance = 1.5 })
		Targets["BSSFryer"] =
		exports['qb-target']:AddBoxZone("BSSFryer", vec3(1597.46, 3750.25, 34.43-1), 1.6, 0.6, { name="BSSFryer", heading = 306.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-temperature-high", label = Loc[Config.Lan].targetinfo["use_deepfryer"], job = loc.job, craftable = Crafting.Fryer, header = Loc[Config.Lan].menu["deep_fat_fryer"], coords = vec3(1597.46, 3750.25, 34.43) }, },
				distance = 1.5 })
		Targets["BSSChop"] =
		exports['qb-target']:AddBoxZone("BSSChop", vec3(1593.61, 3753.22, 34.43-1), 0.6, 2.9, { name="BSSChop", heading = 36.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-utensils", label = Loc[Config.Lan].targetinfo["use_chopping_board"], job = loc.job, craftable = Crafting.ChopBoard, header = Loc[Config.Lan].menu["chopping_board"], coords = vec3(1593.61, 3753.22, 34.43) }, },
				distance = 1.5 })
		Targets["BSSPrepare"] =
		exports['qb-target']:AddBoxZone("BSSPrepare", vec3(1592.9, 3754.27, 34.44-1), 0.6, 2.9, { name="BSSPrepare", heading = 36.0, debugPoly=Config.Debug, minZ = 33.63, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["prepare_food"], job = loc.job, craftable = Crafting.Prepare, header = Loc[Config.Lan].menu["prepare_food"], coords = vec3(1592.9, 3754.27, 34.44) }, },
				distance = 1.5 })
		Targets["BSSDrink"] =
		exports['qb-target']:AddBoxZone("BSSDrink", vec3(1589.49, 3755.53, 34.43), 0.6, 0.9, { name="BSSDrink", heading = 306.0, debugPoly=Config.Debug, minZ = 34.43, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-mug-hot", label = Loc[Config.Lan].targetinfo["prepare_drinks"], job = loc.job, craftable = Crafting.Drink, header = Loc[Config.Lan].menu["drinks_dispenser"], coords = vec3(1589.49, 3755.53, 34.43) }, },
				distance = 1.5 })
		Targets["BSSDonut"] =
		exports['qb-target']:AddBoxZone("BSSDonut", vec3(1589.96, 3754.94, 34.43), 0.6, 0.7, { name="BSSDonut", heading = 36.0, debugPoly=Config.Debug, minZ = 34.43, maxZ= 35.43 },
			{ options = { { event = "jim-burgershot:Crafting", icon = "fas fa-dot-circle", label = Loc[Config.Lan].targetinfo["open_cabinet"], job = loc.job, craftable = Crafting.Donut, header = Loc[Config.Lan].menu["food_cabinet"], coords = vec3(1589.96, 3754.94, 34.43) }, },
				distance = 1.5 })

		--Trays
		Targets["BSSTray1"] =
		exports['qb-target']:AddBoxZone("BSSTray1", vec3(1590.05, 3751.01, 34.43), 0.6, 1.0, { name="BSSTray1", heading = 36.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSSTray1" }, },
				distance = 2.0 })
		Targets["BSSTray2"] =
		exports['qb-target']:AddBoxZone("BSSTray2", vec3(1588.92, 3752.63, 34.43), 0.6, 1.0, { name="BSSTray2", heading = 36.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSSTray2" }, },
				distance = 2.0 })
		Targets["BSSTray3"] =
		exports['qb-target']:AddBoxZone("BSSTray3", vec3(1587.69, 3754.16, 34.43), 0.6, 1.0, { name="BSSTray3", heading = 36.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23 },
			{ options = { { event = "jim-burgershot:Stash", icon = "fas fa-hamburger", label = Loc[Config.Lan].targetinfo["open_tray"], id = "BSSTray3" }, },
				distance = 2.0 })

		--Hand Washing
		Targets["BSSWash1"] =
		exports['qb-target']:AddBoxZone("BSSWash1", vec3(1584.68, 3758.56, 34.43-1), 0.7, 0.7, { name="BSSWash1", heading = 36.0, debugPoly=Config.Debug, minZ=33.63, maxZ=35.03 },
			{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
				distance = 2.0 })
		Targets["BSSWash2"] =
		exports['qb-target']:AddBoxZone("BSSWash2", vec3(1590.42, 3755.76, 34.43-1), 1.2, 0.7, { name="BSSWash2", heading = 36.0, debugPoly=Config.Debug, minZ=33.63, maxZ=35.03 },
			{ options = { { event = "jim-burgershot:washHands", icon = "fas fa-hand-holding-water", label = Loc[Config.Lan].targetinfo["wash_hands"], }, },
				distance = 2.0 })

		--Payments / Clockin
		Targets["BSSReceipt"] =
			exports['qb-target']:AddBoxZone("BSSReceipt", vec3(1590.51, 3750.41, 34.43), 0.6, 0.6, { name="BSSReceipt", heading = 35.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })
		Targets["BSSReceipt2"] =
			exports['qb-target']:AddBoxZone("BSSReceipt2", vec3(1589.29, 3752.05, 34.43), 0.6, 0.6, { name="BSSReceipt2", heading = 35.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							--{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })
		Targets["BSSReceipt3"] =
			exports['qb-target']:AddBoxZone("BSSReceipt3", vec3(1588.23, 3753.52, 34.43), 0.6, 0.6, { name="BSSReceipt3", heading = 35.0, debugPoly=Config.Debug, minZ = 34.43, maxZ = 35.23, },
			{ options = { { event = "jim-payments:client:Charge", icon = "fas fa-credit-card", label = Loc[Config.Lan].targetinfo["charge_customer"], job = loc.job,
							img = "<center><p><img src=https://static.wikia.nocookie.net/gtawiki/images/b/bf/BurgerShot-HDLogo.svg width=225px></p>" },
							--{ type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
						},	distance = 1.5 })

		Targets["BSSClockin"] =
		exports['qb-target']:AddBoxZone("BSSClockin", vec3(1597.95, 3758.02, 34.44-0.5), 0.6, 0.6, { name="BSSClockin", heading = 50.0, debugPoly=Config.Debug, minZ = 33.84, maxZ = 35.04, },
				{ options = { { type = "server", event = "QBCore:ToggleDuty", icon = "fas fa-user-check", label = Loc[Config.Lan].targetinfo["toggle_duty"], job = loc.job },
							{ event = "qb-bossmenu:client:OpenMenu", icon = "fas fa-list", label = Loc[Config.Lan].targetinfo["open_bossmenu"], job = bossroles, },
							}, distance = 2.0 })
	end
	for _, prop in pairs(propTable) do Props[#Props+1] = makeProp(prop, true, false) end
end)

RegisterNetEvent('jim-burgershot:washHands', function(data)
	if progressBar({ label = Loc[Config.Lan].progressbar["washing_hands"], time = 5000, cancel = true, dict = "mp_arresting", anim = "a_uncuff", flag = 8, icon = "fas fa-hand-holding-droplet" }) then
		triggerNotify(nil, Loc[Config.Lan].success["have_washed_hands"], 'success')
	else
		TriggerEvent('inventory:client:busy:status', false) triggerNotify(nil, Loc[Config.Lan].error["cancelled"], 'error')
	end
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('jim-burgershot:client:GrabBag', function(data)
	if progressBar({ label = Loc[Config.Lan].progressbar["grab_murder_bag"], time = 2000, cancel = true, dict = "anim@heists@prison_heiststation@cop_reactions", anim = "cop_b_idle", flag = 8}) then
		TriggerServerEvent("jim-burgershot:server:GrabBag")
	else
		TriggerEvent('inventory:client:busy:status', false) triggerNotify(nil, Loc[Config.Lan].error["cancelled"], 'error')
	end
	ClearPedTasks(PlayerPedId())
end)

--[[CRAFTING]]--
RegisterNetEvent('jim-burgershot:Crafting:MakeItem', function(data)
	if not CraftLock then CraftLock = true else return end
	print(data.header, Loc[Config.Lan].menu["drinks_dispenser"])
	if data.header == Loc[Config.Lan].menu["drinks_dispenser"] then
		bartext = Loc[Config.Lan].progress["pouring"]..QBCore.Shared.Items[data.item].label	bartime = 3500
		animDictNow = "mp_ped_interaction" animNow = "handshake_guy_a"
	elseif data.header == Loc[Config.Lan].menu["food_cabinet"] then
		bartext = Loc[Config.Lan].progress["receiving"]..QBCore.Shared.Items[data.item].label bartime = 3500
		animDictNow = "mp_ped_interaction" animNow = "handshake_guy_a"
	elseif data.item == "slicedpotato" or data.item == "slicedonion" then
		bartext = Loc[Config.Lan].progress["slicing"]..QBCore.Shared.Items[data.item].label bartime = 3000
		animDictNow = "anim@heists@prison_heiststation@cop_reactions" animNow = "cop_b_idle"
	elseif data.item == "cheesewrap" or data.item == "chickenwrap" then
		bartext = Loc[Config.Lan].progress["preparing"]..QBCore.Shared.Items[data.item].label bartime = 8000
		animDictNow = "anim@heists@prison_heiststation@cop_reactions" animNow = "cop_b_idle"
	elseif data.header == Loc[Config.Lan].targetinfo["use_deepfryer"] then
		bartext = Loc[Config.Lan].progress["frying"]..QBCore.Shared.Items[data.item].label bartime = 5000
		animDictNow = "amb@prop_human_bbq@male@base" animNow = "base"
	elseif data.header == Loc[Config.Lan].menu["grill"] then
		bartext = Loc[Config.Lan].progress["cooking"]..QBCore.Shared.Items[data.item].label bartime = 5000
        animDictNow = "amb@prop_human_bbq@male@base" animNow = "base"
	elseif data.header == Loc[Config.Lan].menu["prepare_food"] then
		bartext = Loc[Config.Lan].progress["preparing"]..QBCore.Shared.Items[data.item].label bartime = 12500
		animDictNow = "mini@repair" animNow = "fixing_a_ped"
	else
		bartext = Loc[Config.Lan].progress["preparing"]..QBCore.Shared.Items[data.item].label bartime = 12500
		animDictNow = "mini@repair"	animNow = "fixing_a_ped"
	end
	if (data.amount and data.amount ~= 1) then data.craft["amount"] = data.amount
		for k, v in pairs(data.craft[data.item]) do	data.craft[data.item][k] *= data.amount	end
		bartime *= data.amount bartime *= 0.9
	end
	if progressBar({ label = bartext, time = bartime, cancel = true, dict = animDictNow, anim = animNow, flag = 1, icon = data.item }) then
		CraftLock = false
		TriggerServerEvent('jim-burgershot:Crafting:GetItem', data.item, data.craft)
		Wait(500)
		TriggerEvent("jim-burgershot:Crafting", data)
	else
		CraftLock = false
		TriggerEvent('inventory:client:busy:status', false)
	end
	ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('jim-burgershot:Crafting', function(data)
	if CraftLock then return end
	if not jobCheck() then return end
	local Menu = {}
	if Config.Menu == "qb" then
		Menu[#Menu + 1] = { header = data.header, txt = "", isMenuHeader = true }
		Menu[#Menu + 1] = { icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "" } }
	end
	for i = 1, #data.craftable do
		for k, v in pairs(data.craftable[i]) do
			if k ~= "amount" and k ~= "job" then
				local text = ""
				setheader = QBCore.Shared.Items[tostring(k)].label
				if data.craftable[i]["amount"] ~= nil then setheader = setheader.." x"..data.craftable[i]["amount"] end
				local disable = false
				local checktable = {}
				for l, b in pairs(data.craftable[i][tostring(k)]) do
					if b == 0 or b == 1 then number = "" else number = " x"..b end
					if not QBCore.Shared.Items[l] then print("^3Error^7: ^2Script can't find ingredient item in QB-Core items.lua - ^1"..l.."^7") return end
					if Config.Menu == "ox" then text = text..QBCore.Shared.Items[l].label..number.."\n" end
					if Config.Menu == "qb" then text = text.."- "..QBCore.Shared.Items[l].label..number.."<br>" end
					settext = text
					checktable[l] = HasItem(l, b)
				end
				for _, v in pairs(checktable) do if v == false then disable = true break end end
				if not disable then setheader = setheader.." ✔️" end
				local event = "jim-burgershot:Crafting:MakeItem"
                if Config.MultiCraft then event = "jim-burgershot:Crafting:MultiCraft" end
				Menu[#Menu + 1] = {
					disabled = disable,
					icon = "nui://"..Config.img..QBCore.Shared.Items[tostring(k)].image,
					header = setheader, txt = settext, --qb-menu
					params = { event = event, args = { item = k, craft = data.craftable[i], craftable = data.craftable, header = data.header, anim = data.craftable["anim"] } }, -- qb-menu
					event = event, args = { item = k, craft = data.craftable[i], craftable = data.craftable, header = data.header }, -- ox_lib
					title = setheader, description = settext, -- ox_lib
				}
				settext, setheader = nil
			end
		end
	end
	if Config.Menu == "ox" then exports.ox_lib:registerContext({id = 'Crafting', title = data.header, position = 'top-right', options = Menu }) exports.ox_lib:showContext("Crafting")
	elseif Config.Menu == "qb" then exports['qb-menu']:openMenu(Menu) end
	lookEnt(data.coords)
end)

RegisterNetEvent('jim-burgershot:Crafting:MultiCraft', function(data)
    local success = Config.MultiCraftAmounts local Menu = {}
    for k in pairs(success) do success[k] = true
        for l, b in pairs(data.craft[data.item]) do
            local has = HasItem(l, (b * k)) if not has then success[k] = false break else success[k] = true end
		end end
    if Config.Menu == "qb" then Menu[#Menu + 1] = { header = data.header, txt = "", isMenuHeader = true } end
	Menu[#Menu + 1] = { icon = "fas fa-arrow-left", title = Loc[Config.Lan].menu["back"], header = "", txt = Loc[Config.Lan].menu["back"], params = { event = "jim-burgershot:Crafting", args = data }, event = "jim-burgershot:Crafting", args = data }
	for k in pairsByKeys(success) do
		Menu[#Menu + 1] = {
			disabled = not success[k],
			icon = "nui://"..Config.img..QBCore.Shared.Items[data.item].image, header = QBCore.Shared.Items[data.item].label.." [x"..k.."]", title = QBCore.Shared.Items[data.item].label.." [x"..k.."]",
			event = "jim-burgershot:Crafting:MakeItem", args = { item = data.item, craft = data.craft, craftable = data.craftable, header = data.header, amount = k },
			params = { event = "jim-burgershot:Crafting:MakeItem", args = { item = data.item, craft = data.craft, craftable = data.craftable, header = data.header, amount = k } }
		}
	end
	if Config.Menu == "ox" then	exports.ox_lib:registerContext({id = 'Crafting', title = data.header, position = 'top-right', options = Menu })	exports.ox_lib:showContext("Crafting")
	elseif Config.Menu == "qb" then	exports['qb-menu']:openMenu(Menu) end
end)

--[[STASH SHOPS]]--
RegisterNetEvent('jim-burgershot:Stash', function(data, id)
	if id then -- If it has a bag ID then open the limited stash (doens't work with ox yet, not sure how to make a stash on the fly that isn't exploitable)
		TriggerServerEvent("inventory:server:OpenInventory", "stash", "burgershot_"..id, { maxweight = 2000000, slots = 6, })
		TriggerEvent("inventory:client:SetCurrentStash", "burgershot_"..id)
	else
		if data.job and not jobCheck() then return end
		if Config.Inv == "ox" then exports.ox_inventory:openInventory('stash', tostring(data.id))
		else TriggerEvent("inventory:client:SetCurrentStash", tostring(data.id))
		TriggerServerEvent("inventory:server:OpenInventory", "stash", tostring(data.id)) end
	end
	lookEnt(data.coords)
end)

RegisterNetEvent('jim-burgershot:Shop', function(data)
	local event = "inventory:server:OpenInventory"
	if Config.JimShop then event = "jim-shops:ShopOpen"
	elseif Config.Inv == "ox" then  exports.ox_inventory:openInventory('shop', { type = tostring(data.id) }) end
	TriggerServerEvent(event, "shop", "bugershot", data.shop)
	lookEnt(data.coords)
end)

--[[CONSUME]]--
local function ConsumeSuccess(itemName, type)
	ExecuteCommand("e c")
	toggleItem(false, itemName, 1)
	if QBCore.Shared.Items[itemName].hunger then
		--TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + QBCore.Shared.Items[itemName].hunger)
		TriggerServerEvent("consumables:server:addHunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + QBCore.Shared.Items[itemName].hunger)
	end
	if QBCore.Shared.Items[itemName].thirst then
		--TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + QBCore.Shared.Items[itemName].thirst)
		TriggerServerEvent("consumables:server:addThirst", QBCore.Functions.GetPlayerData().metadata["thirst"] + QBCore.Shared.Items[itemName].thirst)
	end
	if type == "alcohol" then alcoholCount += 1
		if alcoholCount > 1 and alcoholCount < 4 then TriggerEvent("evidence:client:SetStatus", "alcohol", 200)	elseif alcoholCount >= 4 then TriggerEvent("evidence:client:SetStatus", "heavyalcohol", 200) AlienEffect() end
	end
	if Config.RewardItem == itemName then toggleItem(true, Config.RewardPool[math.random(1, #Config.RewardPool)], 1) end
end

RegisterNetEvent('jim-burgershot:client:Consume', function(itemName, type)
	local emoteTable = {
		--Food
		["moneyshot"] = "burger", ["heartstopper"] = "burger", ["bleeder"] = "burger", ["meatfree"] = "burger",	["torpedo"] = "torpedo", ["cheesewrap"] = "torpedo", ["chickenwrap"] = "torpedo",
		["shotrings"] = "bsfries", ["shotnuggets"] = "bsfries", ["shotfries"] = "bsfries", ["rimjob"] = "donut2", ["creampie"] = "donut2",
		--Drinks
		["bscoke"] = "bscoke", ["bscoffee"] = "bscoffee", ["milk"] = "milk", ["milkshake"] = "glass",
	}
	local progstring, defaultemote = Loc[Config.Lan].progress["drinking"], "drink"
	if type == "food" then progstring = Loc[Config.Lan].progress["eating"] defaultemote = "burger" end
	ExecuteCommand("e "..(emoteTable[itemName] or defaultemote))
	if progressBar({label = progstring..QBCore.Shared.Items[itemName].label.."..", time = math.random(3000, 6000), cancel = true, icon = itemName}) then
		ConsumeSuccess(itemName, type)
	else
		ExecuteCommand("e c")
	end
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	if GetResourceState("qb-target") == "started" or GetResourceState("ox_target") == "started" then
		for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
		for k in pairs(Props) do DeleteEntity(Props[k]) end
		exports['qb-menu']:closeMenu()
	end
end)