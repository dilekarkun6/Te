-- ╔═══════════════════════════════════════════════════════════╗
-- ║           DELTA SCRIPT PRO v3.2                           ║
-- ║  Fly · Speed · ESP · GodMode · Aimbot · BunnyHop         ║
-- ║  NoClip · Teleport · Hitbox · Platform · Fun             ║
-- ║  Mobil + PC | RightShift=Menü | F=Fly | G=God | H=ESP   ║
-- ╚═══════════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local LP               = Players.LocalPlayer
local PG               = LP:WaitForChild("PlayerGui")
local Camera           = workspace.CurrentCamera

-- CİHAZ TESPİTİ
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPC     = not isMobile

-- ESKİ GUI TEMİZLE
pcall(function()
    if PG:FindFirstChild("DeltaPro") then PG:FindFirstChild("DeltaPro"):Destroy() end
end)

-- RENKLER
local C = {
    bg     = Color3.fromRGB(8,11,20),
    panel  = Color3.fromRGB(13,18,32),
    panel2 = Color3.fromRGB(17,23,40),
    border = Color3.fromRGB(26,40,72),
    accent = Color3.fromRGB(0,200,255),
    orange = Color3.fromRGB(255,115,35),
    green  = Color3.fromRGB(0,255,130),
    red    = Color3.fromRGB(255,50,50),
    yellow = Color3.fromRGB(255,215,0),
    purple = Color3.fromRGB(160,90,255),
    pink   = Color3.fromRGB(255,70,170),
    cyan   = Color3.fromRGB(0,240,200),
    text   = Color3.fromRGB(190,215,248),
    muted  = Color3.fromRGB(60,92,140),
    white  = Color3.new(1,1,1),
}

-- DURUM TABLOSU
local ST = {
    FlyOn   = false, SpeedOn = false, SpeedVal = 30,
    JumpOn  = false, JumpVal = 80,
    InfJump = false, NoClip  = false, BHop = false,
    GodMode = false,
    AimBot  = false, AimRange = 60,
    Hitbox  = false, HitboxSz = 8,
    ESPOn   = false, Fullbrt  = false, NightM = false,
    SpinOn  = false, SpinSpd  = 8,
    Platform= false,
    AntiAFK = false,
    MenuOpen= false,
    ActiveT = "HAREKET",
}

-- ── FLY SİSTEMİ ─────────────────────────────────────────────
local flyBV, flyBG = nil, nil
local FLY_SPEED    = 65
local flyUp, flyDown = false, false

local function enableFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.Velocity  = Vector3.zero
    flyBV.MaxForce  = Vector3.new(1e5,1e5,1e5)
    flyBV.Parent    = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e4,9e4,9e4)
    flyBG.P         = 9e3
    flyBG.CFrame    = hrp.CFrame
    flyBG.Parent    = hrp
end

local function disableFly()
    pcall(function()
        local char = LP.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
    end)
end

RunService.RenderStepped:Connect(function()
    if not ST.FlyOn or not flyBV or not flyBG then return end
    local vel = Vector3.zero
    local cf  = Camera.CFrame
    if isPC then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) or
           UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) or
           UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0,1,0) end
    else
        local char = LP.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                local md = hum.MoveDirection
                if md.Magnitude > 0.1 then vel = vel + md end
            end
        end
        if flyUp   then vel = vel + Vector3.new(0,1,0) end
        if flyDown then vel = vel - Vector3.new(0,1,0) end
    end
    if vel.Magnitude > 0 then
        flyBV.Velocity = vel.Unit * FLY_SPEED
    else
        flyBV.Velocity = Vector3.zero
    end
    flyBG.CFrame = cf
end)

-- ── ESP SİSTEMİ ─────────────────────────────────────────────
local espData = {}

local function clearESP()
    for _, objs in pairs(espData) do
        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
    end
    espData = {}
end

