local this = {}

this.sideEffects = {
	local function stuntedStamina()
		tes3spell.create( "a3_stuntedStamina", "Stunted Stamina")
		local spell = tes3.getObject("a3_stuntedStamina")
		spell.effects[1].id = 20
		spell.effects[1].rangeType = 0
		spell.effects[1].type = 1
		spell.effects[1].min = stuntEffect
		spell.effects[1].max = stuntEffect
		spell.magickaCost = 0
	end
}

return this