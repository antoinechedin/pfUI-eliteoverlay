pfUI:RegisterModule("EliteOverlay", "vanilla:tbc", function ()
  pfUI.gui.dropdowns.EliteOverlay_positions = {
    "left:" .. T["Left"],
    "right:" .. T["Right"],
    "off:" .. T["Disabled"]
  }

  pfUI.gui.dropdowns.EliteOverlay_skin = {
    "classic:" .. T["Classic"],
    "dragonflight:" .. T["Dragon Flight"]
  }

  local config = {
    classic = {
      worldboss = { img = "GOLD", color = { r = .85, g = .15, b = .15, a = 1 } },
      rareelite = { img = "GOLD", color = { r = 1, g = 1, b = 1, a = 1 } },
      elite = { img = "GOLD", color = { r = .75, g = .6, b = 0, a = 1 } },
      rare = { img = "GRAY", color = { r = .8, g = .8, b = .8, a = 1 } },
    },
    dragonflight = {
      worldboss = { img = "GRAY", color = { r = 1, g = .3, b = .3, a = 1 } },
      rareelite = { img = "GRAY", color = { r = .5, g = 1, b = 1, a = 1 } },
      elite = { img = "GOLD", color = { r = 1, g = 1, b = 1, a = 1 } },
      rare = { img = "GRAY", color = { r = 1, g = 1, b = 1, a = 1 } },
    },
  }

  -- detect current addon path
  local addonpath
  local tocs = { "", "-master", "-tbc", "-wotlk" }
  for _, name in pairs(tocs) do
    local current = string.format("pfUI-eliteoverlay%s", name)
    local _, title = GetAddOnInfo(current)
    if title then
      addonpath = "Interface\\AddOns\\" .. current
      break
    end
  end

  if pfUI.gui.CreateGUIEntry then -- new pfUI
    pfUI.gui.CreateGUIEntry(T["Thirdparty"], T["Elite Overlay"], function()
      pfUI.gui.CreateConfig(pfUI.gui.UpdaterFunctions["target"], T["Select dragon position"], C.EliteOverlay, "position", "dropdown", pfUI.gui.dropdowns.EliteOverlay_positions)
      pfUI.gui.CreateConfig(pfUI.gui.UpdaterFunctions["skin"], T["Select dragon skin"], C.EliteOverlay, "skin", "dropdown", pfUI.gui.dropdowns.EliteOverlay_skin)
    end)
  else -- old pfUI
    pfUI.gui.tabs.thirdparty.tabs.EliteOverlay = pfUI.gui.tabs.thirdparty.tabs:CreateTabChild("EliteOverlay", true)
    pfUI.gui.tabs.thirdparty.tabs.EliteOverlay:SetScript("OnShow", function()
      if not this.setup then
        local CreateConfig = pfUI.gui.CreateConfig
        local update = pfUI.gui.update
        this.setup = true
      end
    end)
  end

  pfUI:UpdateConfig("EliteOverlay",       nil,         "position",   "right"  )
  pfUI:UpdateConfig("EliteOverlay",       nil,         "skin",       "classic")

  local HookRefreshUnit = pfUI.uf.RefreshUnit
  function pfUI.uf:RefreshUnit(unit, component)
    local pos = string.upper(C.EliteOverlay.position)
    local skin = C.EliteOverlay.skin
    local invert = C.EliteOverlay.position == "right" and 1 or -1
    local unitstr = ( unit.label or "" ) .. ( unit.id or "" )

    local size = unit:GetWidth() / 1.5
    local elite = UnitClassification(unitstr)

    unit.dragonTop = unit.dragonTop or unit:CreateTexture(nil, "OVERLAY")
    unit.dragonBottom = unit.dragonBottom or unit:CreateTexture(nil, "OVERLAY")

    if unitstr == "" or C.EliteOverlay.position == "off" then
      unit.dragonTop:Hide()
      unit.dragonBottom:Hide()
    else
      unit.dragonTop:ClearAllPoints()
      unit.dragonTop:SetWidth(size)
      unit.dragonTop:SetHeight(size)
      unit.dragonTop:SetPoint("TOP"..pos, unit, "TOP"..pos, invert*size/5, size/7)
      unit.dragonTop:SetParent(unit.hp.bar)

      unit.dragonBottom:ClearAllPoints()
      unit.dragonBottom:SetWidth(size)
      unit.dragonBottom:SetHeight(size)
      unit.dragonBottom:SetPoint("BOTTOM"..pos, unit, "BOTTOM"..pos, invert*size/5.2, -size/2.98)
      unit.dragonBottom:SetParent(unit.hp.bar)

      if config[skin] == nil or config[skin][elite] == nil then
        unit.dragonTop:Hide()
        unit.dragonBottom:Hide()
      else
        unit.dragonTop:SetTexture(addonpath.."\\img\\"..skin.."\\TOP_"..config[skin][elite].img.."_"..pos)
        unit.dragonTop:Show()
        unit.dragonTop:SetVertexColor(
          config[skin][elite].color.r,
          config[skin][elite].color.g,
          config[skin][elite].color.b,
          config[skin][elite].color.a
        )
        unit.dragonBottom:SetTexture(addonpath.."\\img\\"..skin.."\\BOTTOM_"..config[skin][elite].img.."_"..pos)
        unit.dragonBottom:Show()
        unit.dragonBottom:SetVertexColor(
          config[skin][elite].color.r,
          config[skin][elite].color.g,
          config[skin][elite].color.b,
          config[skin][elite].color.a
        )
      end
    end

    HookRefreshUnit(this, unit, component)
  end
end)
