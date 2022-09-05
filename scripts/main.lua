local triggerBuff = '������ ���';
local wtChat
local valuedText = common.CreateValuedText()
local SmokeAlertText = mainForm:GetChildUnchecked("SmokeAlertText", false)
local SmokeEffectTexture = mainForm:GetChildUnchecked("Smoke", false)

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

function AlarmOn()
    if effect_type == 1 or effect_type == 3 then
        SmokeEffectTexture:Show(true)
    end

    if effect_type == 2 or effect_type == 3 then
        SmokeAlertText:Show(true)
    end
end

function AlarmOff()
    SmokeAlertText:Show(false)
    SmokeEffectTexture:Show(false)
end

function OnEventBuffAdded(params)
    if not (userMods.FromWString(params.buffName) == triggerBuff) then
        return false
    end

    local buffInfo = object.GetBuffInfo(params.buffId)
    if buffInfo.producer.casterId == nil then
        return false
    end

    if not object.IsEnemy(buffInfo.producer.casterId) then
        return
    end

    AlarmOn()
end

function OnEventBuffRemoved(params)
    if not (userMods.FromWString(params.buffName) == triggerBuff) then
        return false
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
    SmokeAlertText:Show(false)
    SmokeEffectTexture:Show(false)

    common.RegisterEventHandler(OnEventBuffAdded, "EVENT_OBJECT_BUFF_ADDED", { objectId = avatar.GetId() })
    common.RegisterEventHandler(OnEventBuffRemoved, "EVENT_OBJECT_BUFF_REMOVED", { objectId = avatar.GetId() })

    if effect_type == 1 or effect_type == 3 then
        common.RegisterEventHandler(OnEventUpdateRatio, "EVENT_UPDATE_SHRINK_RATIO")
        OnEventUpdateRatio()
    end
end

function Init()
    if avatar and avatar.IsExist() then
        OnEventAvatarCreated()
    else
        common.RegisterEventHandler(OnEventAvatarCreated, "EVENT_AVATAR_CREATED")
    end
end

Init()
