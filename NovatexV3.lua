--[[
    ╔══════════════════════════════════════════════╗
    ║          NOVATEX DELTA MENU  V3              ║
    ║     Futuristic • Responsive • Powerful       ║
    ╚══════════════════════════════════════════════╝
    
    Created for Delta Executor
    PC + Mobile Compatible
    Author: Novatex Team
]]

-- ══════════════════════════════════════════════
--  SERVICES & REFERENCES
-- ══════════════════════════════════════════════
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local Lighting        = game:GetService("Lighting")

local Player   = Players.LocalPlayer
local Camera   = workspace.CurrentCamera
local Mouse    = Player:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ══════════════════════════════════════════════
--  CLEANUP OLD INSTANCE
-- ══════════════════════════════════════════════
if CoreGui:FindFirstChild("NovatexV3") then
    CoreGui.NovatexV3:Destroy()
end

-- ══════════════════════════════════════════════
--  FEATURE STATE
-- ══════════════════════════════════════════════
local State = {
    Fly          = false,
    InfJump      = false,
    AutoWalk     = false,
    AutoJump     = false,
    Noclip       = false,
    GodMode      = false,
    AntiVoid     = false,
    ClickTP      = false,
    BunnyHop     = false,
    FullBright   = false,
    SpeedAura    = false,
    FreezeChar   = false,
}

-- ══════════════════════════════════════════════
--  FLY INTERNALS
-- ══════════════════════════════════════════════
local BodyGyro, BodyVelocity

-- ══════════════════════════════════════════════
--  COLOR PALETTE  (Cyber-Neon Dark)
-- ══════════════════════════════════════════════
local C = {
    BG          = Color3.fromRGB(10, 12, 20),
    Panel       = Color3.fromRGB(15, 18, 30),
    Card        = Color3.fromRGB(20, 24, 40),
    CardHover   = Color3.fromRGB(28, 34, 56),
    Accent      = Color3.fromRGB(0, 200, 255),
    AccentDim   = Color3.fromRGB(0, 100, 140),
    Green       = Color3.fromRGB(0, 230, 120),
    GreenDim    = Color3.fromRGB(0, 100, 55),
    Red         = Color3.fromRGB(255, 60, 80),
    RedDim      = Color3.fromRGB(130, 20, 30),
    Gold        = Color3.fromRGB(255, 200, 60),
    Text        = Color3.fromRGB(220, 235, 255),
    TextDim     = Color3.fromRGB(100, 120, 160),
    White       = Color3.new(1,1,1),
    Trans       = Color3.fromRGB(0, 0, 0),
}

-- ══════════════════════════════════════════════
--  UTILITY HELPERS
-- ══════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.Accent
    s.Thickness = thickness or 1
    s.Transparency = 0.5
    return s
end

local function AddPadding(parent, px)
    local p = Instance.new("UIPadding", parent)
    p.PaddingLeft   = UDim.new(0, px)
    p.PaddingRight  = UDim.new(0, px)
    p.PaddingTop    = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
    return p
end

local function Glow(parent, color, size)
    -- Simple gradient glow using ImageLabel
    local g = Instance.new("ImageLabel", parent)
    g.AnchorPoint    = Vector2.new(0.5, 0.5)
    g.Position       = UDim2.new(0.5, 0, 0.5, 0)
    g.Size           = UDim2.new(1, size or 40, 1, size or 40)
    g.BackgroundTransparency = 1
    g.Image          = "rbxassetid://5028857084"  -- radial gradient asset
    g.ImageColor3    = color or C.Accent
    g.ImageTransparency = 0.75
    g.ZIndex         = parent.ZIndex - 1
    return g
end

-- ══════════════════════════════════════════════
--  SCREEN GUI ROOT
-- ══════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NovatexV3"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- ══════════════════════════════════════════════
--  TOGGLE BUTTON
-- ══════════════════════════════════════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size   = IsMobile and UDim2.new(0, 130, 0, 50) or UDim2.new(0, 115, 0, 38)
ToggleBtn.Position = UDim2.new(0, 14, 0.42, 0)
ToggleBtn.BackgroundColor3 = C.BG
ToggleBtn.Text   = "✦ NOVATEX V3"
ToggleBtn.TextColor3 = C.Accent
ToggleBtn.Font   = Enum.Font.GothamBold
ToggleBtn.TextSize = IsMobile and 13 or 11
ToggleBtn.AutoButtonColor = false
ToggleBtn.ZIndex = 20
AddCorner(ToggleBtn, 10)
AddStroke(ToggleBtn, C.Accent, 1.5)
Glow(ToggleBtn, C.Accent, 20)

