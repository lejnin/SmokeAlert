local triggerBuff = 'Густой дым'

local wtChat
local valuedText = common.CreateValuedText()
local SmokeAlertText, ChangeModeButton, SmokeEffectTexture

local effectConfig = {}

local addonName = common.GetAddonName()
local testTimer = 2

local effects = {}
effects[1] = 'затемнение'
effects[2] = 'текст'
effects[3] = 'текст + затменение'

function LogToChat(text)
    if not wtChat then
        wtChat = stateMainForm:GetChildUnchecked("ChatLog", false)
        wtChat = wtChat:GetChildUnchecked("Container", true)
        local formatVT = "<html fontname='AllodsFantasy' fontsize='14' shadow='1'><rs class='color'><r name='addonName'/><r name='text'/></rs></html>"
        valuedText:SetFormat(userMods.ToWString(formatVT))
    end

    if wtChat and wtChat.PushFrontValuedText then
        if not common.IsWString(text) then
            text = userMods.ToWString(text)
        end

        valuedText:ClearValues()
        valuedText:SetClassVal("color", "LogColorYellow")
        valuedText:SetVal("text", text)
        valuedText:SetVal("addonName", userMods.ToWString("SA: "))
        wtChat:PushFrontValuedText(valuedText)
    end
end

function PrepareTextures()
    SmokeAlertText = mainForm:GetChildUnchecked("SmokeAlertText", false)
    SmokeEffectTexture = mainForm:GetChildUnchecked("Smoke", false)
    ChangeModeButton = mainForm:GetChildUnchecked("ChangeModeButton", false)

    SmokeAlertText:Show(false)
    SmokeEffectTexture:Show(false)
    ChangeModeButton:Show(false)
end

function SetConfigButton()
    ChangeModeButton:Show(true)

    DnD.Init(ChangeModeButton, nil, true)

    common.RegisterReactionHandler(OnClickButton, 'EVENT_ON_CONFIG_BUTTON_CLICK')
    common.RegisterReactionHandler(OnRightClickButton, 'EVENT_ON_CONFIG_BUTTON_RIGHT_CLICK')

    common.RegisterEventHandler(OnAoPanelStart, 'AOPANEL_START')
end

function AlarmOn()
    if effectConfig.effectType == 1 or effectConfig.effectType == 3 then
        SmokeEffectTexture:Show(true)
    end

    if effectConfig.effectType == 2 or effectConfig.effectType == 3 then
        SmokeAlertText:Show(true)
    end
end

function AlarmOff()
    SmokeAlertText:Show(false)
    SmokeEffectTexture:Show(false)
end

function LoadConfig()
    effectConfig = userMods.GetGlobalConfigSection(addonName) or effectConfig;

    if effectConfig ~= nil then
        if effectConfig.effectType == nil or effects[effectConfig.effectType] == nil then
            effectConfig.effectType = 3
        end

        if effectConfig.fade == nil then
            effectConfig.fade = 0.5
        end
    end

    SmokeEffectTexture:SetFade(effectConfig.fade)
end

function SaveConfig()
    userMods.SetGlobalConfigSection(addonName, effectConfig)
end

function ShowEffectsForFewSeconds()
    AlarmOff()
    testTimer = 3
    AlarmOn()

    common.RegisterEventHandler(OnEventSecondTimer, 'EVENT_SECOND_TIMER')
end

function OnEventSecondTimer()
    testTimer = testTimer - 1

    if testTimer > 0 then
        return
    end

    testTimer = 3
    AlarmOff()
    common.UnRegisterEventHandler(OnEventSecondTimer, 'EVENT_SECOND_TIMER')
end

function OnEventBuffAdded(params)
    if not (userMods.FromWString(params.buffName) == triggerBuff) then
        return
    end

    local buffInfo = object.GetBuffInfo(params.buffId)
    if buffInfo.producer.casterId == nil then
        return
    end

    if not object.IsEnemy(buffInfo.producer.casterId) then
        return
    end

    AlarmOn()
end

function OnAoPanelClickButton(params)
    if params.sender ~= nil and params.sender ~= addonName then
        return
    end

    OnClickButton()
end

function OnAoPanelRightClickButton(params)
    if params.sender ~= nil and params.sender ~= addonName then
        return
    end

    OnRightClickButton()
end

function OnClickButton()
    if DnD:IsDragging() then
        return
    end

    local nextEffect = effectConfig.effectType + 1
    if effects[nextEffect] == nil then
        nextEffect = 1
    end

    effectConfig.effectType = nextEffect
    LogToChat('Оповещение: ' .. effects[nextEffect])
    SaveConfig()
    ShowEffectsForFewSeconds()
end

function OnRightClickButton()
    if DnD:IsDragging() then
        return
    end

    local nextFadeStep = effectConfig.fade + 0.1
    if nextFadeStep > 1 then
        nextFadeStep = 0.1
    end

    effectConfig.fade = nextFadeStep
    SmokeEffectTexture:SetFade(effectConfig.fade)
    LogToChat('Прозрачность затемнения: ' .. tostring(nextFadeStep))
    SaveConfig()
    ShowEffectsForFewSeconds()
end

function OnAoPanelStart()
    local SetVal = { val = userMods.ToWString("SA") }
    local params = { header = SetVal, ptype = "button", size = 35 }
    userMods.SendEvent("AOPANEL_SEND_ADDON", {
        name = addonName, sysName = addonName, param = params
    })

    common.RegisterEventHandler(OnAoPanelClickButton, 'AOPANEL_BUTTON_LEFT_CLICK')
    common.RegisterEventHandler(OnAoPanelRightClickButton, 'AOPANEL_BUTTON_RIGHT_CLICK')

    ChangeModeButton:Show(false)
end

function OnEventBuffRemoved(params)
    if not (userMods.FromWString(params.buffName) == triggerBuff) then
        return
    end

    AlarmOff()
end

function OnEventUpdateRatio()
    local posConverter = widgetsSystem:GetPosConverterParams()
    local placement = SmokeEffectTexture:GetPlacementPlain()

    placement.sizeX = posConverter.realSizeX / posConverter.realSizeY * 1024;
    SmokeEffectTexture:SetPlacementPlain(placement)
end

function OnEventAvatarCreated()
    PrepareTextures()
    SetConfigButton()
    LoadConfig()

    common.RegisterEventHandler(OnEventBuffAdded, "EVENT_OBJECT_BUFF_ADDED", { objectId = avatar.GetId() })
    common.RegisterEventHandler(OnEventBuffRemoved, "EVENT_OBJECT_BUFF_REMOVED", { objectId = avatar.GetId() })
end

function Init()
    if avatar and avatar.IsExist() then
        OnEventAvatarCreated()
    else
        common.RegisterEventHandler(OnEventAvatarCreated, "EVENT_AVATAR_CREATED")
    end
end

Init()
