// Natural Selection 2 'Classic' Mod 
// lua\ModdedMixinUtility.lua
// - Dragon

local origAddMixinNetworkVars = AddMixinNetworkVars

function AddMixinNetworkVars(theMixin, networkVars)

	if theMixin == nil or networkVars == nil then
		return
	end
	origAddMixinNetworkVars(theMixin, networkVars)
    
end

local origInitMixin = InitMixin

function InitMixin(classInstance, theMixin, optionalMixinData)

	if theMixin == nil then
		return
	end
	origInitMixin(classInstance, theMixin, optionalMixinData)
	
end