-- Pulse animation on toggle button
local pulseTween1 = TweenService:Create(ToggleBtn, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = Color3.fromRGB(120, 230, 255)})
pulseTween1:Play()

-- Draggable toggle button
do
    local dragging, dragStart, startPos = false
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ══════════════════════════════════════════════
--  MAIN PANEL
-- ══════════════════════════════════════════════
local PANEL_W = IsMobile and 320 or 280
local PANEL_H = IsMobile and 540 or 500

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size   = UDim2.new(0, PANEL_W, 0, PANEL_H)
MainFrame.Position = UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BackgroundTransparency = 0.08
MainFrame.Visible = false
MainFrame.Active  = true
MainFrame.ZIndex  = 10
AddCorner(MainFrame, 14)
AddStroke(MainFrame, C.Accent, 1.5)

-- Subtle background grid texture (UIGradient trick)
local bgGrad = Instance.new("UIGradient", MainFrame)
bgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(12, 15, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 12, 22)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(8, 10, 18)),
})
bgGrad.Rotation = 135

-- ── HEADER BAR ──
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = C.Panel
Header.ZIndex = 11
AddCorner(Header, 14)

-- Gradient header
local hGrad = Instance.new("UIGradient", Header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 30, 55)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 20, 40)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 10, 25)),
})
hGrad.Rotation = 90

-- Accent line below header
local AccentLine = Instance.new("Frame", MainFrame)
AccentLine.Size = UDim2.new(1, 0, 0, 2)
AccentLine.Position = UDim2.new(0, 0, 0, 52)
AccentLine.BackgroundColor3 = C.Accent
AccentLine.ZIndex = 12
local lineGrad = Instance.new("UIGradient", AccentLine)
lineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.3, C.Accent),
    ColorSequenceKeypoint.new(0.7, C.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
})

-- Title text
local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "✦ NOVATEX  V3"
TitleLabel.TextColor3 = C.White
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = IsMobile and 17 or 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12

-- Animated gradient on title
local titleGrad = Instance.new("UIGradient", TitleLabel)
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 240, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0, 150, 220)),
})
titleGrad.Rotation = 0
spawn(function()
    local t = 0
    while MainFrame and MainFrame.Parent do
        t = t + 0.5
        titleGrad.Rotation = t % 360
        task.wait(0.016)
    end
end)

-- Subtitle
local SubLabel = Instance.new("TextLabel", Header)
SubLabel.Size = UDim2.new(1, -14, 0, 16)
SubLabel.Position = UDim2.new(0, 14, 1, -20)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Delta Edition  •  Cyber Build"
SubLabel.TextColor3 = C.TextDim
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = IsMobile and 11 or 9
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 12

-- Close button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = C.RedDim
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.Red
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 13
AddCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)
CloseBtn.MouseEnter:Connect(function()
    Tween(CloseBtn, {BackgroundColor3 = C.Red, TextColor3 = C.White}, 0.12)
end)
CloseBtn.MouseLeave:Connect(function()
    Tween(CloseBtn, {BackgroundColor3 = C.RedDim, TextColor3 = C.Red}, 0.12)
end)

-- ── DRAGGABLE HEADER ──
do
    local dragging, dragStart, startPos = false
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ── SCROLL FRAME ──
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -8, 1, -62)
Scroll.Position = UDim2.new(0, 4, 0, 58)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = C.Accent
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)  -- auto-updated
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 11

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder

AddPadding(Scroll, 8)

-- ══════════════════════════════════════════════
--  UI BUILDERS
-- ══════════════════════════════════════════════

