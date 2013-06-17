// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======    
//    
// lua\HasUmbraMixin.lua    
//    
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//    
// ========= For more information, visit us at http://www.unknownworlds.com =====================    

Script.Load("lua/FunctionContracts.lua")

/**
 * UmbraMixin drags out parts of an umbra cloud to protect an alien for additional UmbraMixin.kUmbraDragTime seconds.
 */
HasUmbraMixin = CreateMixin( HasUmbraMixin )
HasUmbraMixin.type = "HasUmbra"

local kMaterialName = "cinematics/vfx_materials/umbra.material"
local kViewMaterialName = "cinematics/vfx_materials/umbra_view.material"

if Client then
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/umbra.surface_shader")
    Shared.PrecacheSurfaceShader("cinematics/vfx_materials/umbra_view.surface_shader")
end

HasUmbraMixin.expectedMixins =
{
}

HasUmbraMixin.networkVars =
{
    umbratime = "private time"
}

function HasUmbraMixin:__initmixin()
    self.umbratime = 0
end

function HasUmbraMixin:GetHasUmbra()
    return self.umbratime > Shared.GetTime()
end

if Server then

    function HasUmbraMixin:SetHasUmbra(state, umbraTime, force)
    
        if HasMixin(self, "Live") and not self:GetIsAlive() then
            return
        end
        self.umbratime = umbraTime
    end
    
end

function HasUmbraMixin:OnUpdateRender()

    local model = self:GetRenderModel()
    if model then
    
        if not self.umbraMaterial then        
            self.umbraMaterial = AddMaterial(model, kMaterialName)  
        end
        
        self.umbraMaterial:SetParameter("intensity", self:GetHasUmbra() and 1 or 0)
    
    end
    
    local viewModel = self.GetViewModelEntity and self:GetViewModelEntity() and self:GetViewModelEntity():GetRenderModel()
    if viewModel then
    
        if not self.umbraViewMaterial then        
            self.umbraViewMaterial = AddMaterial(viewModel, kViewMaterialName)        
        end
        
        self.umbraViewMaterial:SetParameter("intensity", self:GetHasUmbra() and 1 or 0)
    
    end

end