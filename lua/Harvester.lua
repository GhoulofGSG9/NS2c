// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Harvester.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/ResourceTower.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/HasUmbraMixin.lua")

class 'Harvester' (ResourceTower)
Harvester.kMapName = "harvester"

Harvester.kModelName = PrecacheAsset("models/alien/harvester/harvester.model")
local kAnimationGraph = PrecacheAsset("models/alien/harvester/harvester.animation_graph")

local networkVars = 
{
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(HasUmbraMixin, networkVars)

function Harvester:OnCreate()

    ResourceTower.OnCreate(self)
    
    InitMixin(self, CloakableMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, HasUmbraMixin)
        
    if Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
end

function Harvester:OnInitialized()

    ResourceTower.OnInitialized(self)
    
    self:SetModel(Harvester.kModelName, kAnimationGraph)
    
    if Server then
    
        // This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
        self.glowIntensity = ConditionalValue(self:GetIsBuilt(), 1, 0)
        
    end

end

function Harvester:GetDamagedAlertId()
    return kTechId.AlienAlertHarvesterUnderAttack
end

function Harvester:GetCanBeUsed(player, useSuccessTable)
    if not self:GetCanConstruct(player) then
        useSuccessTable.useSuccess = false
    else
        useSuccessTable.useSuccess = true
    end  
end

if Client then

    function Harvester:OnUpdate(deltaTime)
    
        ResourceTower.OnUpdate(self, deltaTime)
        
        if self:GetIsBuilt() then
            self.glowIntensity = math.min(3, self.glowIntensity + deltaTime)
        end
        
    end    

    function Harvester:OnUpdateRender()
    
        PROFILE("Harvester:OnUpdateRender")

        local model = self:GetRenderModel()
        if model then
            model:SetMaterialParameter("glowIntensity", self.glowIntensity)        
        end
        
    end

end

local kHarvesterHealthbarOffset = Vector(0, .9, 0)
function Harvester:GetHealthbarOffset()
    return kHarvesterHealthbarOffset
end 

function Harvester:ConstructOverride(deltaTime)
    return deltaTime / 2
end

Shared.LinkClassToMap("Harvester", Harvester.kMapName, networkVars)