-- Section header label
local sectionOrder = 0
local function SectionLabel(text, icon)
    sectionOrder += 1
    local lbl = Instance.new("TextLabel", Scroll)
    lbl.Size = UDim2.new(1, -16, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = (icon or "◈") .. "  " .. text
    lbl.TextColor3 = C.Accent
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = IsMobile and 12 or 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = sectionOrder
    lbl.ZIndex = 12

    -- Separator line
    local sep = Instance.new("Frame", Scroll)
    sep.Size = UDim2.new(1, -16, 0, 1)
    sep.BackgroundColor3 = C.AccentDim
    sep.BackgroundTransparency = 0.3
    sep.LayoutOrder = sectionOrder
    sep.ZIndex = 12
    local sGrad = Instance.new("UIGradient", sep)
    sGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
end

-- Toggle button
local function CreateToggle(name, stateKey, icon, color)
    sectionOrder += 1
    local activeColor = color or C.Green
    local dimColor    = color == C.Red and C.RedDim or (color == C.Gold and Color3.fromRGB(100,70,0) or C.GreenDim)

    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -16, 0, IsMobile and 46 or 40)
    btn.BackgroundColor3 = C.Card
    btn.AutoButtonColor = false
    btn.LayoutOrder = sectionOrder
    btn.ZIndex = 12
    AddCorner(btn, 8)
    local bStroke = AddStroke(btn, C.AccentDim, 1)

    -- Icon
    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size = UDim2.new(0, 32, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon or "⚡"
    iconLbl.TextColor3 = C.Accent
    iconLbl.Font = Enum.Font.Gotham
    iconLbl.TextSize = IsMobile and 16 or 14
    iconLbl.ZIndex = 13

    -- Name label
    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Size = UDim2.new(1, -100, 1, 0)
    nameLbl.Position = UDim2.new(0, 44, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = C.Text
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = IsMobile and 14 or 12
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 13

    -- Status pill
    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0, 46, 0, 20)
    pill.Position = UDim2.new(1, -54, 0.5, -10)
    pill.BackgroundColor3 = dimColor
    pill.ZIndex = 13
    AddCorner(pill, 10)

    local pillTxt = Instance.new("TextLabel", pill)
    pillTxt.Size = UDim2.new(1, 0, 1, 0)
    pillTxt.BackgroundTransparency = 1
    pillTxt.Text = "OFF"
    pillTxt.TextColor3 = C.TextDim
    pillTxt.Font = Enum.Font.GothamBold
    pillTxt.TextSize = IsMobile and 10 or 9
    pillTxt.ZIndex = 14

    local function refresh()
        local on = State[stateKey]
        Tween(pill,    {BackgroundColor3 = on and activeColor or dimColor}, 0.18)
        Tween(pillTxt, {TextColor3 = on and C.White or C.TextDim}, 0.18)
        Tween(btn,     {BackgroundColor3 = on and C.CardHover or C.Card}, 0.18)
        Tween(bStroke, {Color = on and activeColor or C.AccentDim, Transparency = on and 0.2 or 0.5}, 0.18)
        pillTxt.Text = on and "ON" or "OFF"
    end

    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        -- Scale bounce
        Tween(btn, {Size = UDim2.new(1, -16, 0, IsMobile and 43 or 37)}, 0.06)
        task.delay(0.06, function()
            Tween(btn, {Size = UDim2.new(1, -16, 0, IsMobile and 46 or 40)}, 0.12)
        end)
        refresh()
    end)
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = State[stateKey] and C.CardHover or Color3.fromRGB(24, 28, 46)}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = State[stateKey] and C.CardHover or C.Card}, 0.12)
    end)
end

