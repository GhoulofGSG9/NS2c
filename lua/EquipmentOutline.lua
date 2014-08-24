// ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========    
//    
// lua\EquipmentOutline.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com) and
//                  Max McGuire (max@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

local _fullRenderMask = 0x3c
local _invRenderMask = bit.bnot(_fullRenderMask)
local _maxDistance = 38
local _maxDistance_Commander = 60
local _enabled = true
local _enabledmulti = true

kEquipmentOutlineColor = enum { [0]='TSFBlue', 'Fuchsia', 'Green', 'Yellow' }
    
local lookup = { "GrenadeLauncher", "Shotgun", "HeavyMachineGun" }
local renderMasks = { [0] = 0x04, 0x08, 0x10, 0x20 }
local cameras = {}

function EquipmentOutline_Initialize()

    for i=0,#lookup do

        local camera = Client.CreateRenderCamera()
        camera:SetTargetTexture("*equipment_outline"..i, true)
        camera:SetRenderMask(renderMasks[i])
        camera:SetIsVisible(false)
        camera:SetCullingMode(RenderCamera.CullingMode_Frustum)
        camera:SetRenderSetup("shaders/Mask.render_setup")
        cameras[i] = camera

    end

    local screenEffect = Client.CreateScreenEffect("shaders/EquipmentOutline.screenfx")
    screenEffect:SetActive(false)
    
    EquipmentOutline_screenEffect = screenEffect
    
end

function EquipmentOutline_Shudown()

    for i=0,#lookup do    
        Client.DestroyRenderCamera( cameras[i] )
        cameras[i] = nil    
    end
    Client.DestroyScreenEffect( EquipmentOutline_screenEffect )
    EquipmentOutline_screenEffect = nil
    
end

/** Enables or disabls the hive vision effect. When the effect is not needed it should 
* be disabled to boost performance. */
function EquipmentOutline_SetEnabled(enabled)
    
    for i=0,#lookup do
        cameras[i]:SetIsVisible( enabled and _enabled and ( _enabledmulti or i==0 ) )
    end
    cameras[0]:SetRenderMask( _enabledmulti and renderMasks[0] or _fullRenderMask )

    EquipmentOutline_screenEffect:SetActive(enabled and _enabled)
    
end

/** Must be called prior to rendering */
function EquipmentOutline_SyncCamera(rendercamera, forCommander)

    local distance = ConditionalValue(forCommander, _maxDistance_Commander, _maxDistance)

    for i=0,#lookup do
        local camera = cameras[i]
        camera:SetCoords(rendercamera:GetCoords())
        camera:SetFov(rendercamera:GetFov())
        camera:SetFarPlane(distance + 1)
    end

    local screenEffect = EquipmentOutline_screenEffect

    screenEffect:SetParameter("multienabled", _enabledmulti and 1 or 0 )
    
end

/** Adds a model to the hive vision */
function EquipmentOutline_AddModel(model,weaponclass)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask(bit.bor(renderMask, renderMasks[weaponclass or 0]))

end

/** Removes a model from the hive vision */
function EquipmentOutline_RemoveModel(model)

    local renderMask = model:GetRenderMask()
    model:SetRenderMask(bit.band(renderMask, _invRenderMask))

end

function EquipmentOutline_UpdateModel(forEntity)

    local player = Client.GetLocalPlayer()

    // Check if player can pickup this item or if player is a spectator
    local highlightDroppedWeapon = player ~= nil and ((player:GetTeamNumber() == kSpectatorIndex and Client.GetOutlinePlayers()) or player:isa("MarineCommander")) and forEntity:isa("Weapon") and forEntity.weaponWorldState == true
    local visible = (player ~= nil and forEntity:GetIsValidRecipient(player)) or highlightDroppedWeapon
    local model = HasMixin(forEntity, "Model") and forEntity:GetRenderModel() or nil

    if forEntity:isa("WeaponAmmoPack") then
        model = forEntity:GetRenderModel() or nil
        visible = player ~= nil and player:GetActiveWeapon() and player:GetActiveWeapon():isa(forEntity:GetWeaponClassName())
    end

    local weaponclass = 0
    for i=1,#lookup do
        if forEntity:isa( lookup[i] ) then
            weaponclass = i
            break
        end
    end

    // Update the visibility status.
    if model and visible ~= model.equipmentVisible then    
    
        if visible then
            EquipmentOutline_AddModel(model,weaponclass)
        else
            EquipmentOutline_RemoveModel(model)
        end
        model.equipmentVisible = visible

    end

end

// For debugging.
local function OnCommandOutline(enabled)
    _enabled = enabled ~= "false" and enabled ~= "0"
end
local function OnCommandOutlineMulti(enabled)
    _enabledmulti = enabled ~= "false" and enabled ~= "0"
end
Event.Hook("Console_outline", OnCommandOutline)
Event.Hook("Console_outlinemulti", OnCommandOutlineMulti)