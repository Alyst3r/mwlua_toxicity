local common = {}

local buttonTable = { "Inventory", "Magic", "None" }

common.version = 1.0

local defaultConfig = {
	version = common.version,
	components = {
		useMod = true,
		--vanillaBars = true,
		toxicityModifier = 2,
	},
}

local config = table.copy(defaultConfig)

local function loadConfig()
	config = {}

	table.copy(defaultConfig, config)

	local configJson = mwse.loadConfig("Progressive Poisoning")
	if (configJson ~= nil) then
		if (configJson.version == nil or common.version > configJson.version) then
			configJson.components = nil
		end
		table.copy(configJson, config)
	end
end
loadConfig()

local modConfig = {}

function modConfig.onCreate(container)
	local pane = container:createThinBorder{}
	pane.widthProportional = 1.0
	pane.heightProportional = 1.0
	pane.paddingAllSides = 12
    pane.flowDirection = "top_to_bottom"

	local horizontalBlock2 = pane:createBlock({})
	horizontalBlock2.flowDirection = "left_to_right"
	horizontalBlock2.widthProportional = 1.0
	horizontalBlock2.height = 32
	horizontalBlock2.borderTop = 6
	horizontalBlock2.borderLeft = 6
	horizontalBlock2.borderRight = 6

--[[
	local label2 = horizontalBlock2:createLabel({ text = "Bar frame style:" })
	label2.absolutePosAlignX = 0.0
	label2.absolutePosAlignY = 0.5
	
	local buttonBarFrameStyle = horizontalBlock2:createButton({ text = config.components.vanillaBars and "Vanilla" or "Fit" })
	buttonBarFrameStyle.absolutePosAlignX = 1.0
	buttonBarFrameStyle.absolutePosAlignY = 0.5
	buttonBarFrameStyle.paddingTop = 3
	buttonBarFrameStyle:register("mouseClick", function(e)
		config.components.vanillaBars = not config.components.vanillaBars
		buttonBarFrameStyle.text = (config.components.vanillaBars and "Vanilla" or "Fit")
	end)--]]

	local horizontalBlock3 = pane:createBlock({})
	horizontalBlock3.flowDirection = "left_to_right"
	horizontalBlock3.widthProportional = 1.0
	horizontalBlock3.height = 32
	horizontalBlock3.borderLeft = 6
	horizontalBlock3.borderRight = 6
	
	local label3 = horizontalBlock3:createLabel({ text = "Difficulty:" })
	label3.absolutePosAlignX = 0.0
	label3.absolutePosAlignY = 0.5

	local buttonDifficulty = horizontalBlock3:createButton({})
	buttonDifficulty.absolutePosAlignX = 1.0
	buttonDifficulty.absolutePosAlignY = 0.5
	buttonDifficulty.paddingTop = 3
	if (config.components.toxicityModifier == 1) then
		buttonDifficulty.text = "Lite"
	elseif (config.components.toxicityModifier == 2) then
		buttonDifficulty.text = "Normal"
	elseif (config.components.toxicityModifier == 3) then
		buttonDifficulty.text = "Hardcore"
	end
	buttonDifficulty:register("mouseClick", function(e)
		if (config.components.toxicityModifier == 1) then
			buttonDifficulty.text = "Normal"
			config.components.toxicityModifier = 2
		elseif (config.components.toxicityModifier == 2) then
			buttonDifficulty.text = "Hardcore"
			config.components.toxicityModifier = 3
		elseif (config.components.toxicityModifier == 3) then
			buttonDifficulty.text = "Lite"
			config.components.toxicityModifier = 1
		end
	end)

	pane:updateLayout()
end

function modConfig.onClose(container)
	mwse.saveConfig("Progressive Poisoning", config)
end

modConfig.config = config

local function registerModConfig()
	mwse.registerModConfig("Progressive Poisoning", modConfig)
end
event.register("modConfigReady", registerModConfig)

local function onInitialized(e)
	dofile("Data Files/MWSE/mods/Aleist3r/Potions and Ingredients Poisoning System/MenuLayout.lua")
end

event.register("initialized", onInitialized)