-- Stat adjuster
local function CreateAdjuster(name, property, default, icon, minVal, maxVal)
    sectionOrder += 1
    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(1, -16, 0, IsMobile and 90 or 80)
    card.BackgroundColor3 = C.Card
    card.LayoutOrder = sectionOrder
    card.ZIndex = 12
    AddCorner(card, 8)
    AddStroke(card, C.AccentDim, 1)

    local iconLbl = Instance.new("TextLabel", card)
    iconLbl.Size = UDim2.new(0, 30, 0, 24)
    iconLbl.Position = UDim2.new(0, 8, 0, 6)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon or "⚙"
    iconLbl.TextColor3 = C.Gold
    iconLbl.Font = Enum.Font.Gotham
    iconLbl.TextSize = IsMobile and 15 or 13
    iconLbl.ZIndex = 13

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -48, 0, 24)
    nameLbl.Position = UDim2.new(0, 40, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = C.Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = IsMobile and 13 or 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 13

    -- Current value display
    local curLbl = Instance.new("TextLabel", card)
    curLbl.Size = UDim2.new(0, 60, 0, 20)
    curLbl.Position = UDim2.new(1, -68, 0, 8)
    curLbl.BackgroundTransparency = 1
    curLbl.Text = "now: " .. tostring(default)
    curLbl.TextColor3 = C.Accent
    curLbl.Font = Enum.Font.Gotham
    curLbl.TextSize = IsMobile and 10 or 9
    curLbl.TextXAlignment = Enum.TextXAlignment.Right
    curLbl.ZIndex = 13

    local function refreshCur()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then curLbl.Text = "now: " .. tostring(math.floor(hum[property])) end
    end

    -- Input row
    local inputBox = Instance.new("TextBox", card)
    inputBox.Size = UDim2.new(0, IsMobile and 130 or 110, 0, IsMobile and 30 or 26)
    inputBox.Position = UDim2.new(0, 8, 0, 36)
    inputBox.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
    inputBox.Text = ""
    inputBox.PlaceholderText = "Enter value..."
    inputBox.TextColor3 = C.Text
    inputBox.PlaceholderColor3 = C.TextDim
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = IsMobile and 13 or 11
    inputBox.ClearTextOnFocus = false
    inputBox.ZIndex = 13
    AddCorner(inputBox, 6)
    AddStroke(inputBox, C.AccentDim, 1)

    local setBtn = Instance.new("TextButton", card)
    setBtn.Size = UDim2.new(0, IsMobile and 65 or 55, 0, IsMobile and 30 or 26)
    setBtn.Position = UDim2.new(0, IsMobile and 148 or 124, 0, 36)
    setBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 140)
    setBtn.Text = "SET"
    setBtn.TextColor3 = C.Accent
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = IsMobile and 12 or 10
    setBtn.AutoButtonColor = false
    setBtn.ZIndex = 13
    AddCorner(setBtn, 6)

    local rstBtn = Instance.new("TextButton", card)
    rstBtn.Size = UDim2.new(0, IsMobile and 65 or 55, 0, IsMobile and 30 or 26)
    rstBtn.Position = UDim2.new(0, IsMobile and 221 or 185, 0, 36)
    rstBtn.BackgroundColor3 = C.RedDim
    rstBtn.Text = "RST"
    rstBtn.TextColor3 = C.Red
    rstBtn.Font = Enum.Font.GothamBold
    rstBtn.TextSize = IsMobile and 12 or 10
    rstBtn.AutoButtonColor = false
    rstBtn.ZIndex = 13
    AddCorner(rstBtn, 6)

    setBtn.MouseButton1Click:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local val = tonumber(inputBox.Text)
        if val then
            if minVal and val < minVal then val = minVal end
            if maxVal and val > maxVal then val = maxVal end
            if property == "JumpPower" then hum.UseJumpPower = true end
            hum[property] = val
            refreshCur()
            Tween(setBtn, {BackgroundColor3 = C.Green}, 0.1)
            task.delay(0.4, function() Tween(setBtn, {BackgroundColor3 = Color3.fromRGB(0,80,140)}, 0.3) end)
        end
    end)
    rstBtn.MouseButton1Click:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if property == "JumpPower" then hum.UseJumpPower = true end
        hum[property] = default
        inputBox.Text  = ""
        refreshCur()
    end)

    setBtn.MouseEnter:Connect(function() Tween(setBtn, {BackgroundColor3 = C.Accent}, 0.12) end)
    setBtn.MouseLeave:Connect(function() Tween(setBtn, {BackgroundColor3 = Color3.fromRGB(0,80,140)}, 0.12) end)
    rstBtn.MouseEnter:Connect(function() Tween(rstBtn, {BackgroundColor3 = C.Red, TextColor3 = C.White}, 0.12) end)
    rstBtn.MouseLeave:Connect(function() Tween(rstBtn, {BackgroundColor3 = C.RedDim, TextColor3 = C.Red}, 0.12) end)
end

