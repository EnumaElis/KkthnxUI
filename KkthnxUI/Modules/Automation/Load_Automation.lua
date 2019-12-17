local K = unpack(select(2, ...))
local Module = K:NewModule("Automation")

function Module:OnEnable()
    self:CreateAutoDeclineDuels()
    self:CreateAutoInvite()
    self:CreateAutoRelease()
    self:CreateAutoResurrect()
    -- self:CreateAutoReward()
    self:CreateAutoSetRole()
    self:CreateAutoWhisperInvite()
end