local config = {}
local toxicityTimer = 0

local function loadConfig()
	local configJson = mwse.loadConfig("Progressive Poisoning")
	if (configJson ~= nil) then
		table.copy(configJson, config)
	end
end
loadConfig()

local toxic = 0
local ingrType = require("Aleist3r.Potions and Ingredients Poisoning System.ingredientEffects")
local potType = require("Aleist3r.Potions and Ingredients Poisoning System.potionEffects")
--local sideEffects = require("Aleist3r.Potions and Ingredients Poisoning System.sideEffects")

local function onMenuActivated(e)
	local UI_HelpMenu = tes3ui.findHelpLayerMenu(tes3ui.registerID("HelpMenu"))

	local UI_MenuStat = tes3ui.findMenu(tes3ui.registerID("MenuStat"))
	local UI_MenuStat_mini_frame = UI_MenuStat:findChild(tes3ui.registerID("MenuStat_mini_frame"))

	UI_MenuMulti = tes3ui.findMenu(tes3ui.registerID("MenuMulti"))
	local UI_MenuMulti_fillbars_layout = UI_MenuMulti:findChild(tes3ui.registerID("MenuMulti_fillbars_layout"))
	local UI_MenuMulti_npc_health_bar = UI_MenuMulti:findChild(tes3ui.registerID("MenuMulti_npc_health_bar"))
	local UI_MenuStat_health_fillbar = UI_MenuMulti:findChild(tes3ui.registerID("MenuStat_health_fillbar"))
	local UI_MenuStat_magic_fillbar = UI_MenuMulti:findChild(tes3ui.registerID("MenuStat_magic_fillbar"))
	local UI_MenuStat_fatigue_fillbar = UI_MenuMulti:findChild(tes3ui.registerID("MenuStat_fatigue_fillbar"))

	if (not e.newlyCreated) then
		return
	end

	UI_MenuMulti_npc_health_bar.height = 10
	UI_MenuStat_health_fillbar.height = 10
	UI_MenuStat_magic_fillbar.height = 10
	UI_MenuStat_fatigue_fillbar.height = 10

	UI_MenuMulti_npc_health_bar.parent.borderAllSides = 0
	UI_MenuStat_health_fillbar.parent.borderAllSides = 0
	UI_MenuStat_magic_fillbar.parent.borderAllSides = 0
	UI_MenuStat_fatigue_fillbar.parent.borderAllSides = 0

	UI_MenuMulti_npc_health_bar.parent.borderTop = 2
	UI_MenuStat_health_fillbar.parent.borderTop = 1
	UI_MenuStat_magic_fillbar.parent.borderTop = 0
	UI_MenuStat_fatigue_fillbar.parent.borderTop = 0

	UI_MenuMulti_npc_health_bar.parent.borderBottom = 0
	UI_MenuStat_health_fillbar.parent.borderBottom = 1
	UI_MenuStat_magic_fillbar.parent.borderBottom = 1
	UI_MenuStat_fatigue_fillbar.parent.borderBottom = 1

	UI_MenuMulti_npc_health_bar.parent.borderLeft = 2
	UI_MenuStat_health_fillbar.parent.borderLeft = 2
	UI_MenuStat_magic_fillbar.parent.borderLeft = 2
	UI_MenuStat_fatigue_fillbar.parent.borderLeft = 2

	UI_MenuMulti_npc_health_bar.parent.borderRight = 2
	UI_MenuStat_health_fillbar.parent.borderRight = 2
	UI_MenuStat_magic_fillbar.parent.borderRight = 2
	UI_MenuStat_fatigue_fillbar.parent.borderRight = 2

	local function createTooltip (e)
		local UI_PoisonFrame_tooltip = tes3ui.createTooltipMenu()

		local UI_PoisonFrame_rect = UI_PoisonFrame_tooltip:createRect({id = tes3ui.registerID("PotionPoisoning:UI_PoisonFrame_tooltip")})
		UI_PoisonFrame_rect.flowDirection = "left_to_right"
		UI_PoisonFrame_rect.paddingTop = 6
		UI_PoisonFrame_rect.paddingBottom = 10
		UI_PoisonFrame_rect.paddingLeft = 6
		UI_PoisonFrame_rect.paddingRight = 6
		UI_PoisonFrame_rect.width = 444
		UI_PoisonFrame_rect.autoHeight = true

		local UI_PoisonFrame_icon = UI_PoisonFrame_rect:createImage({path = "icons/a3/a3_b_s_toxic.tga"})
		UI_PoisonFrame_icon.borderTop = 2
		UI_PoisonFrame_icon.borderRight = 11

		local playerRef = tes3.getPlayerRef()
		local a3_endur = 0
		if (playerRef ~= nil) then
			a3_endur = math.clamp(tes3.mobilePlayer.endurance.base, 0, 100)
		end

		local UI_PoisonFrame_text = UI_PoisonFrame_rect:createLabel({text = ("Your body's natural tolerance to the harmful side\neffects of alchemy. Higher rates of toxicity will\nadversely affect your health, while rates exceeding\nyour maximum threshold may, in rare cases, result\nin serious harm or even death. Your toxicity will\ngradually increase by consuming potions and other\ningredients.\n" .. tostring(toxic) .. "/" .. tostring(a3_endur))})
		UI_PoisonFrame_text.wrapText = true

		UI_PoisonFrame_tooltip:updateLayout()
	end

	UI_MenuStat_mini_frame.autoHeight = true

	local UI_MenuStat_poison_frame = UI_MenuStat_mini_frame:createBlock({id = tes3ui.registerID("PotionPoisoning:UI_MenuStat_poison_frame")})
	UI_MenuStat_poison_frame.widthProportional = 1.0
	UI_MenuStat_poison_frame.height = 18
	UI_MenuStat_poison_frame.autoHeight = true
	UI_MenuStat_poison_frame.autoWidth = true
	UI_MenuStat_poison_frame.childAlignX = -1
	UI_MenuStat_poison_frame.childAlignY = 0.5

	local UI_MenuStat_poison_text = UI_MenuStat_poison_frame:createLabel({id = tes3ui.registerID("PotionPoisoning:Toxicity"), text = "Toxicity"})
	UI_MenuStat_poison_text.color = tes3ui.getPalette("normal_over_color")
	UI_MenuStat_poison_text:register("mouseOver", createTooltip)

	UI_MenuStat_poison_fillbar = UI_MenuStat_poison_frame:createFillBar({id = tes3ui.registerID("PotionPoisoning:UI_MenuStat_poison_fillbar")})
	UI_MenuStat_poison_fillbar.width = 130
	UI_MenuStat_poison_fillbar.height = 18
	UI_MenuStat_poison_fillbar.widget.fillColor = {0.667, 0.91, 0.31}
	UI_MenuStat_poison_fillbar:register("mouseOver", createTooltip)

	UI_MenuMulti_poison_rect = UI_MenuMulti_fillbars_layout:createRect({})
	UI_MenuMulti_poison_rect.autoWidth = true
	UI_MenuMulti_poison_rect.autoHeight = true
	UI_MenuMulti_poison_rect.borderTop = 0
	UI_MenuMulti_poison_rect.borderBottom = 1
	UI_MenuMulti_poison_rect.borderLeft = 2
	UI_MenuMulti_poison_rect.borderRight = 2
	
	UI_MenuMulti_poison_rect.alpha = tes3.worldController.menuAlpha

	UI_MenuMulti_poison_fillbar = UI_MenuMulti_poison_rect:createFillBar({id = tes3ui.registerID("PotionPoisoning:UI_MenuMulti_poison_fillbar")})
	UI_MenuMulti_poison_fillbar.width = 65
	UI_MenuMulti_poison_fillbar.height = 10
	UI_MenuMulti_poison_fillbar.widget.fillColor = {0.667, 0.91, 0.31}
	UI_MenuMulti_poison_fillbar.borderAllSides = 0
	UI_MenuMulti_poison_fillbar.widget.showText = false
	UI_MenuMulti_poison_fillbar:register("mouseOver", createTooltip)

	UI_MenuStat:updateLayout()
	UI_MenuMulti:updateLayout()