-- Action button (one-shot)
local function CreateAction(name, icon, callback, color)
    sectionOrder += 1
    local c = color or C.AccentDim
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1, -16, 0, IsMobile and 42 or 36)
    btn.BackgroundColor3 = c
    btn.AutoButtonColor = false
    btn.LayoutOrder = sectionOrder
    btn.ZIndex = 12
    AddCorner(btn, 8)

    local row = Instance.new("TextLabel", btn)
    row.Size = UDim2.new(1, -16, 1, 0)
    row.Position = UDim2.new(0, 8, 0, 0)
    row.BackgroundTransparency = 1
    row.Text = (icon or "▶") .. "  " .. name
    row.TextColor3 = C.White
    row.Font = Enum.Font.GothamBold
    row.TextSize = IsMobile and 13 or 11
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.ZIndex = 13

    btn.MouseButton1Click:Connect(function()
        callback()
        Tween(btn, {BackgroundColor3 = C.Green}, 0.1)
        task.delay(0.35, function() Tween(btn, {BackgroundColor3 = c}, 0.3) end)
    end)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Color3.fromRGB(30,40,70)}, 0.12) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = c}, 0.12) end)
end

-- ══════════════════════════════════════════════
--  POPULATE MENU
-- ══════════════════════════════════════════════

SectionLabel("MOVEMENT", "🏃")
CreateToggle("Fly Mode",        "Fly",        "✈️")
CreateToggle("Infinite Jump",   "InfJump",    "⬆️")
CreateToggle("Auto Walk",       "AutoWalk",   "🦶")
CreateToggle("Auto Jump",       "AutoJump",   "🐇")
CreateToggle("Bunny Hop",       "BunnyHop",   "🐰", C.Gold)
CreateToggle("Noclip",          "Noclip",     "👻", C.Gold)

SectionLabel("STATS", "📊")
CreateAdjuster("Walk / Fly Speed",  "WalkSpeed",  16, "🏎️", 1, 500)
CreateAdjuster("Jump Power",        "JumpPower",  50, "🌙", 1, 500)

SectionLabel("SURVIVAL", "🛡️")
CreateToggle("God Mode  (anti-die)", "GodMode",  "♾️", C.Gold)
CreateToggle("Anti Void",            "AntiVoid", "🌌")
CreateToggle("Freeze Character",     "FreezeChar","🧊", C.Red)

SectionLabel("WORLD", "🌍")
CreateToggle("Full Bright",   "FullBright", "☀️", C.Gold)
CreateToggle("Click Teleport","ClickTP",    "🎯")

SectionLabel("ACTIONS", "⚡")
CreateAction("Teleport to Spawn", "🏠", function()
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if hrp and spawn then
        hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
    elseif hrp then
        hrp.CFrame = CFrame.new(0, 10, 0)
    end
end, Color3.fromRGB(0, 50, 100))

CreateAction("Reset Character", "💀", function()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end, C.RedDim)

CreateAction("Rejoin Server", "🔄", function()
    local TS = game:GetService("TeleportService")
    TS:Teleport(game.PlaceId, Player)
end, Color3.fromRGB(50, 20, 80))

-- Small padding at bottom
local bottomPad = Instance.new("Frame", Scroll)
bottomPad.Size = UDim2.new(1,0,0,8)
bottomPad.BackgroundTransparency = 1
bottomPad.LayoutOrder = sectionOrder + 1

-- ══════════════════════════════════════════════
--  TOGGLE PANEL OPEN/CLOSE  (with tween)
-- ══════════════════════════════════════════════
local menuOpen = false
local function ToggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, PANEL_W, 0, 0)
        Tween(MainFrame, {Size = UDim2.new(0, PANEL_W, 0, PANEL_H)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(MainFrame, {Size = UDim2.new(0, PANEL_W, 0, 0)}, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.17, function() MainFrame.Visible = false end)
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)

-- Keyboard shortcut: RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
    end
end)

-- ══════════════════════════════════════════════
--  RUNTIME SYSTEMS
-- ══════════════════════════════════════════════

-- Original Lighting Ambient cache
local origAmb      = Lighting.Ambient
local origFogEnd   = Lighting.FogEnd
local origBrightness = Lighting.Brightness
local fullBrightApplied = false