local function updateESP()
    if not ST.ESPOn then clearESP(); return end
    local existing = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            existing[plr] = true
            local char = plr.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChild("Humanoid")
            if hrp and hum then
                if not espData[plr] then
                    espData[plr] = {}
                    local box = Instance.new("SelectionBox")
                    box.Adornee = char; box.Color3 = C.accent
                    box.LineThickness = 0.032
                    box.SurfaceTransparency = 0.92
                    box.SurfaceColor3 = C.accent
                    box.Parent = workspace
                    table.insert(espData[plr], box)

                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0,130,0,62)
                    bb.StudsOffset = Vector3.new(0,3.5,0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp; bb.Parent = workspace

                    local nl = Instance.new("TextLabel")
                    nl.Size = UDim2.new(1,0,0,20)
                    nl.BackgroundTransparency = 1
                    nl.Text = plr.Name; nl.TextColor3 = C.yellow
                    nl.TextSize = 13; nl.Font = Enum.Font.GothamBold
                    nl.TextStrokeTransparency = 0; nl.Parent = bb

                    local hpBg = Instance.new("Frame")
                    hpBg.Name = "HPBg"; hpBg.Size = UDim2.new(0.9,0,0,6)
                    hpBg.Position = UDim2.new(0.05,0,0,24)
                    hpBg.BackgroundColor3 = Color3.fromRGB(35,35,35)
                    hpBg.BorderSizePixel = 0; hpBg.Parent = bb
                    Instance.new("UICorner",hpBg).CornerRadius = UDim.new(1,0)

                    local hpFill = Instance.new("Frame")
                    hpFill.Name = "HPFill"; hpFill.Size = UDim2.new(1,0,1,0)
                    hpFill.BackgroundColor3 = C.green
                    hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
                    Instance.new("UICorner",hpFill).CornerRadius = UDim.new(1,0)

                    local hpTxt = Instance.new("TextLabel")
                    hpTxt.Name = "HPTxt"; hpTxt.Size = UDim2.new(1,0,0,16)
                    hpTxt.Position = UDim2.new(0,0,0,32)
                    hpTxt.BackgroundTransparency = 1
                    hpTxt.TextColor3 = C.green; hpTxt.TextSize = 10
                    hpTxt.Font = Enum.Font.GothamBold
                    hpTxt.TextStrokeTransparency = 0; hpTxt.Parent = bb

                    local distTxt = Instance.new("TextLabel")
                    distTxt.Name = "DistTxt"; distTxt.Size = UDim2.new(1,0,0,14)
                    distTxt.Position = UDim2.new(0,0,0,48)
                    distTxt.BackgroundTransparency = 1
                    distTxt.TextColor3 = C.muted; distTxt.TextSize = 9
                    distTxt.Font = Enum.Font.Gotham
                    distTxt.TextStrokeTransparency = 0; distTxt.Parent = bb
                    table.insert(espData[plr], bb)
                end

                for _, obj in ipairs(espData[plr]) do
                    if obj:IsA("BillboardGui") then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth,1), 0, 1)
                        local hpFill = obj:FindFirstChild("HPBg") and obj.HPBg:FindFirstChild("HPFill")
                        local hpTxt  = obj:FindFirstChild("HPTxt")
                        local dTxt   = obj:FindFirstChild("DistTxt")
                        if hpFill then
                            hpFill.Size = UDim2.new(pct,0,1,0)
                            hpFill.BackgroundColor3 = pct>0.6 and C.green or pct>0.3 and C.yellow or C.red
                        end
                        if hpTxt then
                            hpTxt.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth).." HP"
                            hpTxt.TextColor3 = pct>0.6 and C.green or pct>0.3 and C.yellow or C.red
                        end
                        if dTxt then
                            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if myHRP then
                                dTxt.Text = math.floor((hrp.Position-myHRP.Position).Magnitude).."m"
                            end
                        end
                    end
                    if obj:IsA("SelectionBox") and plr.Team then
                        obj.Color3 = plr.Team.TeamColor.Color
                    end
                end
            end
        end
    end
    for plr, _ in pairs(espData) do
        if not existing[plr] then
            for _, o in ipairs(espData[plr]) do pcall(function() o:Destroy() end) end
            espData[plr] = nil
        end
    end
end

-- ── PLATFORM SİSTEMİ (DÜZELTİLDİ: Anchored + CFrame) ─────────
local platPart = nil

local function createPlatform()
    if platPart then platPart:Destroy(); platPart = nil end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    platPart = Instance.new("Part")
    platPart.Name       = "DeltaPlatform"
    platPart.Size       = Vector3.new(10, 0.4, 10)
    platPart.Material   = Enum.Material.Neon
    platPart.Color      = C.purple
    platPart.Anchored   = true       -- Anchored = true, fizik yok
    platPart.CanCollide = true
    platPart.CFrame     = CFrame.new(hrp.Position - Vector3.new(0, 3.5, 0))
    platPart.Parent     = workspace
end

local function removePlatform()
    if platPart then
        platPart:Destroy()
        platPart = nil
    end
end

-- Platform her frame HRP altını takip eder
RunService.Heartbeat:Connect(function()
    if not ST.Platform or not platPart then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Yumuşak takip: lerp ile kademeli hareket
    local target = hrp.Position - Vector3.new(0, 3.5, 0)
    local current = platPart.Position
    platPart.CFrame = CFrame.new(current:Lerp(target, 0.3))
end)