end

event.register("uiActivated", onMenuActivated, {filter = "MenuStat"})

local function onFrameUpdate(e)
	local playerRef = tes3.getPlayerRef()
	if (UI_MenuMulti_poison_fillbar ~= nil) then
		if (playerRef ~= nil) then
			local a3_endur = math.clamp(tes3.mobilePlayer.endurance.base, 0, 100)
			if (tes3.mobilePlayer.sleeping == false and tes3.mobilePlayer.waiting == false) then
				if (tes3.menuMode() == false) then
					if (toxic > a3_endur) then
						local damageHP = toxic - a3_endur
						tes3.mobilePlayer:applyHealthDamage(damageHP)
						toxic = a3_endur
					elseif (toxic < 0) then
						toxic = 0
					end
					UI_MenuMulti_poison_fillbar.widget.current = toxic
					UI_MenuMulti_poison_fillbar.widget.max = a3_endur
					UI_MenuStat_poison_fillbar.widget.current = toxic
					UI_MenuStat_poison_fillbar.widget.max = a3_endur
				end
			else
				UI_MenuMulti_poison_fillbar.widget.current = toxic
				UI_MenuMulti_poison_fillbar.widget.max = a3_endur
				UI_MenuStat_poison_fillbar.widget.current = toxic
				UI_MenuStat_poison_fillbar.widget.max = a3_endur
			end
	
			function onTimerComplete()
				if (toxic > 0) then
					if (tes3.mobilePlayer.sleeping) then
						toxic = toxic - (a3_endur/24)
					elseif (tes3.mobilePlayer.waiting) then
						toxic = toxic - (a3_endur/48)
					elseif (tes3.mobilePlayer.travelling) then
						toxic = toxic - (a3_endur/48)
					elseif (tes3.mobilePlayer.inJail) then
						toxic = toxic - (a3_endur/48)
					else
						if (tes3.menuMode() == false) then
							toxic = toxic - (a3_endur/72)
						end
					end
				end
			end
	
			if (toxicityTimer == 0) then
				timer.start({duration = 1, callback = onTimerComplete, iterations = -1, type = timer.game})
				toxicityTimer = 1
			end
	
			UI_MenuMulti_poison_rect.alpha = tes3.worldController.menuAlpha
		end
	end