RunService.RenderStepped:Connect(function(dt)
    local char = Player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    -- ── FLY ──
    if State.Fly and hrp and hum then
        if not BodyGyro then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 2, 0)
            BodyGyro = Instance.new("BodyGyro", hrp)
            BodyGyro.P = 9e4
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity = Instance.new("BodyVelocity", hrp)
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        end
        BodyGyro.CFrame = Camera.CFrame
        local spd = math.max(hum.WalkSpeed, 30)
        local mv  = hum.MoveDirection
        if mv.Magnitude > 0 then
            BodyVelocity.Velocity = (Camera.CFrame.LookVector * mv.Z * -spd) + (Camera.CFrame.RightVector * mv.X * spd) + Vector3.new(0, 0, 0)
            -- Up/Down via W/S in air
            BodyVelocity.Velocity = Camera.CFrame.LookVector * spd
        else
            BodyVelocity.Velocity = Vector3.new(0, 0.05, 0)
        end
        hum.PlatformStand = true
    else
        if BodyGyro    then BodyGyro:Destroy();    BodyGyro    = nil end
        if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
        if hum and not State.FreezeChar then hum.PlatformStand = false end
    end

    -- ── NOCLIP ──
    if State.Noclip and char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- ── AUTO WALK ──
    if State.AutoWalk and hum then
        hum:Move(Vector3.new(0, 0, -1), true)
    end

    -- ── AUTO JUMP ──
    if State.AutoJump and hum then
        if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
            hum.Jump = true
        end
    end

    -- ── BUNNY HOP ──
    if State.BunnyHop and hum then
        if hum:GetState() == Enum.HumanoidStateType.Landed then
            hum.Jump = true
        end
    end

    -- ── GOD MODE ──
    if State.GodMode and hum then
        hum.Health = hum.MaxHealth
    end

    -- ── ANTI VOID ──
    if State.AntiVoid and hrp then
        if hrp.Position.Y < -80 then
            hrp.CFrame = CFrame.new(hrp.Position.X, 20, hrp.Position.Z)
        end
    end

    -- ── FREEZE CHARACTER ──
    if State.FreezeChar and hrp then
        hrp.Anchored = true
    elseif hrp then
        -- only unanchor if we just had it frozen
        if not State.FreezeChar then hrp.Anchored = false end
    end

    -- ── FULL BRIGHT ──
    if State.FullBright and not fullBrightApplied then
        fullBrightApplied = true
        origAmb       = Lighting.Ambient
        origFogEnd    = Lighting.FogEnd
        origBrightness= Lighting.Brightness
        Lighting.Ambient    = Color3.new(1,1,1)
        Lighting.FogEnd     = 1e6
        Lighting.Brightness = 2
    elseif not State.FullBright and fullBrightApplied then
        fullBrightApplied = false
        Lighting.Ambient    = origAmb
        Lighting.FogEnd     = origFogEnd
        Lighting.Brightness = origBrightness
    end
end)

-- ── INFINITE JUMP ──
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ── CLICK TELEPORT ──
Mouse.Button1Down:Connect(function()
    if State.ClickTP then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local target = Mouse.Hit
            if target then
                hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 4, 0))
            end
        end
    end
end)

-- ══════════════════════════════════════════════
--  NOTIFICATION TOAST
-- ══════════════════════════════════════════════
local function Toast(msg, color)
    local toast = Instance.new("Frame", ScreenGui)
    toast.Size = UDim2.new(0, 240, 0, 40)
    toast.Position = UDim2.new(0.5, -120, 1, -60)
    toast.BackgroundColor3 = color or C.Panel
    toast.BackgroundTransparency = 0.05
    toast.ZIndex = 100
    AddCorner(toast, 10)
    AddStroke(toast, color or C.Accent, 1.5)

    local lbl = Instance.new("TextLabel", toast)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextColor3 = C.White
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 101

    toast.Position = UDim2.new(0.5, -120, 1, 20)
    Tween(toast, {Position = UDim2.new(0.5, -120, 1, -60)}, 0.35, Enum.EasingStyle.Back)
    task.delay(2.5, function()
        Tween(toast, {Position = UDim2.new(0.5, -120, 1, 20), BackgroundTransparency = 1}, 0.3)
        task.delay(0.35, function() toast:Destroy() end)
    end)
end

task.delay(0.5, function()
    Toast("✦ Novatex V3 loaded  •  RightShift to toggle", C.Panel)
end)

-- ══════════════════════════════════════════════
print("[ NOVATEX V3 ]  Loaded — Delta Edition")