-- ── GUI OLUŞTUR ──────────────────────────────────────────────
local SG = Instance.new("ScreenGui")
SG.Name           = "DeltaPro"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true
SG.Parent         = PG

-- ── TOGGLE BUTONU (emoji yerine metin) ─────────────────────
local TogBtn = Instance.new("TextButton")
TogBtn.Size             = UDim2.new(0, 58, 0, 30)
TogBtn.Position         = isMobile and UDim2.new(0,6,0.5,-15) or UDim2.new(0,6,0,95)
TogBtn.BackgroundColor3 = C.panel
TogBtn.Text             = "MENU"
TogBtn.TextColor3       = C.accent
TogBtn.TextSize         = 13
TogBtn.Font             = Enum.Font.GothamBold
TogBtn.ZIndex           = 20
TogBtn.BorderSizePixel  = 0
TogBtn.Parent           = SG
Instance.new("UICorner", TogBtn).CornerRadius = UDim.new(0, 6)
local tStr = Instance.new("UIStroke", TogBtn)
tStr.Color = C.accent; tStr.Thickness = 1.5

-- Mobil uçuş butonları
local function mkBtn(lbl, xsc, ysc, col)
    local b = Instance.new("TextButton")
    b.Size  = UDim2.new(0,50,0,50)
    b.Position = UDim2.new(xsc,0,ysc,0)
    b.BackgroundColor3 = C.panel
    b.BackgroundTransparency = 0.2
    b.Text = lbl; b.TextColor3 = col or C.white
    b.TextSize = 20; b.Font = Enum.Font.GothamBold
    b.ZIndex = 18; b.BorderSizePixel = 0
    b.Visible = false; b.Parent = SG
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke",b)
    s.Color = col or C.white; s.Thickness = 1.2
    return b
end
local btnUp   = mkBtn("^", 0.86, 0.73, C.accent)
local btnDown = mkBtn("v", 0.86, 0.84, C.accent)
btnUp.MouseButton1Down:Connect(function()   flyUp=true  end)
btnUp.MouseButton1Up:Connect(function()     flyUp=false end)
btnDown.MouseButton1Down:Connect(function() flyDown=true  end)
btnDown.MouseButton1Up:Connect(function()   flyDown=false end)

-- ── ANA MENU ─────────────────────────────────────────────────
local MW, MH = 338, 520
local Menu = Instance.new("Frame")
Menu.Size             = UDim2.new(0,MW,0,MH)
Menu.Position         = isMobile and UDim2.new(0,72,0.5,-MH/2) or UDim2.new(0,72,0,82)
Menu.BackgroundColor3 = C.bg
Menu.Visible          = false
Menu.ZIndex           = 10
Menu.BorderSizePixel  = 0
Menu.Active           = true   -- sürükleme için gerekli
Menu.Parent           = SG
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0,12)
local mStr = Instance.new("UIStroke", Menu)
mStr.Color = C.accent; mStr.Thickness = 1.5

-- Üst renkli çizgi
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1,0,0,3); topLine.BackgroundColor3 = C.accent
topLine.BorderSizePixel = 0; topLine.ZIndex = 14; topLine.Parent = Menu
Instance.new("UICorner",topLine).CornerRadius = UDim.new(1,0)

-- Başlık barı
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,48)
TitleBar.Position = UDim2.new(0,0,0,3)
TitleBar.BackgroundColor3 = C.panel
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11; TitleBar.Parent = Menu
TitleBar.Active = true

local TLbl = Instance.new("TextLabel")
TLbl.Size = UDim2.new(1,-54,0,24); TLbl.Position = UDim2.new(0,12,0,4)
TLbl.BackgroundTransparency = 1
TLbl.Text = "DELTA PRO v3.2"; TLbl.TextColor3 = C.accent
TLbl.TextSize = 14; TLbl.Font = Enum.Font.GothamBold
TLbl.TextXAlignment = Enum.TextXAlignment.Left
TLbl.ZIndex = 12; TLbl.Parent = TitleBar

local DLbl = Instance.new("TextLabel")
DLbl.Size = UDim2.new(1,-54,0,14); DLbl.Position = UDim2.new(0,12,0,29)
DLbl.BackgroundTransparency = 1
DLbl.Text = (isMobile and "Mobil" or "PC").." - "..LP.Name
DLbl.TextColor3 = C.muted; DLbl.TextSize = 10; DLbl.Font = Enum.Font.Gotham
DLbl.TextXAlignment = Enum.TextXAlignment.Left
DLbl.ZIndex = 12; DLbl.Parent = TitleBar

