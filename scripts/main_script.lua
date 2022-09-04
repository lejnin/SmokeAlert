local wtChat
local valuedText = common.CreateValuedText()
local SmokeAlertText = mainForm:GetChildUnchecked("SmokeAlertText", false)
local smokesIds = {}

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
    SmokeAlertText:Show(true)
    --common.UnRegisterEventHandler(OnEventBuffAdded, "EVENT_OBJECT_BUFF_ADDED", { objectId = avatar.GetId() })
end

function AlarmOff()
    SmokeAlertText:Show(false)
    --common.RegisterEventHandler(OnEventBuffAdded, "EVENT_OBJECT_BUFF_ADDED", { objectId = avatar.GetId() })
    --common.UnRegisterEventHandler(OnEventBuffRemoved, "EVENT_OBJECT_BUFF_REMOVED", { objectId = avatar.GetId() })
end

function OnEventBuffAdded(params)
    if not (userMods.FromWString(params.buffName) == 'Густой дым') then
        return false
    end

    local buffInfo = object.GetBuffInfo(params.buffId)
    if buffInfo.producer.casterId == nil then
        return false
    end

    if not object.IsEnemy(buffInfo.producer.casterId) then
        return
    end

    --smokesIds[params.buffId] = true
    --common.RegisterEventHandler(OnEventBuffRemoved, "EVENT_OBJECT_BUFF_REMOVED", { objectId = avatar.GetId() })

    AlarmOn()
end

function OnEventBuffRemoved(params)
    if not (userMods.FromWString(params.buffName) == 'Густой дым') then
        return false
    end

    --smokesIds[params.buffId] = nil
    --if table.getn(smokesIds) == 0 then
    --    common.UnRegisterEventHandler(OnEventBuffRemoved, "EVENT_OBJECT_BUFF_REMOVED", { objectId = avatar.GetId() })
    --end

    AlarmOff()
end

function OnEventAvatarCreated()
    SmokeAlertText:Show(false)
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