end

event.register("enterFrame", onFrameUpdate)

local function onConsumeEvent(e)
	if (e.item.objectType == tes3.objectType.ingredient) then
		for i = 1, 4 do
			local effect = e.item.effects[i]
			local value = ingrType.effectIngredient[effect]
			if value ~= nil then
				toxic = toxic + value
			end
		end
		tes3.player.data.a3_toxicity = { toxicityValue = toxic }
	elseif (e.item.objectType == tes3.objectType.alchemy) then
		local toxicValue = 0
		for i = 1, 8 do
			local effect = e.item.effects[i]
			local value = potType.effectPotion[effect.id]
			if value ~= nil then
				toxicValue = toxicValue + value
			end
		end

		if (string.find(e.item.name, "Bargain") ~= nil ) then
			toxic = toxic + (1.15*config.components.toxicityModifier*toxicValue)
		elseif (string.find(e.item.name, "Cheap") ~= nil ) then
			toxic = toxic + (1.1*config.components.toxicityModifier*toxicValue)
		elseif (string.find(e.item.name, "Exclusive") ~= nil ) then
			toxic = toxic + (0.7*config.components.toxicityModifier*toxicValue)
		elseif (string.find(e.item.name, "Quality") ~= nil ) then
			toxic = toxic + (0.9*config.components.toxicityModifier*toxicValue)
		elseif (string.find(e.item.name, "Spoiled") ~= nil ) then
			toxic = toxic + (1.35*config.components.toxicityModifier*toxicValue)
		elseif (string.find(e.item.name, "Standard") ~= nil ) then
			toxic = toxic + (1.0*config.components.toxicityModifier*toxicValue)
		else
			toxic = toxic + (1.1*config.components.toxicityModifier*toxicValue)
		end
		tes3.player.data.a3_toxicity = {toxicityValue = toxic}
	end
end

event.register("equip", onConsumeEvent, {filter = tes3.player})

local function onLoaded()
	if (tes3.player.data.a3_toxicity ~= nil) then
		local playerData = tes3.player.data.a3_toxicity.toxicityValue
		if (playerData ~= nil) then
			toxic = playerData
			toxicityTimer = 0
		else
			toxic = 0
			toxicityTimer = 0
		end
	else
		toxic = 0
		toxicityTimer = 0
	end
end

event.register("loaded", onLoaded)

local function onSave()
	tes3.player.data.a3_toxicity = {toxicityValue = toxic}
end

event.register("save", onSave)