local XBtn = Instance.new("TextButton")
XBtn.Size = UDim2.new(0,28,0,28); XBtn.Position = UDim2.new(1,-38,0.5,-14)
XBtn.BackgroundColor3 = Color3.fromRGB(150,25,25)
XBtn.Text = "X"; XBtn.TextColor3 = C.white
XBtn.TextSize = 13; XBtn.Font = Enum.Font.GothamBold
XBtn.ZIndex = 13; XBtn.BorderSizePixel = 0; XBtn.Parent = TitleBar
Instance.new("UICorner",XBtn).CornerRadius = UDim.new(0,6)

-- ── MENÜYÜ SÜRÜKLE (Drag) ────────────────────────────────────
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = Menu.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement or
       inp.UserInputType == Enum.UserInputType.Touch then
        local delta = inp.Position - dragStart
        Menu.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or
       inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ── TAB BARI ─────────────────────────────────────────────────
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,30)
TabBar.Position = UDim2.new(0,0,0,52)
TabBar.BackgroundColor3 = C.panel
TabBar.BorderSizePixel = 0; TabBar.ZIndex = 11; TabBar.Parent = Menu
local TBL = Instance.new("UIListLayout")
TBL.FillDirection = Enum.FillDirection.Horizontal; TBL.Parent = TabBar

local TABS    = {"HAREKET","GORSEL","COMBAT","UTIL","FUN"}
local TABDISP = {"HARET","GORSEL","COMBAT","UTIL","FUN"}
local tabBtns = {}
local pages   = {}

for i, name in ipairs(TABS) do
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(1/#TABS,0,1,0)
    tb.BackgroundColor3 = i==1 and C.panel2 or C.panel
    tb.Text = TABDISP[i]
    tb.TextColor3 = i==1 and C.accent or C.muted
    tb.TextSize = isMobile and 8 or 8
    tb.Font = Enum.Font.GothamBold
    tb.ZIndex = 12; tb.BorderSizePixel = 0; tb.Parent = TabBar
    local ln = Instance.new("Frame")
    ln.Size = UDim2.new(1,0,0,2); ln.Position = UDim2.new(0,0,1,-2)
    ln.BackgroundColor3 = i==1 and C.accent or C.panel
    ln.BorderSizePixel = 0; ln.ZIndex = 13; ln.Parent = tb
    tabBtns[name] = {btn=tb, line=ln}
end

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1,0,1,-86)
ContentArea.Position = UDim2.new(0,0,0,86)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11; ContentArea.ClipsDescendants = true
ContentArea.Parent = Menu

local function mkPage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = C.accent
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ZIndex = 12; sf.BorderSizePixel = 0
    sf.Visible = false; sf.Parent = ContentArea
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0,4)
    l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = sf
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,8); p.PaddingRight = UDim.new(0,8)
    p.PaddingTop = UDim.new(0,7); p.PaddingBottom = UDim.new(0,10)
    p.Parent = sf
    return sf
end

for _, n in ipairs(TABS) do pages[n] = mkPage() end
pages["HAREKET"].Visible = true

local function switchTab(name)
    ST.ActiveT = name
    for n, pg in pairs(pages) do pg.Visible = (n == name) end
    for n, d in pairs(tabBtns) do
        local on = (n == name)
        d.btn.BackgroundColor3 = on and C.panel2 or C.panel
        d.btn.TextColor3 = on and C.accent or C.muted
        d.line.BackgroundColor3 = on and C.accent or C.panel
    end
end
for name, d in pairs(tabBtns) do
    d.btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ── WIDGET YARDIMCILARI ──────────────────────────────────────
local function addSec(page, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,16)
    l.BackgroundTransparency = 1; l.Text = txt
    l.TextColor3 = C.muted; l.TextSize = 9
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.ZIndex = 13; l.Parent = page
end

local function addTog(page, lbl, key, onCB, offCB)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,38)
    r.BackgroundColor3 = C.panel
    r.BorderSizePixel = 0; r.ZIndex = 13; r.Parent = page
    Instance.new("UICorner",r).CornerRadius = UDim.new(0,7)

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1,-60,1,0); lb.Position = UDim2.new(0,10,0,0)
    lb.BackgroundTransparency = 1; lb.Text = lbl
    lb.TextColor3 = C.text; lb.TextSize = 12
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 14; lb.Parent = r

    local on = key and ST[key] or false
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0,40,0,20); bg.Position = UDim2.new(1,-48,0.5,-10)
    bg.BackgroundColor3 = on and C.green or C.border
    bg.BorderSizePixel = 0; bg.ZIndex = 14; bg.Parent = r
    Instance.new("UICorner",bg).CornerRadius = UDim.new(1,0)

    local kn = Instance.new("Frame")
    kn.Size = UDim2.new(0,14,0,14)
    kn.Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    kn.BackgroundColor3 = C.white
    kn.BorderSizePixel = 0; kn.ZIndex = 15; kn.Parent = bg
    Instance.new("UICorner",kn).CornerRadius = UDim.new(1,0)

    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(1,0,1,0)
    cb.BackgroundTransparency = 1; cb.Text = ""
    cb.ZIndex = 16; cb.Parent = r

    cb.MouseButton1Click:Connect(function()
        if key then ST[key] = not ST[key]; on = ST[key] else on = not on end
        TweenService:Create(bg,TweenInfo.new(0.18),{BackgroundColor3=on and C.green or C.border}):Play()
        TweenService:Create(kn,TweenInfo.new(0.18),{
            Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()
        if on and onCB  then pcall(onCB)  end
        if not on and offCB then pcall(offCB) end
    end)
end

local function addSld(page, label, minV, maxV, def, cb)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(1,0,0,54)
    r.BackgroundColor3 = C.panel
    r.BorderSizePixel = 0; r.ZIndex = 13; r.Parent = page
    Instance.new("UICorner",r).CornerRadius = UDim.new(0,7)

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.62,0,0,22); lb.Position = UDim2.new(0,10,0,4)
    lb.BackgroundTransparency = 1; lb.Text = label
    lb.TextColor3 = C.text; lb.TextSize = 11
    lb.Font = Enum.Font.Gotham
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 14; lb.Parent = r

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.35,0,0,22); vl.Position = UDim2.new(0.63,0,0,4)
    vl.BackgroundTransparency = 1; vl.Text = tostring(def)
    vl.TextColor3 = C.accent; vl.TextSize = 13
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.ZIndex = 14; vl.Parent = r

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1,-20,0,5); tr.Position = UDim2.new(0,10,0,34)
    tr.BackgroundColor3 = C.border
    tr.BorderSizePixel = 0; tr.ZIndex = 14; tr.Parent = r
    Instance.new("UICorner",tr).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-minV)/math.max(maxV-minV,1),0,1,0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 15; fill.Parent = tr
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local dg = false
    local sb = Instance.new("TextButton")
    sb.Size = UDim2.new(1,0,0,26); sb.Position = UDim2.new(0,0,0,24)
    sb.BackgroundTransparency = 1; sb.Text = ""
    sb.ZIndex = 16; sb.Parent = r

    local function upd(px)
        local pct = math.clamp((px-tr.AbsolutePosition.X)/math.max(tr.AbsoluteSize.X,1),0,1)
        local v = math.floor(minV+pct*(maxV-minV))
        fill.Size = UDim2.new(pct,0,1,0); vl.Text = tostring(v)
        if cb then cb(v) end
    end
    sb.MouseButton1Down:Connect(function() dg=true end)
    UserInputService.InputChanged:Connect(function(i) if dg then upd(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end)
    sb.MouseButton1Click:Connect(function() upd(UserInputService:GetMouseLocation().X) end)
end

local function addBtn(page, label, color, cb)
    local r = Instance.new("TextButton")
    r.Size = UDim2.new(1,0,0,34)
    r.BackgroundColor3 = color or C.panel
    r.Text = label; r.TextColor3 = C.white
    r.TextSize = 12; r.Font = Enum.Font.GothamBold
    r.ZIndex = 13; r.BorderSizePixel = 0; r.Parent = page
    Instance.new("UICorner",r).CornerRadius = UDim.new(0,7)
    r.MouseButton1Click:Connect(function()
        TweenService:Create(r,TweenInfo.new(0.08),{BackgroundColor3=C.white}):Play()
        task.delay(0.15,function()
            TweenService:Create(r,TweenInfo.new(0.15),{BackgroundColor3=color or C.panel}):Play()
        end)
        if cb then pcall(cb) end
    end)
end

-- ── BİLDİRİM ─────────────────────────────────────────────────
local function notify(msg, col, dur)
    col = col or C.green; dur = dur or 3
    task.spawn(function()
        local n = Instance.new("ScreenGui")
        n.Name = "DN"..tostring(math.random(1000,9999)); n.Parent = PG
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0,268,0,40)
        f.Position = UDim2.new(1,10,0,14)
        f.BackgroundColor3 = C.panel; f.BorderSizePixel = 0; f.Parent = n
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
        local s = Instance.new("UIStroke",f); s.Color=col; s.Thickness=1.5
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,-10,1,0); l.Position = UDim2.new(0,5,0,0)
        l.BackgroundTransparency = 1; l.Text = msg
        l.TextColor3 = col; l.TextSize = 11
        l.Font = Enum.Font.GothamBold; l.ZIndex = 2; l.Parent = f
        TweenService:Create(f,TweenInfo.new(0.3),{Position=UDim2.new(1,-280,0,14)}):Play()
        task.wait(dur)
        TweenService:Create(f,TweenInfo.new(0.3),{Position=UDim2.new(1,10,0,14)}):Play()
        task.wait(0.35); n:Destroy()
    end)
end

-- ── HAREKET SAYFASI ──────────────────────────────────────────
local p1 = pages["HAREKET"]

addTog(p1,"Fly (Ucus)","FlyOn",
    function()
        enableFly()
        if isMobile then btnUp.Visible=true; btnDown.Visible=true end
        notify("Fly ACIK"..(isPC and " - W/S/A/D + E/Q" or ""),C.accent)
    end,
    function()
        disableFly(); btnUp.Visible=false; btnDown.Visible=false
        notify("Fly KAPALI",C.muted)
    end
)
addSld(p1,"Ucus Hizi",10,250,65,function(v) FLY_SPEED=v end)
addSec(p1,"------------------------")
addTog(p1,"Speed Hack","SpeedOn",
    function()
        local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=ST.SpeedVal end end
    end,
    function()
        local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=16 end end
    end
)
addSld(p1,"Hiz Degeri",16,300,30,function(v)
    ST.SpeedVal=v
    if ST.SpeedOn then
        local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.WalkSpeed=v end end
    end
end)
addTog(p1,"Jump Boost","JumpOn",
    function() local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.JumpPower=ST.JumpVal end end end,
    function() local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.JumpPower=50 end end end
)
addSld(p1,"Zipla Gucu",50,500,80,function(v)
    ST.JumpVal=v
    if ST.JumpOn then local c=LP.Character; if c then local h=c:FindFirstChild("Humanoid"); if h then h.JumpPower=v end end end
end)
addTog(p1,"Sonsuz Zipla","InfJump",nil,nil)
addTog(p1,"NoClip (Duvara gec)","NoClip",nil,nil)
addTog(p1,"BunnyHop","BHop",nil,nil)
addSec(p1,"-------- ISINLANMA --------")
addBtn(p1,"Spawn'a Isinla",Color3.fromRGB(28,52,78),function()
    local c=LP.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
    if hrp and sp then hrp.CFrame=sp.CFrame+Vector3.new(0,5,0); notify("Spawn'a isinlandin!",C.cyan) end
end)
addBtn(p1,"Rastgele Oyuncuya Isin",Color3.fromRGB(48,22,72),function()
    local tgts={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(tgts,p)
        end
    end
    if #tgts==0 then notify("Hedef yok",C.red); return end
    local t=tgts[math.random(1,#tgts)]
    local c=LP.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,4,0)
        notify(t.Name.." yanina isinlandin!",C.purple)
    end
end)
addBtn(p1,"Harita Merkezine Isin",Color3.fromRGB(18,58,38),function()
    local c=LP.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame=CFrame.new(0,50,0); notify("Merkeze isinlandin!",C.green) end
end)

-- ── GORSEL SAYFASI ───────────────────────────────────────────
local p2 = pages["GORSEL"]
addTog(p2,"ESP (Isim + HP + Mesafe)","ESPOn",
    function() notify("ESP ACIK",C.accent) end,
    function() clearESP(); notify("ESP KAPALI",C.muted) end
)
addTog(p2,"Fullbright","Fullbrt",
    function()
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        Lighting.Brightness=2.5; Lighting.ClockTime=12
    end,
    function()
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
        Lighting.Brightness=1; Lighting.ClockTime=14
    end
)
addTog(p2,"Gece Modu","NightM",
    function()
        Lighting.ClockTime=0; Lighting.FogEnd=220
        Lighting.FogColor=Color3.fromRGB(4,4,16)
        Lighting.Ambient=Color3.fromRGB(22,22,50)
    end,
    function()
        Lighting.ClockTime=14; Lighting.FogEnd=100000
        Lighting.Ambient=Color3.fromRGB(127,127,127)
    end
)
addSec(p2,"-------- KAMERA --------")
addSld(p2,"FOV Degeri",30,120,70,function(v) Camera.FieldOfView=v end)
addBtn(p2,"Max FOV (110)",Color3.fromRGB(22,42,72),function() Camera.FieldOfView=110 end)
addBtn(p2,"Normal FOV (70)",Color3.fromRGB(32,32,58),function() Camera.FieldOfView=70 end)

-- ── COMBAT SAYFASI ───────────────────────────────────────────
local p3 = pages["COMBAT"]
addTog(p3,"God Mode (Olumsuzhuk)","GodMode",
    function() notify("God Mode ACIK",C.green) end,
    function()
        local c=LP.Character; if c then
            local h=c:FindFirstChild("Humanoid")
            if h then h.MaxHealth=100; h.Health=100 end
        end
    end
)
addBtn(p3,"Aninda Tam Can",Color3.fromRGB(14,68,32),function()
    local c=LP.Character; if c then
        local h=c:FindFirstChild("Humanoid"); if h then h.Health=h.MaxHealth end
    end
    notify("Tam can!",C.green)
end)
addSec(p3,"-------- AIMBOT --------")
addTog(p3,"Aimbot (Otomatik Nisanla)","AimBot",
    function() notify("Aimbot ACIK - "..ST.AimRange.."m menzil",C.orange) end,
    nil
)
addSld(p3,"Aim Menzili",10,200,60,function(v) ST.AimRange=v end)
addSec(p3,"-------- HITBOX --------")
addTog(p3,"Hitbox Genislet","Hitbox",
    function() notify("Hitbox ACIK",C.orange) end,
    function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                for _,p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p:GetAttribute("OrigSz") then
                        p.Size=p:GetAttribute("OrigSz"); p:SetAttribute("OrigSz",nil)
                        p.Transparency=p:GetAttribute("OrigTr") or 0
                    end
                end
            end
        end
    end
)
addSld(p3,"Hitbox Boyutu",2,25,8,function(v) ST.HitboxSz=v end)

-- ── UTIL SAYFASI ─────────────────────────────────────────────
local p4 = pages["UTIL"]
addTog(p4,"Anti-AFK","AntiAFK",
    function() notify("Anti-AFK ACIK",C.green) end, nil
)
addSec(p4,"-------- BILGI --------")
addBtn(p4,"Oyun Bilgisi",Color3.fromRGB(18,36,62),function()
    local ping = math.floor(LP:GetNetworkPing()*1000)
    local pc   = #Players:GetPlayers()
    notify(pc.." oyuncu | "..ping.."ms ping | Place:"..game.PlaceId,C.accent,5)
end)
addBtn(p4,"PlaceId Kopyala",Color3.fromRGB(22,48,68),function()
    pcall(function() setclipboard(tostring(game.PlaceId)) end)
    notify("PlaceId: "..tostring(game.PlaceId),C.accent,4)
end)
addBtn(p4,"Sunucu Degistir",Color3.fromRGB(28,48,78),function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end)
addBtn(p4,"Chat Mesaji Gonder",Color3.fromRGB(22,58,42),function()
    pcall(function()
        game:GetService("Chat"):Chat(
            LP.Character and LP.Character:FindFirstChild("Head"),
            "Delta Pro v3.2"
        )
    end)
end)
addBtn(p4,"GUI Kaldir",Color3.fromRGB(72,14,14),function()
    SG:Destroy()
end)

-- ── FUN SAYFASI ──────────────────────────────────────────────
local p5 = pages["FUN"]
local spinConn = nil
addTog(p5,"Spin (Karakter Donuyor)","SpinOn",
    function()
        spinConn = RunService.Heartbeat:Connect(function()
            local c=LP.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(ST.SpinSpd),0) end
        end)
        notify("Spin ACIK",C.pink)
    end,
    function()
        if spinConn then spinConn:Disconnect(); spinConn=nil end
    end
)
addSld(p5,"Spin Hizi",1,30,8,function(v) ST.SpinSpd=v end)
addTog(p5,"Platform (Ayak Alti)","Platform",
    function() createPlatform(); notify("Platform ACIK",C.purple) end,
    function() removePlatform() end
)
addBtn(p5,"Karakter Buyut",Color3.fromRGB(48,28,68),function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size=p.Size*1.5 end
    end
    notify("Buyutuldu!",C.purple)
end)
addBtn(p5,"Karakter Kucult",Color3.fromRGB(28,48,58),function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size=p.Size*0.65 end
    end
    notify("Kucultuldu!",C.cyan)
end)
addBtn(p5,"Neon Karakter",Color3.fromRGB(28,38,68),function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Material=Enum.Material.Neon end
    end
    notify("Neon modu!",C.yellow)
end)
addBtn(p5,"Koy Rengini Degistir",Color3.fromRGB(45,18,65),function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Color=Color3.fromHSV(math.random(),0.8,1)
        end
    end
    notify("Renkler degistirildi!",C.pink)
end)
addBtn(p5,"Karakteri Sifirla",Color3.fromRGB(68,18,18),function()
    LP.Character:BreakJoints()
end)

-- ── RUNTIME ──────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    local c = LP.Character; if not c then return end
    local hum = c:FindFirstChild("Humanoid")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if ST.SpeedOn and hum then hum.WalkSpeed = ST.SpeedVal end
    if ST.JumpOn  and hum then hum.JumpPower = ST.JumpVal  end
    if ST.GodMode and hum then hum.Health = hum.MaxHealth  end
    if ST.NoClip and hrp then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if ST.BHop and hum then
        if hum:GetState() == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if ST.AimBot and hrp then
        local best, bestD = nil, ST.AimRange
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local tgt = plr.Character:FindFirstChild("Head") or
                            plr.Character:FindFirstChild("HumanoidRootPart")
                if tgt then
                    local d = (tgt.Position-hrp.Position).Magnitude
                    if d < bestD then bestD=d; best=tgt end
                end
            end
        end
        if best then Camera.CFrame=CFrame.new(Camera.CFrame.Position,best.Position) end
    end
    if ST.Hitbox then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if not root:GetAttribute("OrigSz") then
                        root:SetAttribute("OrigSz", root.Size)
                        root:SetAttribute("OrigTr", root.Transparency)
                    end
                    root.Size = Vector3.new(ST.HitboxSz,ST.HitboxSz,ST.HitboxSz)
                    root.Transparency = 0.85
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not ST.InfJump then return end
    local c=LP.Character; if not c then return end
    local h=c:FindFirstChild("Humanoid")
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

LP.Idled:Connect(function()
    if ST.AntiAFK then
        VirtualUser:Button2Down(Vector2.zero,Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.zero,Camera.CFrame)
    end
end)

RunService.RenderStepped:Connect(updateESP)

LP.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    local hum = char:FindFirstChild("Humanoid")
    if ST.SpeedOn and hum then hum.WalkSpeed = ST.SpeedVal end
    if ST.JumpOn  and hum then hum.JumpPower = ST.JumpVal  end
    if ST.FlyOn   then task.wait(0.5); enableFly() end
end)

-- ── MENU AC/KAPAT ────────────────────────────────────────────
local menuAnim = false

local function openMenu()
    if menuAnim then return end
    menuAnim = true; ST.MenuOpen = true
    Menu.Visible = true
    Menu.Size    = UDim2.new(0,MW,0,0)
    Menu.BackgroundTransparency = 1
    local t = TweenService:Create(Menu,
        TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,MW,0,MH),BackgroundTransparency=0})
    t.Completed:Connect(function() menuAnim=false end)
    t:Play()
    TogBtn.Text = "KAPAT"
end

local function closeMenu()
    if menuAnim then return end
    menuAnim = true; ST.MenuOpen = false
    local t = TweenService:Create(Menu,
        TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
        {Size=UDim2.new(0,MW,0,0),BackgroundTransparency=1})
    t.Completed:Connect(function() Menu.Visible=false; menuAnim=false end)
    t:Play()
    TogBtn.Text = "MENU"
end

TogBtn.MouseButton1Click:Connect(function()
    if ST.MenuOpen then closeMenu() else openMenu() end
end)
XBtn.MouseButton1Click:Connect(closeMenu)

if isPC then
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.RightShift then
            if ST.MenuOpen then closeMenu() else openMenu() end
        end
        if inp.KeyCode == Enum.KeyCode.F then
            ST.FlyOn = not ST.FlyOn
            if ST.FlyOn then enableFly(); notify("Fly ACIK [F]",C.accent)
            else disableFly(); notify("Fly KAPALI [F]",C.muted) end
        end
        if inp.KeyCode == Enum.KeyCode.G then
            ST.GodMode = not ST.GodMode
            notify(ST.GodMode and "God Mode ACIK [G]" or "God Mode KAPALI [G]",C.green)
        end
        if inp.KeyCode == Enum.KeyCode.H then
            ST.ESPOn = not ST.ESPOn
            if not ST.ESPOn then clearESP() end
            notify(ST.ESPOn and "ESP ACIK [H]" or "ESP KAPALI [H]",C.accent)
        end
        if inp.KeyCode == Enum.KeyCode.K then
            ST.NoClip = not ST.NoClip
            notify(ST.NoClip and "NoClip ACIK [K]" or "NoClip KAPALI [K]",C.orange)
        end
    end)
end

-- BASLANGIC
task.spawn(function()
    task.wait(0.3)
    notify("Delta Pro v3.2 Yuklendi! "..(isMobile and "Mobil" or "PC"),C.green,3.5)
    if isPC then
        task.wait(1.3)
        notify("RShift=Menu | F=Fly | G=God | H=ESP | K=NoClip",C.text,5)
    end
end)

print("[Delta Pro v3.2] Yuklendi! Cihaz: "..(isMobile and "Mobil" or "PC"))
