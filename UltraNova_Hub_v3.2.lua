--[[
    ╔══════════════════════════════════════════════════════╗
    ║                 UltraNova Hub v3.2                 ║
    ║            Created by OfficialGattino              ║
    ║   Single-file • No Key System • Mobile / Tablet    ║
    ╚══════════════════════════════════════════════════════╝

    UltraNova Hub
    Smooth mobile / tablet interface • No key system
]]

--========================================================
-- SERVICES
--========================================================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local unpackArgs = table.unpack or unpack

local function character()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function humanoid()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

--========================================================
-- PARENT + CLEAN OLD UI
--========================================================
local GuiParent = LP:WaitForChild("PlayerGui")
pcall(function()
    if gethui then
        GuiParent = gethui()
    else
        GuiParent = CoreGui
    end
end)

pcall(function()
    local old = GuiParent:FindFirstChild("UltraNovaHub")
    if old then old:Destroy() end
    local oldAim = GuiParent:FindFirstChild("UltraNovaAimOverlay")
    if oldAim then oldAim:Destroy() end
end)

--========================================================
-- THEME
--========================================================
local C = {
    Space       = Color3.fromRGB(7, 5, 17),
    Space2      = Color3.fromRGB(13, 8, 30),
    Panel       = Color3.fromRGB(20, 14, 43),
    Panel2      = Color3.fromRGB(29, 19, 60),
    Panel3      = Color3.fromRGB(38, 24, 78),
    Purple      = Color3.fromRGB(151, 77, 255),
    PurpleDark  = Color3.fromRGB(97, 46, 191),
    Blue        = Color3.fromRGB(62, 148, 255),
    Cyan        = Color3.fromRGB(93, 220, 255),
    White       = Color3.fromRGB(246, 246, 255),
    Soft        = Color3.fromRGB(189, 184, 213),
    Green       = Color3.fromRGB(83, 255, 133),
    Red         = Color3.fromRGB(255, 72, 92),
    Orange      = Color3.fromRGB(255, 181, 76),
    Yellow      = Color3.fromRGB(255, 232, 91),
    Black       = Color3.fromRGB(4, 4, 10),
}

local ESP_PALETTE = {
    C.Purple, C.Blue, C.Cyan, C.Green, C.Red, C.Orange,
    C.Yellow, C.White, Color3.fromRGB(255, 90, 220)
}

local function corner(obj, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 10)
    x.Parent = obj
    return x
end

local function stroke(obj, color, thickness, transparency)
    local x = Instance.new("UIStroke")
    x.Color = color or C.Purple
    x.Thickness = thickness or 1
    x.Transparency = transparency or 0
    x.Parent = obj
    return x
end

local function gradient(obj, a, b, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(a, b)
    g.Rotation = rot or 0
    g.Parent = obj
    return g
end

local function padding(obj, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = obj
end

--========================================================
-- STATE
--========================================================
local S = {
    speed = 16,
    jump = 50,
    gravity = workspace.Gravity,

    infiniteJump = false,
    autoJump = false,
    noclip = false,
    fly = false,
    flySpeed = 55,
    flyVertical = 0,
    clickTP = false,
    airWalk = false,
    spin = false,
    spinSpeed = 8,
    localInvisible = false,

    esp = false,
    espTarget = nil, -- nil = all
    espColor = C.Purple,
    espColorIndex = 1,
    espName = true,
    espDistance = true,

    fullbright = false,
    noFog = false,
    xray = false,
    fov = Camera.FieldOfView,

    crosshair = false,
    crosshairSpin = false,
    crosshairSize = 30,

    aimbot = false,
    aimTarget = nil, -- nil = auto nearest
    aimFov = 180,
    aimSmooth = 8,
    aimWallCheck = true,
    aimTeamCheck = false,
    aimPart = "Head",

    silentAim = false,

    antiAfk = false,

    -- v3.2 movement+
    dashPower = 82,
    antiVoid = false,
    antiVoidDepth = 48,
    freezePosition = false,
    float = false,
    waterWalk = false,

    -- v3.2 player tools
    selectedPlayer = nil,
    orbitPlayer = false,
    orbitRadius = 6,
    orbitSpeed = 2,
    playerRadar = false,
    healthMonitor = false,

    -- v3.2 visual extras
    tracers = false,
    boxEsp = false,
    healthBars = false,
    skeletonEsp = false,
    chams = false,
    playerGlow = false,
    rainbowEsp = false,
    espMaxDistance = 2500,
    nightVision = false,
    crosshairThickness = 2,
    crosshairOpacity = 0,
    crosshairColorIndex = 1,

    -- v3.2 camera
    freecam = false,
    freecamSpeed = 28,
    cameraRoll = 0,
    thirdPersonDistance = 12,

    -- v3.2 UI / settings
    menuMusic = true,
    menuMusicVolume = 0.11,
    lineSpeed = 1.0,
    lineFx = true,
    reduceMotion = false,
    guiScale = 1.0,
    guiTransparency = 0,
    languageMode = "Bilingual",
    themeName = "Purple",
    activeShader = "None",
    activeDance = "None",
}

local original = {
    Gravity = workspace.Gravity,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation,
    ColorShiftTop = Lighting.ColorShift_Top,
    ColorShiftBottom = Lighting.ColorShift_Bottom,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    FOV = Camera.FieldOfView,
}

--========================================================
-- ROOT GUI
--========================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "UltraNovaHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = GuiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(670, 430)
Main.Position = UDim2.fromScale(.5, .5)
Main.AnchorPoint = Vector2.new(.5, .5)
Main.BackgroundColor3 = C.Space
Main.ClipsDescendants = true
Main.Parent = Gui
corner(Main, 18)
stroke(Main, C.Purple, 1.5, .10)
gradient(Main, C.Space, C.Space2, 35)

-- auto-scale for phone / tablet
local Scale = Instance.new("UIScale")
Scale.Parent = Main

local function refreshScale()
    Camera = workspace.CurrentCamera or Camera
    local v = Camera.ViewportSize
    local autoScale = math.clamp(math.min(v.X / 790, v.Y / 540), .62, 1)
    Scale.Scale = autoScale * (S.guiScale or 1)
end
refreshScale()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale)

-- subtle moving stars
local Stars = Instance.new("Frame")
Stars.Size = UDim2.fromScale(1,1)
Stars.BackgroundTransparency = 1
Stars.ZIndex = 1
Stars.Parent = Main

for i = 1, 28 do
    local s = Instance.new("Frame")
    local sz = (i % 4 == 0) and 3 or 2
    s.Size = UDim2.fromOffset(sz, sz)
    s.Position = UDim2.new(((i * 37) % 100)/100, 0, ((i * 61) % 100)/100, 0)
    s.BackgroundColor3 = (i % 3 == 0) and C.Cyan or C.White
    s.BackgroundTransparency = .42 + ((i % 5) * .08)
    s.ZIndex = 1
    s.Parent = Stars
    corner(s, 8)

    TweenService:Create(
        s,
        TweenInfo.new(2.5 + (i % 5), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        {BackgroundTransparency = .86}
    ):Play()
end

-- moving light streaks (v3.2: controllable speed / reduce motion)
local MainLineFX = {}

local function startMainLineTween(entry)
    if entry.Tween then pcall(function() entry.Tween:Cancel() end) end
    entry.Line.Position = entry.StartPos
    entry.Line.Visible = S.lineFx and not S.reduceMotion
    local duration = (5.4 + entry.Index * .52) / math.max(.25, S.lineSpeed or 1)
    entry.Tween = TweenService:Create(
        entry.Line,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
        {Position = entry.EndPos}
    )
    if entry.Line.Visible then entry.Tween:Play() end
end

local function restartMainLineTweens()
    for _,entry in ipairs(MainLineFX) do startMainLineTween(entry) end
end

for i = 1, 10 do
    local line = Instance.new("Frame")
    line.Size = UDim2.fromOffset(145 + i * 19, 1)
    line.BackgroundColor3 = (i % 3 == 0) and C.Cyan or C.White
    line.BackgroundTransparency = .80 + ((i % 3) * .035)
    line.Rotation = -12 + i * 2.4
    line.ZIndex = 1
    line.Parent = Main

    local entry = {
        Line = line,
        Index = i,
        StartPos = UDim2.new(-.58, 0, .035 + i * .087, 0),
        EndPos = UDim2.new(1.10, 0, .02 + i * .087, 0),
        Tween = nil
    }
    table.insert(MainLineFX, entry)
    startMainLineTween(entry)
end

--========================================================
-- HEADER
--========================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = C.Space2
Header.BackgroundTransparency = .05
Header.ZIndex = 10
Header.Parent = Main

local NovaIcon = Instance.new("TextLabel")
NovaIcon.Size = UDim2.fromOffset(42,42)
NovaIcon.Position = UDim2.fromOffset(10,8)
NovaIcon.BackgroundColor3 = C.PurpleDark
NovaIcon.Text = "✦"
NovaIcon.TextColor3 = C.White
NovaIcon.TextScaled = true
NovaIcon.Font = Enum.Font.GothamBold
NovaIcon.ZIndex = 11
NovaIcon.Parent = Header
corner(NovaIcon, 13)
stroke(NovaIcon, C.Cyan, 1.2, .15)
gradient(NovaIcon, C.PurpleDark, C.Blue, 45)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-185,1,0)
Title.Position = UDim2.fromOffset(62,0)
Title.BackgroundTransparency = 1
Title.Text = "UltraNova Hub"
Title.TextColor3 = C.White
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 11
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1,-185,0,18)
SubTitle.Position = UDim2.fromOffset(64,34)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "OfficialGattino • UltraNova Hub"
SubTitle.TextColor3 = C.Soft
SubTitle.TextSize = 10
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Font = Enum.Font.Gotham
SubTitle.ZIndex = 11
SubTitle.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(40,34)
Minimize.Position = UDim2.new(1,-48,.5,-17)
Minimize.BackgroundColor3 = C.Panel2
Minimize.Text = "—"
Minimize.TextColor3 = C.White
Minimize.TextSize = 19
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.ZIndex = 11
Minimize.Parent = Header
corner(Minimize,10)

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.fromOffset(112,40)
Mini.Position = UDim2.new(0,16,.52,-20)
Mini.BackgroundColor3 = C.Space2
Mini.Text = ""
Mini.AutoButtonColor = false
Mini.Visible = false
Mini.ZIndex = 80
Mini.ClipsDescendants = false
Mini.Parent = Gui
corner(Mini,13)

-- Animated purple/cyan/white border
local MiniStroke = stroke(Mini,C.Purple,1.6,.02)
local MiniStrokeGradient = Instance.new("UIGradient")
MiniStrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.Purple),
    ColorSequenceKeypoint.new(.25,C.White),
    ColorSequenceKeypoint.new(.5,C.Cyan),
    ColorSequenceKeypoint.new(.75,C.Blue),
    ColorSequenceKeypoint.new(1,C.Purple)
})
MiniStrokeGradient.Parent = MiniStroke
TweenService:Create(
    MiniStrokeGradient,
    TweenInfo.new(2.8,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,false),
    {Rotation=360}
):Play()

-- Inner clipping mask: moving lines stay inside the button
local MiniInner = Instance.new("Frame")
MiniInner.Size = UDim2.new(1,-8,1,-8)
MiniInner.Position = UDim2.fromOffset(4,4)
MiniInner.BackgroundColor3 = C.Space2
MiniInner.BackgroundTransparency = .08
MiniInner.ClipsDescendants = true
MiniInner.ZIndex = 81
MiniInner.Parent = Mini
corner(MiniInner,9)
gradient(MiniInner,C.Space2,C.Panel2,25)

local MiniLineFX = {}

local function startMiniLineTween(entry)
    if entry.Tween then pcall(function() entry.Tween:Cancel() end) end
    entry.Line.Position = entry.StartPos
    entry.Line.Visible = S.lineFx and not S.reduceMotion
    local duration = (1.55 + entry.Index * .16) / math.max(.25, S.lineSpeed or 1)
    entry.Tween = TweenService:Create(
        entry.Line,
        TweenInfo.new(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,false),
        {Position=entry.EndPos}
    )
    if entry.Line.Visible then entry.Tween:Play() end
end

local function restartMiniLineTweens()
    for _,entry in ipairs(MiniLineFX) do startMiniLineTween(entry) end
end

for i = 1,7 do
    local line = Instance.new("Frame")
    line.Size = UDim2.fromOffset(34+i*7,1)
    line.BackgroundColor3 = (i%3==0) and C.Cyan or C.White
    line.BackgroundTransparency = .68+(i%3)*.06
    line.ZIndex = 82
    line.Parent = MiniInner
    local entry = {
        Line=line, Index=i,
        StartPos=UDim2.new(-.7,0,.06+i*.115,0),
        EndPos=UDim2.new(1.12,0,.06+i*.115,0),
        Tween=nil
    }
    table.insert(MiniLineFX,entry)
    startMiniLineTween(entry)
end

local MiniLabel = Instance.new("TextLabel")
MiniLabel.Size = UDim2.fromScale(1,1)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "UltraNova"
MiniLabel.TextColor3 = C.White
MiniLabel.TextSize = 11
MiniLabel.TextStrokeTransparency = .65
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.ZIndex = 85
MiniLabel.Parent = Mini

local MiniStar = Instance.new("TextLabel")
MiniStar.Size = UDim2.fromOffset(20,20)
MiniStar.Position = UDim2.fromOffset(5,10)
MiniStar.BackgroundTransparency = 1
MiniStar.Text = "✦"
MiniStar.TextColor3 = C.Cyan
MiniStar.TextSize = 11
MiniStar.Font = Enum.Font.GothamBold
MiniStar.ZIndex = 86
MiniStar.Parent = Mini

local miniDragging = false
local miniDragStart
local miniStartAbsolute
local miniDragInput
local miniMoved = false

Mini.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        miniDragging = true
        miniMoved = false
        miniDragStart = input.Position
        miniStartAbsolute = Mini.AbsolutePosition
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                miniDragging = false
            end
        end)
    end
end)

Mini.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        miniDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if miniDragging and input == miniDragInput then
        local delta = input.Position-miniDragStart
        if delta.Magnitude > 5 then miniMoved = true end
        local viewport = Camera.ViewportSize
        local newX = math.clamp(miniStartAbsolute.X+delta.X,4,viewport.X-Mini.AbsoluteSize.X-4)
        local newY = math.clamp(miniStartAbsolute.Y+delta.Y,4,viewport.Y-Mini.AbsoluteSize.Y-4)
        Mini.Position = UDim2.fromOffset(newX,newY)
    end
end)

Minimize.MouseButton1Click:Connect(function()
    Main.Visible = false
    Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
    if miniMoved then
        miniMoved = false
        return
    end
    Mini.Visible = false
    Main.Visible = true
end)

-- drag Header: touch + mouse
do
    local dragging = false
    local dragStart
    local startPos
    local dragInput

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

--========================================================
-- TOAST
--========================================================
local function toast(text, col)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(350,54)
    f.Position = UDim2.new(.5,-175,1,18)
    f.BackgroundColor3 = C.Panel2
    f.ZIndex = 200
    f.Parent = Gui
    corner(f,13)
    stroke(f,col or C.Purple,1.3,.08)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-22,1,0)
    l.Position = UDim2.fromOffset(11,0)
    l.BackgroundTransparency = 1
    l.Text = tostring(text)
    l.TextColor3 = C.White
    l.TextSize = 13
    l.TextWrapped = true
    l.Font = Enum.Font.GothamMedium
    l.ZIndex = 201
    l.Parent = f

    TweenService:Create(f,TweenInfo.new(.24,Enum.EasingStyle.Quint),{
        Position = UDim2.new(.5,-175,1,-76)
    }):Play()

    task.delay(2.6,function()
        if not f.Parent then return end
        TweenService:Create(f,TweenInfo.new(.22),{
            Position = UDim2.new(.5,-175,1,18),
            BackgroundTransparency = 1
        }):Play()
        task.wait(.25)
        if f then f:Destroy() end
    end)
end


--========================================================
-- MENU MUSIC / SPACE AMBIENCE (v3.2)
--========================================================
local MenuAmbience = Instance.new("Sound")
MenuAmbience.Name = "UltraNovaMenuAmbience"
MenuAmbience.SoundId = "rbxassetid://1845421369" -- Space Atmosphere
MenuAmbience.Volume = S.menuMusicVolume
MenuAmbience.Looped = true
MenuAmbience.Parent = SoundService

local MenuWhoosh = Instance.new("Sound")
MenuWhoosh.Name = "UltraNovaMenuWhoosh"
MenuWhoosh.SoundId = "rbxassetid://9114340342" -- gentle sci-fi pass-by
MenuWhoosh.Volume = math.max(.035,S.menuMusicVolume*.65)
MenuWhoosh.Looped = false
MenuWhoosh.Parent = SoundService

pcall(function()
    task.spawn(function()
        ContentProvider:PreloadAsync({MenuAmbience,MenuWhoosh})
    end)
end)

local function syncMenuAudio()
    local shouldPlay = S.menuMusic and Main.Visible
    MenuAmbience.Volume = S.menuMusicVolume
    MenuWhoosh.Volume = math.max(.025,S.menuMusicVolume*.62)
    if shouldPlay then
        if not MenuAmbience.IsPlaying then pcall(function() MenuAmbience:Play() end) end
    else
        pcall(function() MenuAmbience:Pause() end)
        pcall(function() MenuWhoosh:Stop() end)
    end
end

Main:GetPropertyChangedSignal("Visible"):Connect(syncMenuAudio)

task.spawn(function()
    while Gui.Parent do
        task.wait(math.random(8,15))
        if S.menuMusic and Main.Visible and not S.reduceMotion then
            pcall(function()
                MenuWhoosh.PlaybackSpeed = math.random(92,108)/100
                MenuWhoosh:Play()
            end)
        end
    end
end)

task.defer(syncMenuAudio)

--========================================================
-- SIDEBAR / PAGES
--========================================================
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0,158,1,-58)
Sidebar.Position = UDim2.fromOffset(0,58)
Sidebar.BackgroundColor3 = C.Space2
Sidebar.BackgroundTransparency = .11
Sidebar.ZIndex = 8
Sidebar.Parent = Main
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.fromOffset(0,0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = C.Purple
padding(Sidebar,8,8,12,8)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0,8)
SideList.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-158,1,-58)
Content.Position = UDim2.fromOffset(158,58)
Content.BackgroundTransparency = 1
Content.ZIndex = 8
Content.Parent = Main

local Pages = {}
local Navs = {}

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.fromScale(1,1)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = C.Purple
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.CanvasSize = UDim2.fromOffset(0,0)
    p.Visible = false
    p.ZIndex = 9
    p.Parent = Content
    padding(p,14,14,14,20)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0,9)
    list.Parent = p

    Pages[name] = p
    return p
end

local function switchPage(name)
    for n,p in pairs(Pages) do
        p.Visible = n == name
    end
    for n,b in pairs(Navs) do
        TweenService:Create(b,TweenInfo.new(.14),{
            BackgroundColor3 = (n == name) and C.PurpleDark or C.Panel
        }):Play()
    end
end

local function makeNav(name, text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,42)
    b.BackgroundColor3 = C.Panel
    b.Text = text
    b.TextColor3 = C.White
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    b.ZIndex = 10
    b.Parent = Sidebar
    corner(b,11)
    stroke(b,C.Purple,1,.68)

    b.MouseButton1Click:Connect(function()
        switchPage(name)
    end)

    Navs[name] = b
end

local Home = makePage("Home")
local Cheats = makePage("Cheats")
local PlayersPage = makePage("Players")
local CameraPage = makePage("Camera")
local VisualsPage = makePage("Visuals")
local Emotes = makePage("Emotes")
local Shaders = makePage("Shaders")
local ServerPage = makePage("Server")
local PerformancePage = makePage("Performance")
local ToolsPage = makePage("Tools")
local SettingsPage = makePage("Settings")

makeNav("Home","⌂   HOME")
makeNav("Cheats","✦   CHEATS")
makeNav("Players","◎   PLAYERS")
makeNav("Camera","◉   CAMERA")
makeNav("Visuals","◇   VISUALS")
makeNav("Emotes","♫   EMOTES")
makeNav("Shaders","◈   SHADERS")
makeNav("Server","⌁   SERVER")
makeNav("Performance","⚡   PERFORMANCE")
makeNav("Tools","＋   TOOLS")
makeNav("Settings","⚙   SETTINGS")

--========================================================
-- COMPONENTS
--========================================================
local ControlRegistry = {}

local function registerControl(parent,text,frame)
    if not parent or not frame or not text then return end
    table.insert(ControlRegistry,{
        Text=tostring(text),
        Page=parent.Name,
        Frame=frame
    })
end

local function heading(parent, title, subtitle)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1,0,0,subtitle and 58 or 38)
    wrap.BackgroundTransparency = 1
    wrap.ZIndex = 10
    wrap.Parent = parent

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,0,34)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.White
    t.TextSize = 19
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamBold
    t.ZIndex = 11
    t.Parent = wrap

    if subtitle then
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1,0,0,22)
        s.Position = UDim2.fromOffset(0,32)
        s.BackgroundTransparency = 1
        s.Text = subtitle
        s.TextColor3 = C.Soft
        s.TextSize = 11
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.Font = Enum.Font.Gotham
        s.ZIndex = 11
        s.Parent = wrap
    end
    return wrap
end

local function section(parent, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,28)
    l.BackgroundTransparency = 1
    l.Text = "✦  "..text
    l.TextColor3 = C.Cyan
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.ZIndex = 11
    l.Parent = parent
    return l
end

local function card(parent, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,height or 54)
    f.BackgroundColor3 = C.Panel
    f.BackgroundTransparency = .04
    f.ZIndex = 10
    f.Parent = parent
    corner(f,12)
    stroke(f,C.Purple,1,.72)
    return f
end

local function infoCard(parent, title, text)
    local f = card(parent,86)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-20,0,26)
    t.Position = UDim2.fromOffset(10,8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = C.White
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Font = Enum.Font.GothamBold
    t.ZIndex = 11
    t.Parent = f

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-20,1,-39)
    d.Position = UDim2.fromOffset(10,34)
    d.BackgroundTransparency = 1
    d.Text = text
    d.TextColor3 = C.Soft
    d.TextSize = 11
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextYAlignment = Enum.TextYAlignment.Top
    d.Font = Enum.Font.Gotham
    d.ZIndex = 11
    d.Parent = f

    return f,d
end

local function button(parent, text, callback)
    local f = card(parent,52)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-14,1,-14)
    b.Position = UDim2.fromOffset(7,7)
    b.BackgroundColor3 = C.Panel2
    b.Text = text
    b.TextColor3 = C.White
    b.TextSize = 12
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    b.ZIndex = 11
    b.Parent = f
    corner(b,10)
    registerControl(parent,text,f)

    b.MouseButton1Click:Connect(function()
        TweenService:Create(b,TweenInfo.new(.07),{BackgroundColor3=C.PurpleDark}):Play()
        task.delay(.12,function()
            if b.Parent then
                TweenService:Create(b,TweenInfo.new(.13),{BackgroundColor3=C.Panel2}):Play()
            end
        end)
        if callback then callback(b) end
    end)

    return b,f
end

local function toggle(parent, text, default, callback)
    local state = not not default
    local f = card(parent,54)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-90,1,0)
    l.Position = UDim2.fromOffset(12,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.White
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamSemibold
    l.ZIndex = 11
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(60,30)
    b.Position = UDim2.new(1,-72,.5,-15)
    b.BackgroundColor3 = state and C.Purple or C.Black
    b.Text = state and "ON" or "OFF"
    b.TextColor3 = C.White
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.ZIndex = 11
    b.Parent = f
    corner(b,12)
    registerControl(parent,text,f)

    local function render()
        b.Text = state and "ON" or "OFF"
        TweenService:Create(b,TweenInfo.new(.14),{
            BackgroundColor3 = state and C.Purple or C.Black
        }):Play()
    end

    b.MouseButton1Click:Connect(function()
        state = not state
        render()
        if callback then callback(state) end
    end)

    return {
        Frame = f,
        Label = l,
        Button = b,
        Get = function() return state end,
        Set = function(v)
            state = not not v
            render()
            if callback then callback(state) end
        end
    }
end

local function slider(parent, text, minv, maxv, default, callback)
    local value = default
    local f = card(parent,72)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,-84,0,28)
    l.Position = UDim2.fromOffset(12,4)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = C.White
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamSemibold
    l.ZIndex = 11
    l.Parent = f

    local val = Instance.new("TextLabel")
    val.Size = UDim2.fromOffset(66,28)
    val.Position = UDim2.new(1,-78,0,4)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = C.Cyan
    val.TextSize = 12
    val.Font = Enum.Font.GothamBold
    val.ZIndex = 11
    val.Parent = f

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-26,0,9)
    bar.Position = UDim2.fromOffset(13,48)
    bar.BackgroundColor3 = C.Black
    bar.ZIndex = 11
    bar.Parent = f
    corner(bar,8)

    local pct0 = (default-minv)/(maxv-minv)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct0,0,1,0)
    fill.BackgroundColor3 = C.Purple
    fill.ZIndex = 12
    fill.Parent = bar
    corner(fill,8)
    gradient(fill,C.Purple,C.Blue,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18,18)
    knob.AnchorPoint = Vector2.new(.5,.5)
    knob.Position = UDim2.new(pct0,0,.5,0)
    knob.BackgroundColor3 = C.White
    knob.ZIndex = 13
    knob.Parent = bar
    corner(knob,9)
    stroke(knob,C.Purple,1,.1)

    registerControl(parent,text,f)

    local dragging = false

    local function setX(x)
        local pct = math.clamp((x-bar.AbsolutePosition.X)/math.max(1,bar.AbsoluteSize.X),0,1)
        value = math.floor(minv + (maxv-minv)*pct + .5)
        fill.Size = UDim2.new(pct,0,1,0)
        knob.Position = UDim2.new(pct,0,.5,0)
        val.Text = tostring(value)
        if callback then callback(value) end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            setX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {
        Frame = f,
        Label = l,
        Get = function() return value end,
        Set = function(v)
            value = math.clamp(math.floor(v + .5),minv,maxv)
            local pct = (value-minv)/(maxv-minv)
            fill.Size = UDim2.new(pct,0,1,0)
            knob.Position = UDim2.new(pct,0,.5,0)
            val.Text = tostring(value)
            if callback then callback(value) end
        end
    }
end

--========================================================
-- PLAYER PICKER (dynamic current server list)
--========================================================
local ModalDim = Instance.new("TextButton")
ModalDim.Size = UDim2.fromScale(1,1)
ModalDim.BackgroundColor3 = Color3.new(0,0,0)
ModalDim.BackgroundTransparency = .42
ModalDim.Text = ""
ModalDim.AutoButtonColor = false
ModalDim.Visible = false
ModalDim.ZIndex = 150
ModalDim.Parent = Gui

local function playerPicker(title, allowAll, callback)
    ModalDim.Visible = true

    local modal = Instance.new("Frame")
    modal.Size = UDim2.fromOffset(350,350)
    modal.Position = UDim2.fromScale(.5,.5)
    modal.AnchorPoint = Vector2.new(.5,.5)
    modal.BackgroundColor3 = C.Space2
    modal.ZIndex = 151
    modal.Parent = Gui
    corner(modal,17)
    stroke(modal,C.Purple,1.5,.08)

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1,-54,0,48)
    ttl.Position = UDim2.fromOffset(12,0)
    ttl.BackgroundTransparency = 1
    ttl.Text = title
    ttl.TextColor3 = C.White
    ttl.TextSize = 16
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Font = Enum.Font.GothamBold
    ttl.ZIndex = 152
    ttl.Parent = modal

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(36,32)
    close.Position = UDim2.new(1,-44,0,8)
    close.BackgroundColor3 = C.Panel2
    close.Text = "×"
    close.TextColor3 = C.White
    close.TextSize = 18
    close.Font = Enum.Font.GothamBold
    close.ZIndex = 152
    close.Parent = modal
    corner(close,10)

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1,-20,1,-62)
    list.Position = UDim2.fromOffset(10,52)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.fromOffset(0,0)
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = C.Purple
    list.ZIndex = 152
    list.Parent = modal

    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0,7)
    ll.Parent = list

    local function dismiss()
        ModalDim.Visible = false
        if modal then modal:Destroy() end
    end

    close.MouseButton1Click:Connect(dismiss)

    local function addChoice(text, p)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,-5,0,44)
        b.BackgroundColor3 = C.Panel
        b.Text = text
        b.TextColor3 = C.White
        b.TextSize = 12
        b.Font = Enum.Font.GothamSemibold
        b.AutoButtonColor = false
        b.ZIndex = 153
        b.Parent = list
        corner(b,10)
        b.MouseButton1Click:Connect(function()
            dismiss()
            callback(p)
        end)
    end

    if allowAll then
        addChoice("★  Tutti / Everyone", nil)
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            addChoice(p.DisplayName.."   @"..p.Name, p)
        end
    end
end

--========================================================
-- HOME
--========================================================
local gameName = "Unknown"
pcall(function()
    gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

heading(Home, "ULTRANOVA HUB", "Space UI • Mobile / Tablet • No Key System")

local Credits, CreditsText = infoCard(
    Home,
    "✦  Crediti / Credits",
    "Creato da / Created by: OfficialGattino\n"..
    "Concept, nome e design: OfficialGattino\n"..
    "UltraNova Hub • v3.2"
)

local Info, InfoText = infoCard(Home,"◈  Sessione / Session","")
local function updateSession()
    local executor = "Unknown"
    pcall(function()
        if identifyexecutor then
            executor = tostring(select(1,identifyexecutor()))
        end
    end)
    InfoText.Text =
        "Gioco / Game: "..gameName..
        "\nGiocatori / Players: "..tostring(#Players:GetPlayers())..
        "\nExecutor: "..executor..
        "\nPlaceId: "..tostring(game.PlaceId)
end
updateSession()

Players.PlayerAdded:Connect(updateSession)
Players.PlayerRemoving:Connect(function() task.delay(.1,updateSession) end)

local YOUTUBE_URL = "https://www.youtube.com/@OfficialGattino"

button(Home,"▶  OfficialGattino • YouTube",function()
    local opened = false

    pcall(function()
        GuiService:OpenBrowserWindow(YOUTUBE_URL)
        opened = true
    end)

    if not opened and setclipboard then
        pcall(function()
            setclipboard(YOUTUBE_URL)
            toast("Link YouTube copiato / YouTube link copied ✦",C.Red)
        end)
    elseif not opened then
        toast("YouTube: @OfficialGattino",C.Red)
    end
end)

button(Home,"⟳  Rejoin / Rientra nel server",function()
    toast("Rejoining...",C.Blue)
    pcall(function()
        TeleportService:Teleport(game.PlaceId,LP)
    end)
end)

button(Home,"⨯  Chiudi Hub / Unload Hub",function()
    Gui:Destroy()
end)

infoCard(
    Home,
    "⌁  Compatibilità / Compatibility",
    "Alcuni giochi possono ripristinare velocità, salto o teletrasporto. "..
    "Silent Aim dipende dal sistema di tiro usato dal gioco."
)

--========================================================
-- CHEATS PAGE
--========================================================
heading(Cheats,"CHEATS","Touch Friendly • Italiano / English")

--========================================================
-- PLAYER / MOVEMENT
--========================================================
section(Cheats,"MOVIMENTO / MOVEMENT")

slider(Cheats,"Velocità / WalkSpeed",8,120,16,function(v)
    S.speed = v
    local h = humanoid()
    if h then h.WalkSpeed = v end
end)

slider(Cheats,"Salto super / Jump Power",25,220,50,function(v)
    S.jump = v
    local h = humanoid()
    if h then
        pcall(function() h.UseJumpPower = true end)
        h.JumpPower = v
    end
end)

slider(Cheats,"Gravità / Gravity",20,300,math.floor(workspace.Gravity+.5),function(v)
    S.gravity = v
    workspace.Gravity = v
end)

toggle(Cheats,"Salto infinito / Infinite Jump",false,function(on)
    S.infiniteJump = on
end)

UIS.JumpRequest:Connect(function()
    if S.infiniteJump then
        local h = humanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

toggle(Cheats,"Auto salto / Auto Jump",false,function(on)
    S.autoJump = on
end)

toggle(Cheats,"Noclip / Attraversa muri",false,function(on)
    S.noclip = on
end)

local collisionBackup = {}
RunService.Stepped:Connect(function()
    if not S.noclip then return end
    local c = LP.Character
    if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            if collisionBackup[p] == nil then collisionBackup[p] = p.CanCollide end
            p.CanCollide = false
        end
    end
end)

toggle(Cheats,"Invisibile locale / Local Invisible",false,function(on)
    S.localInvisible = on
    local c = LP.Character
    if not c then return end
    for _,d in ipairs(c:GetDescendants()) do
        if d:IsA("BasePart") then
            d.LocalTransparencyModifier = on and 1 or 0
        elseif d:IsA("Decal") then
            d.Transparency = on and 1 or 0
        end
    end
end)

-- Fly mobile buttons
local FlyPad = Instance.new("Frame")
FlyPad.Size = UDim2.fromOffset(60,130)
FlyPad.Position = UDim2.new(1,-78,.50,-65)
FlyPad.BackgroundTransparency = 1
FlyPad.Visible = false
FlyPad.ZIndex = 90
FlyPad.Parent = Gui

local function flyPadButton(text,y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(58,58)
    b.Position = UDim2.fromOffset(0,y)
    b.BackgroundColor3 = C.Panel2
    b.Text = text
    b.TextColor3 = C.White
    b.TextSize = 22
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.ZIndex = 91
    b.Parent = FlyPad
    corner(b,15)
    stroke(b,C.Purple,1.2,.08)
    return b
end

local FlyUp = flyPadButton("▲",0)
local FlyDown = flyPadButton("▼",70)

local function verticalHold(btn, dir)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            S.flyVertical = dir
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if S.flyVertical == dir then S.flyVertical = 0 end
        end
    end)
end
verticalHold(FlyUp,1)
verticalHold(FlyDown,-1)

toggle(Cheats,"Fly / Volo",false,function(on)
    S.fly = on
    FlyPad.Visible = on
    if on then
        toast("Fly: joystick + ▲ / ▼",C.Purple)
    else
        S.flyVertical = 0
    end
end)

slider(Cheats,"Velocità Fly / Fly Speed",10,150,55,function(v)
    S.flySpeed = v
end)

RunService.Heartbeat:Connect(function()
    local h = humanoid()
    local r = root()

    if h then
        if not S.fly then
            if math.abs(h.WalkSpeed - S.speed) > .1 then
                h.WalkSpeed = S.speed
            end
            pcall(function()
                h.UseJumpPower = true
                if math.abs(h.JumpPower - S.jump) > .1 then
                    h.JumpPower = S.jump
                end
            end)
        end

        if S.autoJump and h.MoveDirection.Magnitude > .08
        and h.FloorMaterial ~= Enum.Material.Air then
            h.Jump = true
        end
    end

    if S.fly and h and r then
        local vel = h.MoveDirection * S.flySpeed
        vel += Vector3.new(0,S.flyVertical*S.flySpeed,0)
        r.AssemblyLinearVelocity = vel
    end
end)

-- Air Walk
local AirPlatform = nil
toggle(Cheats,"Cammina nell'aria / Air Walk",false,function(on)
    S.airWalk = on
    if not on and AirPlatform then
        AirPlatform:Destroy()
        AirPlatform = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.airWalk then return end
    local r = root()
    if not r then return end

    if not AirPlatform or not AirPlatform.Parent then
        AirPlatform = Instance.new("Part")
        AirPlatform.Name = "UltraNovaAirWalk"
        AirPlatform.Size = Vector3.new(7,.5,7)
        AirPlatform.Anchored = true
        AirPlatform.CanCollide = true
        AirPlatform.Transparency = 1
        AirPlatform.Parent = workspace
    end

    AirPlatform.CFrame = CFrame.new(r.Position.X,r.Position.Y-3.15,r.Position.Z)
end)

toggle(Cheats,"Spin / Rotazione personaggio",false,function(on)
    S.spin = on
end)

slider(Cheats,"Velocità Spin / Spin Speed",1,30,8,function(v)
    S.spinSpeed = v
end)

RunService.Heartbeat:Connect(function(dt)
    if S.spin then
        local r = root()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0,math.rad(S.spinSpeed*60*dt),0)
        end
    end
end)


--========================================================
-- MOVEMENT+ v3.2
--========================================================
section(Cheats,"MOVEMENT+ / EXTRA")

slider(Cheats,"Forza Dash / Dash Power",30,160,82,function(v)
    S.dashPower = v
end)

local dashReady = true
button(Cheats,"Dash / Scatto",function()
    if not dashReady then
        toast("Dash cooldown...",C.Orange)
        return
    end
    local r = root()
    local h = humanoid()
    if not r or not h then return end
    dashReady = false
    local dir = h.MoveDirection
    if dir.Magnitude < .05 then dir = Camera.CFrame.LookVector end
    local flat = Vector3.new(dir.X,0,dir.Z)
    if flat.Magnitude < .01 then flat = Vector3.new(0,0,-1) end
    r.AssemblyLinearVelocity = flat.Unit*S.dashPower + Vector3.new(0,r.AssemblyLinearVelocity.Y,0)
    task.delay(.65,function() dashReady=true end)
end)

button(Cheats,"Preset gravità bassa / Low Gravity",function()
    S.gravity = 82
    workspace.Gravity = S.gravity
    toast("Low Gravity: 82",C.Cyan)
end)

button(Cheats,"Preset salto alto / High Jump",function()
    S.jump = 105
    local h = humanoid()
    if h then pcall(function() h.UseJumpPower=true end) h.JumpPower=S.jump end
    toast("Jump Power: 105",C.Cyan)
end)

local LastSafeCFrame = nil
local SafeStableTime = 0

toggle(Cheats,"Anti-Void / Salvataggio caduta",false,function(on)
    S.antiVoid = on
    if on and root() then LastSafeCFrame = root().CFrame end
end)

slider(Cheats,"Profondità Anti-Void / Anti-Void Depth",25,120,48,function(v)
    S.antiVoidDepth = v
end)

toggle(Cheats,"Blocca posizione / Freeze Position",false,function(on)
    S.freezePosition = on
    local r = root()
    if r then r.Anchored = on end
end)

toggle(Cheats,"Float / Galleggia",false,function(on)
    S.float = on
end)

local WaterWalkPart = nil
toggle(Cheats,"Cammina sull'acqua / Water Walk",false,function(on)
    S.waterWalk = on
    if not on and WaterWalkPart then WaterWalkPart:Destroy() WaterWalkPart=nil end
end)

local FlyPresetIndex = 2
local FlyPresets = {
    {"Slow",28},{"Normal",55},{"Fast",90},{"Insane",140}
}
button(Cheats,"Fly Preset: NORMAL",function(b)
    FlyPresetIndex = FlyPresetIndex%#FlyPresets+1
    local preset = FlyPresets[FlyPresetIndex]
    S.flySpeed = preset[2]
    b.Text = "Fly Preset: "..string.upper(preset[1])
    toast("Fly Speed: "..tostring(preset[2]),C.Purple)
end)

RunService.Heartbeat:Connect(function(dt)
    local h,r = humanoid(),root()
    if not h or not r then return end

    if h.FloorMaterial ~= Enum.Material.Air and not S.fly and not S.airWalk then
        SafeStableTime += dt
        if SafeStableTime > .18 then LastSafeCFrame = r.CFrame end
    else
        SafeStableTime = 0
    end

    if S.antiVoid and LastSafeCFrame and r.Position.Y < LastSafeCFrame.Position.Y-S.antiVoidDepth then
        r.AssemblyLinearVelocity = Vector3.zero
        r.CFrame = LastSafeCFrame*CFrame.new(0,3,0)
        toast("Anti-Void ✦",C.Cyan)
    end

    if S.freezePosition and not r.Anchored then r.Anchored=true end
    if not S.freezePosition and r.Anchored then r.Anchored=false end

    if S.float and not S.fly then
        local v = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(v.X,0,v.Z)
    end

    if S.waterWalk then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character()}
        params.IgnoreWater = false
        local hit = workspace:Raycast(r.Position,Vector3.new(0,-7,0),params)
        if hit and hit.Material == Enum.Material.Water then
            if not WaterWalkPart or not WaterWalkPart.Parent then
                WaterWalkPart = Instance.new("Part")
                WaterWalkPart.Name="UltraNovaWaterWalk"
                WaterWalkPart.Size=Vector3.new(7,.35,7)
                WaterWalkPart.Anchored=true
                WaterWalkPart.CanCollide=true
                WaterWalkPart.Transparency=1
                WaterWalkPart.Parent=workspace
            end
            WaterWalkPart.CFrame=CFrame.new(hit.Position+Vector3.new(0,.1,0))
        elseif WaterWalkPart then
            WaterWalkPart.CFrame=CFrame.new(0,-10000,0)
        end
    end
end)

--========================================================
-- TELEPORT
--========================================================
section(Cheats,"TELEPORT")

button(Cheats,"TP a giocatore / Teleport to Player",function()
    playerPicker("TP • Lista giocatori / Player List",false,function(p)
        if not p then return end
        local r = root()
        local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r and pr then
            r.CFrame = pr.CFrame * CFrame.new(0,0,3)
            toast("TP → @"..p.Name,C.Blue)
        end
    end)
end)

local SavedCF = nil
button(Cheats,"Salva posizione / Save Position",function()
    local r = root()
    if r then
        SavedCF = r.CFrame
        toast("Posizione salvata / Position saved",C.Green)
    end
end)

button(Cheats,"Torna alla posizione / Return to Saved",function()
    local r = root()
    if r and SavedCF then
        r.CFrame = SavedCF
    else
        toast("Nessuna posizione salvata / No saved position",C.Orange)
    end
end)

toggle(Cheats,"Tieni premuto per TP / Hold to Click TP",false,function(on)
    S.clickTP = on
    if on then
        toast("Tieni premuto ~0.45s nel mondo / Hold ~0.45s",C.Cyan)
    end
end)

do
    local activeInput = nil
    local started = nil
    local pos = nil

    UIS.InputBegan:Connect(function(input,gp)
        if gp or not S.clickTP then return end
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            activeInput = input
            started = os.clock()
            pos = input.Position
        end
    end)

    UIS.InputEnded:Connect(function(input,gp)
        if input ~= activeInput or not started or not S.clickTP then return end
        local held = os.clock() - started
        local endPos = input.Position
        activeInput = nil

        if held < .45 then return end
        if (Vector2.new(endPos.X,endPos.Y)-Vector2.new(pos.X,pos.Y)).Magnitude > 45 then return end

        if Main.Visible then
            local ap = Main.AbsolutePosition
            local as = Main.AbsoluteSize
            if endPos.X >= ap.X and endPos.X <= ap.X+as.X
            and endPos.Y >= ap.Y and endPos.Y <= ap.Y+as.Y then
                return
            end
        end

        local ray = Camera:ViewportPointToRay(endPos.X,endPos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character()}

        local hit = workspace:Raycast(ray.Origin,ray.Direction*1800,params)
        local r = root()
        if hit and r then
            r.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
        end
    end)
end

--========================================================
-- ESP
--========================================================
section(Cheats,"ESP / VISUAL PLAYERS")

local EspFolder = Instance.new("Folder")
EspFolder.Name = "UltraNovaESP"
EspFolder.Parent = Gui

local EspObjects = {}

local function removeEsp(p)
    local o = EspObjects[p]
    if not o then return end
    pcall(function() o.HL:Destroy() end)
    pcall(function() o.BB:Destroy() end)
    EspObjects[p] = nil
end

local function clearEsp()
    for p in pairs(EspObjects) do
        removeEsp(p)
    end
end

local function shouldEsp(p)
    if not S.esp or p == LP then return false end
    if S.espTarget and p ~= S.espTarget then return false end
    return true
end

local function makeEsp(p)
    if not shouldEsp(p) then return end
    local c = p.Character
    if not c then return end

    local existing = EspObjects[p]
    if existing and existing.Char == c then return existing end
    if existing then removeEsp(p) end

    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = .84
    hl.OutlineTransparency = .06
    hl.FillColor = S.espColor
    hl.OutlineColor = S.espColor
    hl.Adornee = c
    hl.Parent = EspFolder

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(220,50)
    bb.StudsOffset = Vector3.new(0,3.25,0)
    bb.AlwaysOnTop = true
    bb.Adornee = c:FindFirstChild("Head") or c:FindFirstChild("HumanoidRootPart")
    bb.Parent = EspFolder

    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.fromScale(1,1)
    tx.BackgroundTransparency = 1
    tx.Text = ""
    tx.TextColor3 = S.espColor
    tx.TextStrokeTransparency = .42
    tx.TextSize = 12
    tx.Font = Enum.Font.GothamBold
    tx.Parent = bb

    local obj = {HL=hl,BB=bb,TX=tx,Char=c}
    EspObjects[p] = obj
    return obj
end

local function refreshEsp()
    if not S.esp then
        clearEsp()
        return
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if shouldEsp(p) then
            makeEsp(p)
        else
            removeEsp(p)
        end
    end
end

toggle(Cheats,"ESP giocatori / Player ESP",false,function(on)
    S.esp = on
    refreshEsp()
end)

local EspTargetButton
EspTargetButton = select(1,button(Cheats,"Target ESP: Tutti / Everyone",function()
    playerPicker("ESP Target",true,function(p)
        S.espTarget = p
        EspTargetButton.Text = "Target ESP: "..(p and ("@"..p.Name) or "Tutti / Everyone")
        refreshEsp()
    end)
end))

button(Cheats,"Colore ESP / ESP Color",function(b)
    S.espColorIndex = (S.espColorIndex % #ESP_PALETTE) + 1
    S.espColor = ESP_PALETTE[S.espColorIndex]
    b.TextColor3 = S.espColor
    refreshEsp()
end)

toggle(Cheats,"Nome utente ESP / Show Username",true,function(on)
    S.espName = on
end)

toggle(Cheats,"Distanza ESP / Show Distance",true,function(on)
    S.espDistance = on
end)

task.spawn(function()
    while Gui.Parent do
        if S.esp then
            refreshEsp()
            local myRoot = root()

            for p,o in pairs(EspObjects) do
                if p.Parent and o and o.Char and o.Char.Parent then
                    o.HL.FillColor = S.espColor
                    o.HL.OutlineColor = S.espColor
                    o.TX.TextColor3 = S.espColor

                    local lines = {}
                    if S.espName then
                        table.insert(lines,p.DisplayName.."  @"..p.Name)
                    end

                    if S.espDistance then
                        local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        if myRoot and pr then
                            table.insert(lines,string.format("%.0f studs",(pr.Position-myRoot.Position).Magnitude))
                        end
                    end

                    o.TX.Text = table.concat(lines,"\n")
                end
            end
        end
        task.wait(.18)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeEsp(p)
    if S.espTarget == p then S.espTarget = nil end
    if S.aimTarget == p then S.aimTarget = nil end
end)

--========================================================
-- AIM / CROSSHAIR
--========================================================
section(Cheats,"AIM / CROSSHAIR")

local AimOverlay = Instance.new("ScreenGui")
AimOverlay.Name = "UltraNovaAimOverlay"
AimOverlay.IgnoreGuiInset = true
AimOverlay.ResetOnSpawn = false
AimOverlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AimOverlay.Parent = GuiParent

local Cross = Instance.new("Frame")
Cross.Size = UDim2.fromOffset(70,70)
Cross.Position = UDim2.fromScale(.5,.5)
Cross.AnchorPoint = Vector2.new(.5,.5)
Cross.BackgroundTransparency = 1
Cross.Visible = false
Cross.ZIndex = 50
Cross.Parent = AimOverlay

local CrossH = Instance.new("Frame")
CrossH.AnchorPoint = Vector2.new(.5,.5)
CrossH.Position = UDim2.fromScale(.5,.5)
CrossH.Size = UDim2.fromOffset(S.crosshairSize,2)
CrossH.BackgroundColor3 = C.White
CrossH.ZIndex = 51
CrossH.Parent = Cross
corner(CrossH,2)

local CrossV = Instance.new("Frame")
CrossV.AnchorPoint = Vector2.new(.5,.5)
CrossV.Position = UDim2.fromScale(.5,.5)
CrossV.Size = UDim2.fromOffset(2,S.crosshairSize)
CrossV.BackgroundColor3 = C.White
CrossV.ZIndex = 51
CrossV.Parent = Cross
corner(CrossV,2)

local CrossDot = Instance.new("Frame")
CrossDot.AnchorPoint = Vector2.new(.5,.5)
CrossDot.Position = UDim2.fromScale(.5,.5)
CrossDot.Size = UDim2.fromOffset(5,5)
CrossDot.BackgroundColor3 = C.Purple
CrossDot.ZIndex = 52
CrossDot.Parent = Cross
corner(CrossDot,5)

local FovCircle = Instance.new("Frame")
FovCircle.AnchorPoint = Vector2.new(.5,.5)
FovCircle.Position = UDim2.fromScale(.5,.5)
FovCircle.Size = UDim2.fromOffset(S.aimFov*2,S.aimFov*2)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
FovCircle.ZIndex = 45
FovCircle.Parent = AimOverlay
corner(FovCircle,999)
local FovStroke = stroke(FovCircle,C.Purple,1.2,.28)

toggle(Cheats,"Crosshair / Mirino",false,function(on)
    S.crosshair = on
    Cross.Visible = on
end)

toggle(Cheats,"Ruota crosshair / Spin Crosshair",false,function(on)
    S.crosshairSpin = on
end)

slider(Cheats,"Dimensione crosshair / Crosshair Size",10,90,30,function(v)
    S.crosshairSize = v
    CrossH.Size = UDim2.fromOffset(v,S.crosshairThickness or 2)
    CrossV.Size = UDim2.fromOffset(S.crosshairThickness or 2,v)
end)

local function isSameTeam(p)
    if not S.aimTeamCheck then return false end
    if LP.Team == nil or p.Team == nil then return false end
    return LP.Team == p.Team
end

local function visibleTarget(part, p)
    if not S.aimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position-origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character()}

    local result = workspace:Raycast(origin,direction,params)
    if not result then return true end
    return result.Instance and result.Instance:IsDescendantOf(p.Character)
end

local function validAimPart(p)
    if not p or p == LP or not p.Character then return nil end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return nil end
    if isSameTeam(p) then return nil end

    local part = p.Character:FindFirstChild(S.aimPart)
        or p.Character:FindFirstChild("Head")
        or p.Character:FindFirstChild("HumanoidRootPart")

    if not part then return nil end
    if not visibleTarget(part,p) then return nil end
    return part
end

local function getAimTarget()
    Camera = workspace.CurrentCamera or Camera
    local center = Camera.ViewportSize/2

    -- specific selected player
    if S.aimTarget then
        local part = validAimPart(S.aimTarget)
        if part then
            local pos,onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                if dist <= S.aimFov then
                    return part,S.aimTarget
                end
            end
        end
        return nil,nil
    end

    -- automatic nearest on screen
    local bestPart,bestPlayer,bestDist = nil,nil,S.aimFov

    for _,p in ipairs(Players:GetPlayers()) do
        local part = validAimPart(p)
        if part then
            local pos,onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and pos.Z > 0 then
                local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = part
                    bestPlayer = p
                end
            end
        end
    end

    return bestPart,bestPlayer
end

toggle(Cheats,"Aimbot morbido / Smooth Aim Assist",false,function(on)
    S.aimbot = on
    FovCircle.Visible = on or S.silentAim
end)

local AimTargetButton
AimTargetButton = select(1,button(Cheats,"Aim Target: Automatico / Auto",function()
    playerPicker("Aim Target",true,function(p)
        S.aimTarget = p
        AimTargetButton.Text = "Aim Target: "..(p and ("@"..p.Name) or "Automatico / Auto")
    end)
end))

slider(Cheats,"FOV Aimbot / Aim FOV",40,400,180,function(v)
    S.aimFov = v
    FovCircle.Size = UDim2.fromOffset(v*2,v*2)
end)

slider(Cheats,"Morbidezza mira / Aim Smoothness",1,25,8,function(v)
    S.aimSmooth = v
end)

toggle(Cheats,"Wall Check / Controllo muri",true,function(on)
    S.aimWallCheck = on
end)

toggle(Cheats,"Team Check / Ignora compagni",false,function(on)
    S.aimTeamCheck = on
end)

button(Cheats,"Target Part: Head / Testa",function(b)
    S.aimPart = (S.aimPart == "Head") and "HumanoidRootPart" or "Head"
    b.Text = "Target Part: "..((S.aimPart=="Head") and "Head / Testa" or "Body / Corpo")
end)

RunService.RenderStepped:Connect(function(dt)
    Camera = workspace.CurrentCamera or Camera

    if S.crosshairSpin then
        Cross.Rotation = (Cross.Rotation + dt*100) % 360
    else
        Cross.Rotation = 0
    end

    FovCircle.Position = UDim2.fromScale(.5,.5)
    FovCircle.Size = UDim2.fromOffset(S.aimFov*2,S.aimFov*2)
    FovCircle.Visible = S.aimbot or S.silentAim

    if S.aimbot then
        local target = getAimTarget()
        if target then
            local goal = CFrame.new(Camera.CFrame.Position,target.Position)
            local alpha = math.clamp(dt*(28/math.max(1,S.aimSmooth)),0,1)
            Camera.CFrame = Camera.CFrame:Lerp(goal,alpha)
        end
    end
end)

-- Generic Silent Aim: Workspace:Raycast only.
local SilentInstalled = false
local OldNamecall = nil

local function installSilentAim()
    if SilentInstalled then return true end
    if not hookmetamethod or not getnamecallmethod or not newcclosure then
        return false
    end

    local ok = pcall(function()
        OldNamecall = hookmetamethod(game,"__namecall",newcclosure(function(self,...)
            local args = {...}
            local method = getnamecallmethod()

            if S.silentAim
            and method == "Raycast"
            and self == workspace
            and typeof(args[1]) == "Vector3"
            and typeof(args[2]) == "Vector3"
            and (not checkcaller or not checkcaller()) then

                local target = getAimTarget()
                if target then
                    local origin = args[1]
                    local oldDirection = args[2]
                    local mag = oldDirection.Magnitude
                    if mag > 0 then
                        args[2] = (target.Position-origin).Unit * mag
                        return OldNamecall(self,unpackArgs(args))
                    end
                end
            end

            return OldNamecall(self,...)
        end))
    end)

    SilentInstalled = ok
    return ok
end

local SilentToggle
SilentToggle = toggle(Cheats,"Silent Aim generico / Generic Silent Aim",false,function(on)
    if on then
        if not installSilentAim() then
            S.silentAim = false
            task.defer(function()
                if SilentToggle then SilentToggle.Set(false) end
            end)
            toast("Silent Aim non supportato da questo executor / unsupported",C.Red)
            return
        end
        S.silentAim = true
        FovCircle.Visible = true
        toast("Silent Aim: Raycast mode",C.Purple)
    else
        S.silentAim = false
        FovCircle.Visible = S.aimbot
    end
end)

--========================================================
-- WORLD / VISUALS
--========================================================
section(Cheats,"MONDO / VISUALS")

toggle(Cheats,"Fullbright / Luce completa",false,function(on)
    S.fullbright = on
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
    else
        Lighting.Brightness = original.Brightness
        Lighting.ClockTime = original.ClockTime
        Lighting.GlobalShadows = original.GlobalShadows
    end
end)

toggle(Cheats,"No Fog / Rimuovi nebbia",false,function(on)
    S.noFog = on
    Lighting.FogEnd = on and 1000000 or original.FogEnd
end)

slider(Cheats,"Camera FOV / Campo visivo",50,120,math.floor(Camera.FieldOfView+.5),function(v)
    S.fov = v
    Camera.FieldOfView = v
end)

local XrayBackup = {}
toggle(Cheats,"X-Ray mondo / World X-Ray",false,function(on)
    S.xray = on

    if on then
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart")
            and not p:IsDescendantOf(character())
            and not Players:GetPlayerFromCharacter(p.Parent) then
                if XrayBackup[p] == nil then
                    XrayBackup[p] = p.LocalTransparencyModifier
                end
                p.LocalTransparencyModifier = math.max(p.LocalTransparencyModifier,.62)
            end
        end
    else
        for p,val in pairs(XrayBackup) do
            if p and p.Parent then
                pcall(function() p.LocalTransparencyModifier = val end)
            end
        end
        XrayBackup = {}
    end
end)

button(Cheats,"FPS Boost leggero / Light FPS Boost",function()
    pcall(function()
        Lighting.GlobalShadows = false
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ParticleEmitter")
            or d:IsA("Trail")
            or d:IsA("Smoke")
            or d:IsA("Fire")
            or d:IsA("Sparkles") then
                d.Enabled = false
            end
        end
    end)
    toast("FPS Boost applicato / applied",C.Green)
end)

--========================================================
-- UTILITY
--========================================================
section(Cheats,"UTILITY")

toggle(Cheats,"Anti AFK / Anti Idle",false,function(on)
    S.antiAfk = on
end)

LP.Idled:Connect(function()
    if S.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    end
end)

button(Cheats,"Reset personaggio / Reset Character",function()
    local h = humanoid()
    if h then h.Health = 0 end
end)

button(Cheats,"Rejoin / Rientra nel server",function()
    toast("Rejoining...",C.Blue)
    pcall(function()
        TeleportService:Teleport(game.PlaceId,LP)
    end)
end)

button(Cheats,"Copia JobId / Copy Server JobId",function()
    if setclipboard then
        pcall(function()
            setclipboard(game.JobId)
            toast("JobId copiato / copied",C.Cyan)
        end)
    else
        toast(game.JobId,C.Cyan)
    end
end)

infoCard(
    Cheats,
    "✦ UltraNova",
    "Nessuna key. La lista giocatori viene aggiornata dal server corrente. "..
    "UltraNova è ottimizzata per touch, telefono e tablet."
)


--========================================================
-- EMOTES
--========================================================
heading(Emotes,"EMOTES","10 dance mixes • Musica / Music")

local EmoteMusicEnabled = true
local EmoteVolume = .45
local CurrentDanceTrack = nil
local DanceToken = 0
local DanceSpeedMultiplier = 1
local DanceLoop = true
local DanceShuffle = false
local DancePlaylist = false
local DanceAutomationToken = 0
local NowPlayingDance = "None"

local DanceSound = Instance.new("Sound")
DanceSound.Name = "UltraNovaDanceMusic"
DanceSound.Volume = EmoteVolume
DanceSound.Looped = true
DanceSound.Parent = SoundService

-- Each preset mixes multiple clips instead of looping one move forever.
local DANCES = {
    {
        Name="Nova Groove", Music=1838673350, MusicSpeed=1,
        Clips={
            {R15=507771019,R6=182435998,Speed=1.02,Duration=4},
            {R15=507771955,R6=182491037,Speed=1.08,Duration=4}
        }
    },
    {
        Name="Cosmic Shuffle", Music=1837393392, MusicSpeed=1.03,
        Clips={
            {R15=507772104,R6=182491065,Speed=1.08,Duration=3.8},
            {R15=507776043,R6=182436842,Speed=1.16,Duration=3.8},
            {R15=507771955,R6=182491037,Speed=1.10,Duration=3.5}
        }
    },
    {
        Name="Zero-G Bounce", Music=1847000084, MusicSpeed=.96,
        Clips={
            {R15=507776720,R6=182491248,Speed=.96,Duration=4.2},
            {R15=507776879,R6=182491277,Speed=1.04,Duration=4.2}
        }
    },
    {
        Name="Purple Pulse", Music=1846869595, MusicSpeed=1.05,
        Clips={
            {R15=507777268,R6=182436935,Speed=1.14,Duration=3.6},
            {R15=507777451,R6=182491368,Speed=1.08,Duration=3.7}
        }
    },
    {
        Name="Orbit Funk", Music=1839256190, MusicSpeed=1,
        Clips={
            {R15=507777623,R6=182491423,Speed=1.08,Duration=3.8},
            {R15=507770677,R6=129423030,Speed=1.04,Duration=4}
        }
    },
    {
        Name="Nebula Mix", Music=1845554017, MusicSpeed=1.05,
        Clips={
            {R15=507771955,R6=182491037,Speed=1.08,Duration=3.3},
            {R15=507776720,R6=182491248,Speed=1.05,Duration=3.3},
            {R15=507777268,R6=182436935,Speed=1.15,Duration=3.3}
        }
    },
    {
        Name="Galaxy Rush", Music=1842976958, MusicSpeed=1.08,
        Clips={
            {R15=507776043,R6=182436842,Speed=1.20,Duration=3.2},
            {R15=507776879,R6=182491277,Speed=1.16,Duration=3.2},
            {R15=507777623,R6=182491423,Speed=1.22,Duration=3.2}
        }
    },
    {
        Name="Smooth Nova", Music=1838117725, MusicSpeed=.95,
        Clips={
            {R15=507771019,R6=182435998,Speed=.90,Duration=4.6},
            {R15=507777451,R6=182491368,Speed=.94,Duration=4.6}
        }
    },
    {
        Name="Glitch Step", Music=1840963785, MusicSpeed=1.10,
        Clips={
            {R15=507772104,R6=182491065,Speed=1.22,Duration=3},
            {R15=507777623,R6=182491423,Speed=1.28,Duration=3},
            {R15=507776720,R6=182491248,Speed=1.18,Duration=3}
        }
    },
    {
        Name="SUPERNOVA RAVE", Music=1846368080, MusicSpeed=1.10,
        Clips={
            {R15=507770677,R6=129423030,Speed=1.18,Duration=3.1},
            {R15=507777268,R6=182436935,Speed=1.24,Duration=3.1},
            {R15=507776879,R6=182491277,Speed=1.20,Duration=3.1},
            {R15=507777623,R6=182491423,Speed=1.25,Duration=3.1}
        }
    }
}

local function stopDance()
    DanceToken += 1
    if CurrentDanceTrack then
        pcall(function()
            CurrentDanceTrack:Stop(.18)
            CurrentDanceTrack:Destroy()
        end)
        CurrentDanceTrack = nil
    end
    pcall(function() DanceSound:Stop() end)
    NowPlayingDance = "None"
    S.activeDance = "None"
end

local function loadDanceClip(data)
    local h = humanoid()
    if not h then return nil end
    local animator = h:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = h
    end
    local animation = Instance.new("Animation")
    local isR15 = h.RigType == Enum.HumanoidRigType.R15
    animation.AnimationId = "rbxassetid://"..tostring(isR15 and data.R15 or data.R6)
    local ok,track = pcall(function() return animator:LoadAnimation(animation) end)
    animation:Destroy()
    if not ok then return nil end
    return track
end

local function playDancePreset(preset)
    stopDance()
    if not humanoid() then
        toast("Personaggio non pronto / Character not ready",C.Red)
        return
    end

    DanceToken += 1
    local myToken = DanceToken

    if EmoteMusicEnabled then
        DanceSound.SoundId = "rbxassetid://"..tostring(preset.Music)
        DanceSound.Volume = EmoteVolume
        DanceSound.PlaybackSpeed = preset.MusicSpeed or 1
        pcall(function() DanceSound:Play() end)
    end

    task.spawn(function()
        while Gui.Parent and DanceToken == myToken do
            for _,clip in ipairs(preset.Clips) do
                if DanceToken ~= myToken then return end
                local track = loadDanceClip(clip)
                if track then
                    CurrentDanceTrack = track
                    track.Priority = Enum.AnimationPriority.Action
                    track.Looped = true
                    track:Play(.22,1,(clip.Speed or 1)*DanceSpeedMultiplier)
                    local started = os.clock()
                    local duration = clip.Duration or 4
                    while DanceToken == myToken and os.clock()-started < duration do
                        task.wait(.08)
                    end
                    pcall(function()
                        track:Stop(.22)
                        track:Destroy()
                    end)
                    if CurrentDanceTrack == track then CurrentDanceTrack = nil end
                end
            end
            if not DanceLoop then break end
        end
    end)

    NowPlayingDance = preset.Name
    S.activeDance = preset.Name
    toast(preset.Name.." ✦",C.Purple)
end

toggle(Emotes,"Musica / Music",true,function(on)
    EmoteMusicEnabled = on
    if not on then DanceSound:Stop() end
end)

slider(Emotes,"Volume musica / Music Volume",0,100,45,function(v)
    EmoteVolume = v/100
    DanceSound.Volume = EmoteVolume
end)

local SharedAudioToggle
SharedAudioToggle = toggle(Emotes,"Altri sentono musica / Others Hear Music",false,function(on)
    if on then
        task.defer(function()
            if SharedAudioToggle then SharedAudioToggle.Set(false) end
        end)
        toast("Serve il supporto audio del server / Game server support required",C.Orange)
    end
end)

button(Emotes,"■  Ferma ballo / Stop Dance",function() stopDance() end)
section(Emotes,"BALLI / DANCES")

for index,preset in ipairs(DANCES) do
    button(Emotes,string.format("%02d  ✦  %s",index,preset.Name),function()
        playDancePreset(preset)
    end)
end


section(Emotes,"EMOTES+ / DANCE CONTROL")

slider(Emotes,"Velocità ballo / Dance Speed",50,160,100,function(v)
    DanceSpeedMultiplier = v/100
    if CurrentDanceTrack then pcall(function() CurrentDanceTrack:AdjustSpeed(DanceSpeedMultiplier) end) end
end)

toggle(Emotes,"Loop ballo / Dance Loop",true,function(on)
    DanceLoop = on
end)

local NowPlayingCard,NowPlayingText = infoCard(Emotes,"♫ Now Playing","Dance: None")

task.spawn(function()
    while Gui.Parent do
        NowPlayingText.Text = "Dance: "..tostring(NowPlayingDance).."\nMusic: "..(EmoteMusicEnabled and "ON" or "OFF").." • Volume "..math.floor(EmoteVolume*100).."%"
        task.wait(.35)
    end
end)

button(Emotes,"⤨  Ballo casuale / Random Dance",function()
    local pick = DANCES[math.random(1,#DANCES)]
    playDancePreset(pick)
end)

toggle(Emotes,"Shuffle automatico / Auto Shuffle",false,function(on)
    DanceShuffle = on
    DanceAutomationToken += 1
    local token = DanceAutomationToken
    if on then
        DancePlaylist = false
        task.spawn(function()
            while Gui.Parent and DanceShuffle and token==DanceAutomationToken do
                playDancePreset(DANCES[math.random(1,#DANCES)])
                task.wait(12)
            end
        end)
    end
end)

toggle(Emotes,"Playlist 1→10 / Dance Playlist",false,function(on)
    DancePlaylist = on
    DanceAutomationToken += 1
    local token = DanceAutomationToken
    if on then
        DanceShuffle = false
        task.spawn(function()
            local i=1
            while Gui.Parent and DancePlaylist and token==DanceAutomationToken do
                playDancePreset(DANCES[i])
                i=i%#DANCES+1
                task.wait(12)
            end
        end)
    end
end)

infoCard(
    Emotes,
    "♫ UltraNova Dance Engine",
    "Ogni preset combina più movimenti con transizioni smooth. La musica può essere disattivata o regolata separatamente."
)

--========================================================
-- SHADERS
--========================================================
heading(Shaders,"SHADERS","14 presets • Mobile / High / Ultra")

local ShaderObjects = {}
local ShaderQuality = "Mobile"
local QualityOrder = {"Mobile","High","Ultra"}
local QualityIndex = 1
local CurrentShaderPreset = nil

local function qualityRank()
    if ShaderQuality == "Ultra" then return 3 end
    if ShaderQuality == "High" then return 2 end
    return 1
end

local function qualityValue(mobile,high,ultra)
    local rank = qualityRank()
    if rank == 3 then return ultra end
    if rank == 2 then return high end
    return mobile
end

local function trackShaderObject(obj)
    table.insert(ShaderObjects,obj)
    return obj
end

local ShaderWorldFolder = Instance.new("Folder")
ShaderWorldFolder.Name = "UltraNovaWorldFX"
ShaderWorldFolder.Parent = workspace

local MaterialBackup = {}
local TransparencyBackup = {}

local function clearShaderObjects()
    for _,obj in ipairs(ShaderObjects) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    ShaderObjects = {}
end

local function clearWorldShader()
    if ShaderWorldFolder and ShaderWorldFolder.Parent then ShaderWorldFolder:ClearAllChildren() end
    for part,data in pairs(MaterialBackup) do
        if part and part.Parent then
            pcall(function()
                part.Material = data.Material
                part.Color = data.Color
                part.Reflectance = data.Reflectance
            end)
        end
    end
    MaterialBackup = {}
    for part,val in pairs(TransparencyBackup) do
        if part and part.Parent then pcall(function() part.LocalTransparencyModifier = val end) end
    end
    TransparencyBackup = {}
end

local function resetShader()
    clearShaderObjects()
    clearWorldShader()
    Lighting.Brightness = original.Brightness
    Lighting.ClockTime = original.ClockTime
    Lighting.FogEnd = original.FogEnd
    Lighting.GlobalShadows = original.GlobalShadows
    Lighting.Ambient = original.Ambient
    Lighting.OutdoorAmbient = original.OutdoorAmbient
    Lighting.ExposureCompensation = original.ExposureCompensation
    Lighting.ColorShift_Top = original.ColorShiftTop
    Lighting.ColorShift_Bottom = original.ColorShiftBottom
    Lighting.EnvironmentDiffuseScale = original.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = original.EnvironmentSpecularScale
end

local function addColor(tint,brightness,contrast,saturation)
    local e = Instance.new("ColorCorrectionEffect")
    e.Name = "UltraNovaColor"
    e.TintColor = tint or Color3.new(1,1,1)
    e.Brightness = brightness or 0
    e.Contrast = contrast or 0
    e.Saturation = saturation or 0
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function addBloom(intensity,size,threshold)
    local e = Instance.new("BloomEffect")
    e.Name = "UltraNovaBloom"
    e.Intensity = intensity or .2
    e.Size = size or 28
    e.Threshold = threshold or 1.2
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function addSun(intensity,spread)
    local e = Instance.new("SunRaysEffect")
    e.Name = "UltraNovaSun"
    e.Intensity = intensity or .05
    e.Spread = spread or .8
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function addDOF(farIntensity,focusDistance,inFocusRadius,nearIntensity)
    if qualityRank() < 2 then return nil end
    local e = Instance.new("DepthOfFieldEffect")
    e.Name = "UltraNovaDOF"
    e.FarIntensity = farIntensity or .04
    e.FocusDistance = focusDistance or 40
    e.InFocusRadius = inFocusRadius or 55
    e.NearIntensity = nearIntensity or 0
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function addBlur(size)
    if qualityRank() < 3 then return nil end
    local e = Instance.new("BlurEffect")
    e.Name = "UltraNovaBlur"
    e.Size = size or 1
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function addAtmosphere(color,decay,density,haze,glare)
    local e = Instance.new("Atmosphere")
    e.Name = "UltraNovaAtmosphere"
    e.Color = color or Color3.fromRGB(190,200,255)
    e.Decay = decay or Color3.fromRGB(95,75,150)
    e.Density = density or .2
    e.Haze = haze or .5
    e.Glare = glare or 0
    e.Parent = Lighting
    return trackShaderObject(e)
end

local function backupMaterial(part)
    if not MaterialBackup[part] then
        MaterialBackup[part] = {Material=part.Material,Color=part.Color,Reflectance=part.Reflectance}
    end
end

local function polishWorld(mode)
    local limit = qualityValue(0,260,650)
    if limit <= 0 then return end
    local count = 0
    for _,part in ipairs(workspace:GetDescendants()) do
        if count >= limit then break end
        if part:IsA("BasePart")
        and not part:IsDescendantOf(character())
        and not Players:GetPlayerFromCharacter(part.Parent) then
            backupMaterial(part)
            if mode == "Realistic" then
                if part.Material == Enum.Material.Plastic then part.Material = Enum.Material.SmoothPlastic end
                part.Reflectance = math.clamp(part.Reflectance+.025,0,.18)
            elseif mode == "Neon" then
                if part.Material == Enum.Material.Plastic then part.Material = Enum.Material.SmoothPlastic end
                part.Reflectance = math.clamp(part.Reflectance+.08,0,.25)
            elseif mode == "Cartoon" then
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
            end
            count += 1
            if count%120 == 0 then task.wait() end
        end
    end
end

local function outlineWorld(color)
    local limit = qualityValue(110,320,650)
    local count = 0
    for _,part in ipairs(workspace:GetDescendants()) do
        if count >= limit then break end
        if part:IsA("BasePart")
        and not part:IsDescendantOf(character())
        and not Players:GetPlayerFromCharacter(part.Parent) then
            local box = Instance.new("SelectionBox")
            box.Name = "UltraNovaOutline"
            box.Adornee = part
            box.Color3 = color or C.White
            box.LineThickness = qualityValue(.014,.018,.022)
            box.SurfaceTransparency = 1
            box.Parent = ShaderWorldFolder
            count += 1
            if count%120 == 0 then task.wait() end
        end
    end
end

local ShaderPresets = {
    {
        Name="Ultra Realistic",
        Apply=function()
            Lighting.Brightness = qualityValue(2.0,2.15,2.25)
            Lighting.GlobalShadows = true
            Lighting.ExposureCompensation = qualityValue(.02,.07,.11)
            Lighting.EnvironmentDiffuseScale = qualityValue(.65,.78,.86)
            Lighting.EnvironmentSpecularScale = qualityValue(.70,.90,1)
            addColor(Color3.fromRGB(255,248,241),.01,qualityValue(.08,.12,.15),qualityValue(.03,.06,.08))
            addBloom(qualityValue(.13,.19,.24),qualityValue(22,28,34),1.35)
            addSun(qualityValue(.035,.055,.075),.82)
            addAtmosphere(Color3.fromRGB(205,216,232),Color3.fromRGB(110,120,145),qualityValue(.08,.12,.15),qualityValue(.25,.48,.70),.02)
            addDOF(qualityValue(0,.025,.045),48,qualityValue(80,65,55),0)
            polishWorld("Realistic")
        end
    },
    {
        Name="RoShade Style",
        Apply=function()
            Lighting.Brightness = 2.05
            Lighting.GlobalShadows = true
            Lighting.ExposureCompensation = .06
            Lighting.EnvironmentSpecularScale = qualityValue(.72,.92,1)
            addColor(Color3.fromRGB(255,241,233),.015,qualityValue(.13,.18,.23),qualityValue(.08,.13,.17))
            addBloom(qualityValue(.18,.28,.38),qualityValue(24,32,38),qualityValue(1.3,1.15,1))
            addSun(qualityValue(.045,.075,.105),.86)
            addAtmosphere(Color3.fromRGB(220,211,202),Color3.fromRGB(112,101,117),qualityValue(.09,.14,.18),qualityValue(.25,.55,.85),qualityValue(0,.03,.07))
            addDOF(.05,42,qualityValue(70,60,48),.005)
            polishWorld("Realistic")
        end
    },
    {
        Name="Cinematic",
        Apply=function()
            Lighting.Brightness = 1.85
            Lighting.ExposureCompensation = -.02
            Lighting.GlobalShadows = true
            addColor(Color3.fromRGB(239,231,226),-.015,qualityValue(.12,.19,.25),-.06)
            addBloom(qualityValue(.09,.14,.19),30,1.45)
            addDOF(qualityValue(0,.08,.15),32,qualityValue(90,42,30),qualityValue(0,.015,.035))
            addAtmosphere(Color3.fromRGB(205,201,195),Color3.fromRGB(90,85,92),.09,qualityValue(.15,.38,.52),0)
        end
    },
    {
        Name="Golden Rays",
        Apply=function()
            Lighting.ClockTime = 17.25
            Lighting.Brightness = 2.1
            addColor(Color3.fromRGB(255,210,164),.025,.11,.13)
            addSun(qualityValue(.08,.12,.16),.9)
            addBloom(qualityValue(.20,.30,.40),30,1.05)
            addAtmosphere(Color3.fromRGB(255,193,139),Color3.fromRGB(123,74,81),qualityValue(.12,.18,.23),qualityValue(.55,1,1.35),qualityValue(.05,.13,.20))
            addDOF(.04,45,70,0)
        end
    },
    {
        Name="RTX-ish Night",
        Apply=function()
            Lighting.ClockTime = 21.1
            Lighting.Brightness = qualityValue(1.15,1.30,1.45)
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(24,29,48)
            Lighting.OutdoorAmbient = Color3.fromRGB(17,23,43)
            Lighting.EnvironmentSpecularScale = qualityValue(.75,.95,1)
            addColor(Color3.fromRGB(193,211,255),-.025,.21,.13)
            addBloom(qualityValue(.25,.40,.58),qualityValue(28,36,44),.88)
            addAtmosphere(Color3.fromRGB(88,108,160),Color3.fromRGB(18,24,53),qualityValue(.15,.23,.30),qualityValue(.45,1,1.55),.04)
            addDOF(.045,38,58,0)
            polishWorld("Realistic")
        end
    },
    {
        Name="Deep Space",
        Apply=function()
            Lighting.ClockTime = .05
            Lighting.Brightness = .92
            Lighting.Ambient = Color3.fromRGB(28,16,61)
            Lighting.OutdoorAmbient = Color3.fromRGB(13,19,46)
            addColor(Color3.fromRGB(194,172,255),-.025,.25,.24)
            addBloom(qualityValue(.35,.55,.75),40,.82)
            addAtmosphere(Color3.fromRGB(82,61,147),Color3.fromRGB(14,8,40),qualityValue(.22,.31,.39),qualityValue(1,1.8,2.5),qualityValue(.03,.10,.18))
            addDOF(.05,40,55,0)
        end
    },
    {
        Name="Cyber Purple",
        Apply=function()
            Lighting.ClockTime = 20.2
            Lighting.Brightness = 1.6
            Lighting.Ambient = Color3.fromRGB(56,25,95)
            Lighting.OutdoorAmbient = Color3.fromRGB(24,29,69)
            addColor(Color3.fromRGB(225,182,255),.015,.23,.27)
            addBloom(qualityValue(.42,.66,.85),40,.76)
            addAtmosphere(Color3.fromRGB(112,83,190),Color3.fromRGB(31,13,81),qualityValue(.20,.29,.36),qualityValue(.9,1.7,2.25),.12)
            addDOF(.04,42,60,0)
        end
    },
    {
        Name="Neon City",
        Apply=function()
            Lighting.ClockTime = 22
            Lighting.Brightness = 1.45
            Lighting.Ambient = Color3.fromRGB(38,20,69)
            addColor(Color3.fromRGB(215,184,255),.015,.23,.34)
            addBloom(qualityValue(.50,.76,.95),44,.68)
            addAtmosphere(Color3.fromRGB(79,75,145),Color3.fromRGB(19,13,55),.25,1.3,.1)
            polishWorld("Neon")
            if qualityRank() >= 2 then outlineWorld(C.Purple) end
        end
    },
    {
        Name="Dreamy",
        Apply=function()
            Lighting.ClockTime = 8.25
            Lighting.Brightness = 2.25
            addColor(Color3.fromRGB(255,218,246),.045,-.04,.08)
            addBloom(qualityValue(.32,.52,.72),44,.78)
            addAtmosphere(Color3.fromRGB(234,205,255),Color3.fromRGB(134,113,169),.14,.55,.03)
            addDOF(qualityValue(0,.08,.16),28,qualityValue(90,40,28),.02)
            addBlur(1)
        end
    },
    {
        Name="Clean HD",
        Apply=function()
            Lighting.Brightness = 2.15
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = .8
            Lighting.EnvironmentSpecularScale = qualityValue(.75,.90,1)
            addColor(Color3.fromRGB(255,252,248),.01,qualityValue(.09,.14,.18),qualityValue(.04,.07,.10))
            addBloom(.08,20,1.65)
            polishWorld("Realistic")
        end
    },
    {
        Name="Ice World",
        Apply=function()
            Lighting.ClockTime = 11.5
            Lighting.Brightness = 2.1
            addColor(Color3.fromRGB(184,238,255),.025,.15,.04)
            addBloom(qualityValue(.18,.30,.42),34,1.05)
            addAtmosphere(Color3.fromRGB(184,232,255),Color3.fromRGB(86,125,166),.17,qualityValue(.35,.65,.95),.05)
            addDOF(.03,48,70,0)
        end
    },
    {
        Name="Crimson",
        Apply=function()
            Lighting.ClockTime = 19.4
            Lighting.Brightness = 1.4
            Lighting.Ambient = Color3.fromRGB(91,17,27)
            Lighting.OutdoorAmbient = Color3.fromRGB(58,15,23)
            addColor(Color3.fromRGB(255,139,145),-.015,.23,.18)
            addBloom(qualityValue(.22,.36,.48),30,1.04)
            addAtmosphere(Color3.fromRGB(166,64,69),Color3.fromRGB(59,12,24),.24,qualityValue(.55,1,1.45),.07)
        end
    },
    {
        Name="Cel Outline",
        Apply=function()
            Lighting.Brightness = 2
            addColor(Color3.fromRGB(255,249,255),.02,.25,.18)
            polishWorld("Cartoon")
            outlineWorld(Color3.fromRGB(245,245,255))
        end
    },
    {
        Name="Retro Film",
        Apply=function()
            Lighting.Brightness = 1.8
            Lighting.ColorShift_Top = Color3.fromRGB(24,7,16)
            Lighting.ColorShift_Bottom = Color3.fromRGB(5,10,24)
            addColor(Color3.fromRGB(255,218,186),.01,.10,-.17)
            addBloom(.13,20,1.4)
            addDOF(.025,40,70,0)
            addAtmosphere(Color3.fromRGB(206,183,164),Color3.fromRGB(102,84,79),.08,.22,0)
        end
    }
}

local function applyShaderPreset(preset)
    if not preset then return end
    CurrentShaderPreset = preset
    S.activeShader = preset.Name
    resetShader()
    toast("Loading "..preset.Name.."...",C.Cyan)
    task.spawn(function()
        local ok = pcall(preset.Apply)
        if ok then
            toast(preset.Name.." • "..ShaderQuality,C.Purple)
        else
            toast("Shader error",C.Red)
        end
    end)
end

local ShaderQualityButton
ShaderQualityButton = select(1,button(Shaders,"Qualità Shader: MOBILE",function(b)
    QualityIndex = QualityIndex%3+1
    ShaderQuality = QualityOrder[QualityIndex]
    b.Text = "Qualità Shader: "..string.upper(ShaderQuality)
    toast("Shader Quality: "..ShaderQuality,C.Cyan)
    if CurrentShaderPreset then applyShaderPreset(CurrentShaderPreset) end
end))

infoCard(
    Shaders,
    "◈ Quality Mode",
    "Mobile usa effetti leggeri. High aggiunge profondità, materiali e più dettagli. Ultra usa il preset completo e modifica più elementi della scena."
)

button(Shaders,"↺  Reset Shader / Ripristina",function()
    CurrentShaderPreset = nil
    S.activeShader = "None"
    resetShader()
    toast("Shader reset ✦",C.Cyan)
end)

section(Shaders,"PRESETS")

for index,preset in ipairs(ShaderPresets) do
    button(Shaders,string.format("%02d  ✦  %s",index,preset.Name),function()
        applyShaderPreset(preset)
    end)
end

infoCard(
    Shaders,
    "◈ UltraNova Visual Engine",
    "Ultra Realistic, RoShade Style, Cinematic, Golden Rays, RTX-ish Night, Deep Space, Cyber Purple, Neon City, Dreamy, Clean HD, Ice World, Crimson, Cel Outline e Retro Film."
)



--========================================================
-- ULTRANOVA v3.2 EXPANSION
-- Players • Camera • Visuals • Server • Performance • Tools • Settings
--========================================================
local SessionStartedAt = os.clock()
local RuntimeFPS = 60
local frameCount = 0
local frameWindow = os.clock()

RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = os.clock()
    if now-frameWindow >= 1 then
        RuntimeFPS = math.floor(frameCount/(now-frameWindow)+.5)
        frameCount = 0
        frameWindow = now
    end
end)

local function pingText()
    local result = "?"
    pcall(function()
        result = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
    end)
    return result
end

local function memoryText()
    local result = "?"
    pcall(function()
        result = string.format("%.0f MB",Stats:GetTotalMemoryUsageMb())
    end)
    return result
end

local function uptimeText()
    local s = math.floor(os.clock()-SessionStartedAt)
    return string.format("%02d:%02d:%02d",math.floor(s/3600),math.floor(s/60)%60,s%60)
end

--========================================================
-- HOME DASHBOARD + MENU MUSIC
--========================================================
section(Home,"DASHBOARD v3.2")
local DashboardCard,DashboardText = infoCard(Home,"✦ Live Dashboard","")

task.spawn(function()
    while Gui.Parent do
        DashboardText.Text =
            "FPS: "..tostring(RuntimeFPS).."  •  Ping: "..pingText().."\n"..
            "Players: "..tostring(#Players:GetPlayers()).."  •  Session: "..uptimeText().."\n"..
            "Shader: "..tostring(S.activeShader).."  •  Dance: "..tostring(S.activeDance)
        task.wait(.45)
    end
end)

local MenuMusicToggle
MenuMusicToggle = toggle(Home,"Musica del menù / Menu Music",true,function(on)
    S.menuMusic = on
    syncMenuAudio()
end)

slider(Home,"Volume menù / Menu Volume",0,30,11,function(v)
    S.menuMusicVolume = v/100
    syncMenuAudio()
end)

button(Home,"⚡  Quick Stats",function()
    toast("FPS "..RuntimeFPS.." • Ping "..pingText().." • "..#Players:GetPlayers().." players",C.Cyan)
end)

--========================================================
-- PLAYERS PAGE
--========================================================
heading(PlayersPage,"PLAYERS","Player tools • Spectate • Radar • Orbit")
local SelectedInfoCard,SelectedInfoText = infoCard(PlayersPage,"◎ Player selezionato / Selected Player","Nessuno / None")
local SelectedPlayerButton

local function selectedPlayerValid()
    return S.selectedPlayer and S.selectedPlayer.Parent==Players and S.selectedPlayer~=LP
end

local function selectedRoot()
    return selectedPlayerValid() and S.selectedPlayer.Character and S.selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function selectedHumanoid()
    return selectedPlayerValid() and S.selectedPlayer.Character and S.selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
end

SelectedPlayerButton = select(1,button(PlayersPage,"Scegli giocatore / Select Player",function(b)
    playerPicker("Players",false,function(p)
        S.selectedPlayer=p
        b.Text="Selected: @"..p.Name
    end)
end))

task.spawn(function()
    while Gui.Parent do
        if selectedPlayerValid() then
            local p=S.selectedPlayer
            local h=selectedHumanoid()
            local pr=selectedRoot()
            local mr=root()
            local dist=(pr and mr) and string.format("%.0f studs",(pr.Position-mr.Position).Magnitude) or "?"
            SelectedInfoText.Text = p.DisplayName.."  @"..p.Name.."\nUserId: "..p.UserId.." • Distance: "..dist.."\nHealth: "..(h and string.format("%.0f / %.0f",h.Health,h.MaxHealth) or "?")
        else
            SelectedInfoText.Text="Nessuno / None"
        end
        task.wait(.35)
    end
end)

button(PlayersPage,"👁  Spectate / Osserva",function()
    local h=selectedHumanoid()
    if h then Camera.CameraSubject=h else toast("Scegli un giocatore / Select a player",C.Orange) end
end)

button(PlayersPage,"↩  Stop Spectate",function()
    local h=humanoid()
    if h then Camera.CameraSubject=h end
end)

button(PlayersPage,"Avatar Card / Scheda Avatar",function()
    if not selectedPlayerValid() then toast("Scegli un giocatore / Select a player",C.Orange) return end
    local p=S.selectedPlayer
    local modal=Instance.new("Frame")
    modal.Size=UDim2.fromOffset(300,250)
    modal.Position=UDim2.fromScale(.5,.5)
    modal.AnchorPoint=Vector2.new(.5,.5)
    modal.BackgroundColor3=C.Space2
    modal.ZIndex=180
    modal.Parent=Gui
    corner(modal,16); stroke(modal,C.Purple,1.5,.08)
    local img=Instance.new("ImageLabel")
    img.Size=UDim2.fromOffset(120,120); img.Position=UDim2.new(.5,-60,0,18)
    img.BackgroundColor3=C.Panel; img.ZIndex=181; img.Parent=modal; corner(img,60)
    task.spawn(function()
        local ok,url=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.AvatarBust,Enum.ThumbnailSize.Size420x420) end)
        if ok and img.Parent then img.Image=url end
    end)
    local tx=Instance.new("TextLabel")
    tx.Size=UDim2.new(1,-20,0,64); tx.Position=UDim2.fromOffset(10,142); tx.BackgroundTransparency=1
    tx.Text=p.DisplayName.."\n@"..p.Name.." • "..p.UserId; tx.TextColor3=C.White; tx.TextSize=13; tx.Font=Enum.Font.GothamBold; tx.ZIndex=181; tx.Parent=modal
    local close=Instance.new("TextButton")
    close.Size=UDim2.fromOffset(100,32); close.Position=UDim2.new(.5,-50,1,-42); close.BackgroundColor3=C.Panel2; close.Text="Close"; close.TextColor3=C.White; close.ZIndex=181; close.Parent=modal; corner(close,10)
    close.MouseButton1Click:Connect(function() modal:Destroy() end)
end)

button(PlayersPage,"Copia username / Copy Username",function()
    if not selectedPlayerValid() then return end
    if setclipboard then setclipboard(S.selectedPlayer.Name) else toast(S.selectedPlayer.Name,C.Cyan) end
end)

button(PlayersPage,"Copia UserId / Copy UserId",function()
    if not selectedPlayerValid() then return end
    if setclipboard then setclipboard(tostring(S.selectedPlayer.UserId)) else toast(tostring(S.selectedPlayer.UserId),C.Cyan) end
end)

button(PlayersPage,"TP dietro / TP Behind",function()
    local pr,r=selectedRoot(),root()
    if pr and r then r.CFrame=pr.CFrame*CFrame.new(0,0,4) end
end)

button(PlayersPage,"TP sopra / TP Above",function()
    local pr,r=selectedRoot(),root()
    if pr and r then r.CFrame=pr.CFrame*CFrame.new(0,7,0) end
end)

slider(PlayersPage,"Raggio Orbit / Orbit Radius",3,20,6,function(v) S.orbitRadius=v end)
slider(PlayersPage,"Velocità Orbit / Orbit Speed",1,10,2,function(v) S.orbitSpeed=v end)
toggle(PlayersPage,"Orbit Player",false,function(on) S.orbitPlayer=on end)
toggle(PlayersPage,"Health Monitor",false,function(on) S.healthMonitor=on end)
toggle(PlayersPage,"Radar 2D",false,function(on) S.playerRadar=on end)

local Radar = Instance.new("Frame")
Radar.Size=UDim2.fromOffset(150,150); Radar.Position=UDim2.new(1,-165,0,78); Radar.BackgroundColor3=C.Space2; Radar.BackgroundTransparency=.18; Radar.Visible=false; Radar.ZIndex=70; Radar.Parent=Gui
corner(Radar,75); stroke(Radar,C.Purple,1.2,.15)
local RadarDots={}

local HealthMonitorHud=Instance.new("TextLabel")
HealthMonitorHud.Size=UDim2.fromOffset(230,44)
HealthMonitorHud.Position=UDim2.new(0,14,0,78)
HealthMonitorHud.BackgroundColor3=C.Space2
HealthMonitorHud.BackgroundTransparency=.18
HealthMonitorHud.TextColor3=C.White
HealthMonitorHud.TextSize=11
HealthMonitorHud.Font=Enum.Font.GothamBold
HealthMonitorHud.Visible=false
HealthMonitorHud.ZIndex=73
HealthMonitorHud.Parent=Gui
corner(HealthMonitorHud,10)
stroke(HealthMonitorHud,C.Purple,1,.25)

RunService.RenderStepped:Connect(function()
    if S.orbitPlayer then
        local pr,r=selectedRoot(),root()
        if pr and r then
            local a=os.clock()*S.orbitSpeed
            local offset=Vector3.new(math.cos(a)*S.orbitRadius,1.5,math.sin(a)*S.orbitRadius)
            r.CFrame=CFrame.new(pr.Position+offset,pr.Position)
        end
    end

    HealthMonitorHud.Visible=S.healthMonitor and selectedPlayerValid()
    if HealthMonitorHud.Visible then
        local h=selectedHumanoid()
        HealthMonitorHud.Text="@"..S.selectedPlayer.Name.."  •  HP "..(h and string.format("%.0f / %.0f",h.Health,h.MaxHealth) or "?")
    end

    Radar.Visible=S.playerRadar
    if S.playerRadar then
        local mr=root()
        if mr then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local dot=RadarDots[p]
                    if not dot then
                        dot=Instance.new("Frame"); dot.Size=UDim2.fromOffset(7,7); dot.AnchorPoint=Vector2.new(.5,.5); dot.BackgroundColor3=C.Cyan; dot.ZIndex=72; dot.Parent=Radar; corner(dot,5); RadarDots[p]=dot
                    end
                    local pr=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if pr then
                        local delta=pr.Position-mr.Position
                        local scale=math.min(1,Vector2.new(delta.X,delta.Z).Magnitude/150)
                        local dir=Vector2.new(delta.X,delta.Z)
                        if dir.Magnitude>0 then dir=dir.Unit end
                        dot.Position=UDim2.fromOffset(75+dir.X*scale*65,75+dir.Y*scale*65); dot.Visible=true
                    else dot.Visible=false end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if RadarDots[p] then RadarDots[p]:Destroy(); RadarDots[p]=nil end
    if S.selectedPlayer==p then S.selectedPlayer=nil end
end)

--========================================================
-- CAMERA PAGE
--========================================================
heading(CameraPage,"CAMERA","Freecam • Zoom • Follow • Screenshot")

local FreeCamPad=Instance.new("Frame")
FreeCamPad.Size=UDim2.fromOffset(190,145); FreeCamPad.Position=UDim2.new(1,-205,1,-165); FreeCamPad.BackgroundColor3=C.Space2; FreeCamPad.BackgroundTransparency=.18; FreeCamPad.Visible=false; FreeCamPad.ZIndex=88; FreeCamPad.Parent=Gui
corner(FreeCamPad,16); stroke(FreeCamPad,C.Purple,1,.2)
local FreeInput={F=0,R=0,U=0,Yaw=0}
local freeCFrame=nil

local function camPadButton(text,x,y,w,h,field,val)
    local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(w or 42,h or 42); b.Position=UDim2.fromOffset(x,y); b.BackgroundColor3=C.Panel2; b.Text=text; b.TextColor3=C.White; b.TextSize=16; b.Font=Enum.Font.GothamBold; b.ZIndex=89; b.Parent=FreeCamPad; corner(b,10)
    b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then FreeInput[field]=val end end)
    b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then if FreeInput[field]==val then FreeInput[field]=0 end end end)
end
camPadButton("▲",50,8,42,42,"F",1); camPadButton("▼",50,94,42,42,"F",-1)
camPadButton("◀",6,51,42,42,"R",-1); camPadButton("▶",94,51,42,42,"R",1)
camPadButton("＋",140,8,42,42,"U",1); camPadButton("－",140,94,42,42,"U",-1)
camPadButton("↶",6,8,42,32,"Yaw",-1); camPadButton("↷",94,8,42,32,"Yaw",1)

local function setFreecam(on)
    S.freecam=on
    FreeCamPad.Visible=on
    if on then
        freeCFrame=Camera.CFrame; Camera.CameraType=Enum.CameraType.Scriptable
    else
        Camera.CameraType=Enum.CameraType.Custom
        local h=humanoid(); if h then Camera.CameraSubject=h end
    end
end

toggle(CameraPage,"Freecam",false,setFreecam)
slider(CameraPage,"Velocità Freecam / Freecam Speed",5,120,28,function(v) S.freecamSpeed=v end)

RunService.RenderStepped:Connect(function(dt)
    if S.freecam then
        Camera.CameraType=Enum.CameraType.Scriptable
        freeCFrame=freeCFrame or Camera.CFrame
        freeCFrame=freeCFrame*CFrame.Angles(0,math.rad(FreeInput.Yaw*70*dt),0)
        local move=freeCFrame.LookVector*FreeInput.F + freeCFrame.RightVector*FreeInput.R + Vector3.new(0,FreeInput.U,0)
        if move.Magnitude>0 then freeCFrame=freeCFrame+CFrame.new(move.Unit*S.freecamSpeed*dt).Position end
        Camera.CFrame=freeCFrame
    elseif math.abs(S.cameraRoll)>.05 then
        Camera.CFrame=Camera.CFrame*CFrame.Angles(0,0,math.rad(S.cameraRoll))
    end
end)

button(CameraPage,"Zoom +",function() Camera.FieldOfView=math.max(40,Camera.FieldOfView-5); S.fov=Camera.FieldOfView end)
button(CameraPage,"Zoom -",function() Camera.FieldOfView=math.min(120,Camera.FieldOfView+5); S.fov=Camera.FieldOfView end)

toggle(CameraPage,"Prima persona / First Person Lock",false,function(on)
    LP.CameraMode=on and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
end)

slider(CameraPage,"Distanza terza persona / Third Person",4,40,12,function(v)
    S.thirdPersonDistance=v
    LP.CameraMaxZoomDistance=v
    if LP.CameraMinZoomDistance>v then LP.CameraMinZoomDistance=0.5 end
end)

slider(CameraPage,"Camera Roll",-15,15,0,function(v) S.cameraRoll=v end)

local CineFov={60,70,80,90}; local CineFovIndex=1
button(CameraPage,"Cinematic FOV: 60",function(b)
    CineFovIndex=CineFovIndex%#CineFov+1; local v=CineFov[CineFovIndex]; Camera.FieldOfView=v; S.fov=v; b.Text="Cinematic FOV: "..v
end)

button(CameraPage,"Segui giocatore / Camera Follow",function()
    playerPicker("Camera Follow",false,function(p)
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then setFreecam(false); Camera.CameraSubject=h end
    end)
end)

button(CameraPage,"Torna a me / Follow Myself",function()
    local h=humanoid(); if h then setFreecam(false); Camera.CameraSubject=h end
end)

local ScreenshotMode=false
button(CameraPage,"Screenshot Mode / Hide Roblox HUD",function(b)
    ScreenshotMode=not ScreenshotMode
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,not ScreenshotMode) end)
    b.Text=ScreenshotMode and "Screenshot Mode: ON" or "Screenshot Mode / Hide Roblox HUD"
    if ScreenshotMode then Main.Visible=false; Mini.Visible=true end
end)

--========================================================
-- VISUALS PAGE
--========================================================
heading(VisualsPage,"VISUALS","Tracers • Boxes • Skeleton • Chams • Crosshair+")

local ExtraVisualGui=Instance.new("ScreenGui")
ExtraVisualGui.Name="UltraNovaExtraVisuals"; ExtraVisualGui.IgnoreGuiInset=true; ExtraVisualGui.ResetOnSpawn=false; ExtraVisualGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; ExtraVisualGui.Parent=GuiParent
local ExtraVisualObjects={}
local VisualWorldFolder=Instance.new("Folder")
VisualWorldFolder.Name="UltraNovaVisualWorld"
VisualWorldFolder.Parent=workspace

local function getVisualObj(p)
    local o=ExtraVisualObjects[p]
    if o then return o end
    o={}
    o.Tracer=Instance.new("Frame"); o.Tracer.AnchorPoint=Vector2.new(0,.5); o.Tracer.BackgroundColor3=C.Purple; o.Tracer.BorderSizePixel=0; o.Tracer.Visible=false; o.Tracer.ZIndex=35; o.Tracer.Parent=ExtraVisualGui
    o.Box=Instance.new("Frame"); o.Box.BackgroundTransparency=1; o.Box.Visible=false; o.Box.ZIndex=35; o.Box.Parent=ExtraVisualGui; o.BoxStroke=stroke(o.Box,C.Purple,1.3,.05)
    o.HealthBG=Instance.new("Frame"); o.HealthBG.BackgroundColor3=C.Black; o.HealthBG.BorderSizePixel=0; o.HealthBG.Visible=false; o.HealthBG.ZIndex=36; o.HealthBG.Parent=ExtraVisualGui
    o.Health=Instance.new("Frame"); o.Health.BackgroundColor3=C.Green; o.Health.BorderSizePixel=0; o.Health.AnchorPoint=Vector2.new(0,1); o.Health.Position=UDim2.new(0,0,1,0); o.Health.Size=UDim2.fromScale(1,1); o.Health.ZIndex=37; o.Health.Parent=o.HealthBG
    o.HL=Instance.new("Highlight"); o.HL.Enabled=false; o.HL.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; o.HL.Parent=VisualWorldFolder
    o.Skel={}
    for i=1,12 do local f=Instance.new("Frame"); f.AnchorPoint=Vector2.new(0,.5); f.BorderSizePixel=0; f.BackgroundColor3=C.Cyan; f.Visible=false; f.ZIndex=34; f.Parent=ExtraVisualGui; o.Skel[i]=f end
    ExtraVisualObjects[p]=o; return o
end

local function draw2DLine(frame,a,b,color,thickness)
    local d=b-a; local len=d.Magnitude
    frame.Position=UDim2.fromOffset(a.X,a.Y); frame.Size=UDim2.fromOffset(len,thickness or 1); frame.Rotation=math.deg(math.atan2(d.Y,d.X)); frame.BackgroundColor3=color; frame.Visible=true
end

local function hideVisual(o)
    o.Tracer.Visible=false; o.Box.Visible=false; o.HealthBG.Visible=false; o.HL.Enabled=false
    for _,f in ipairs(o.Skel) do f.Visible=false end
end

toggle(VisualsPage,"Tracers",false,function(on) S.tracers=on end)
toggle(VisualsPage,"Box ESP",false,function(on) S.boxEsp=on end)
toggle(VisualsPage,"Health Bar ESP",false,function(on) S.healthBars=on end)
toggle(VisualsPage,"Skeleton ESP",false,function(on) S.skeletonEsp=on end)
toggle(VisualsPage,"Chams",false,function(on) S.chams=on end)
toggle(VisualsPage,"Player Glow",false,function(on) S.playerGlow=on end)
toggle(VisualsPage,"Rainbow ESP",false,function(on) S.rainbowEsp=on end)
slider(VisualsPage,"Distanza massima ESP / Max ESP Distance",100,5000,2500,function(v) S.espMaxDistance=v end)

toggle(VisualsPage,"Night Vision",false,function(on)
    S.nightVision=on
    local old=Lighting:FindFirstChild("UltraNovaNightVision"); if old then old:Destroy() end
    if on then
        local cc=Instance.new("ColorCorrectionEffect"); cc.Name="UltraNovaNightVision"; cc.TintColor=Color3.fromRGB(190,255,205); cc.Brightness=.12; cc.Contrast=.08; cc.Saturation=-.08; cc.Parent=Lighting
    end
end)

section(VisualsPage,"CROSSHAIR+")
button(VisualsPage,"Colore crosshair / Crosshair Color",function(b)
    S.crosshairColorIndex=S.crosshairColorIndex%#ESP_PALETTE+1
    local col=ESP_PALETTE[S.crosshairColorIndex]
    CrossH.BackgroundColor3=col; CrossV.BackgroundColor3=col; CrossDot.BackgroundColor3=col; b.TextColor3=col
end)
slider(VisualsPage,"Spessore crosshair / Thickness",1,8,2,function(v)
    S.crosshairThickness=v; CrossH.Size=UDim2.fromOffset(S.crosshairSize,v); CrossV.Size=UDim2.fromOffset(v,S.crosshairSize)
end)
slider(VisualsPage,"Trasparenza crosshair / Opacity",0,90,0,function(v)
    S.crosshairOpacity=v/100; CrossH.BackgroundTransparency=S.crosshairOpacity; CrossV.BackgroundTransparency=S.crosshairOpacity; CrossDot.BackgroundTransparency=S.crosshairOpacity
end)

local skeletonPairsR15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
local skeletonPairsR6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

RunService.RenderStepped:Connect(function()
    Camera=workspace.CurrentCamera or Camera
    local myRoot=root(); local centerBottom=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y-5)
    local rainbow=Color3.fromHSV((os.clock()*.13)%1,.85,1)
    if S.rainbowEsp then S.espColor=rainbow end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local o=getVisualObj(p); local c=p.Character; local pr=c and c:FindFirstChild("HumanoidRootPart"); local head=c and c:FindFirstChild("Head"); local h=c and c:FindFirstChildOfClass("Humanoid")
            local allowed=false; local distance=math.huge
            if pr and myRoot then distance=(pr.Position-myRoot.Position).Magnitude; allowed=distance<=S.espMaxDistance end
            if not allowed then hideVisual(o) else
                local col=S.rainbowEsp and rainbow or S.espColor
                local rp,ron=Camera:WorldToViewportPoint(pr.Position); local hp,hon=head and Camera:WorldToViewportPoint(head.Position) or rp,false
                if ron and rp.Z>0 then
                    if S.tracers then draw2DLine(o.Tracer,centerBottom,Vector2.new(rp.X,rp.Y),col,1.4) else o.Tracer.Visible=false end
                    local height=math.max(28,math.abs(rp.Y-hp.Y)*2.7); local width=height*.55
                    if S.boxEsp then o.Box.Position=UDim2.fromOffset(rp.X-width/2,rp.Y-height/2); o.Box.Size=UDim2.fromOffset(width,height); o.BoxStroke.Color=col; o.Box.Visible=true else o.Box.Visible=false end
                    if S.healthBars and h then
                        o.HealthBG.Position=UDim2.fromOffset(rp.X-width/2-7,rp.Y-height/2); o.HealthBG.Size=UDim2.fromOffset(4,height); o.Health.Size=UDim2.new(1,0,math.clamp(h.Health/math.max(1,h.MaxHealth),0,1),0); o.HealthBG.Visible=true
                    else o.HealthBG.Visible=false end
                    o.HL.Adornee=c; o.HL.FillColor=col; o.HL.OutlineColor=col; o.HL.FillTransparency=S.chams and .68 or 1; o.HL.OutlineTransparency=S.playerGlow and 0 or .45; o.HL.Enabled=S.chams or S.playerGlow
                    for _,f in ipairs(o.Skel) do f.Visible=false end
                    if S.skeletonEsp then
                        local pairsList=(h and h.RigType==Enum.HumanoidRigType.R15) and skeletonPairsR15 or skeletonPairsR6
                        for i,pair in ipairs(pairsList) do
                            local a=c:FindFirstChild(pair[1]); local b=c:FindFirstChild(pair[2]); local f=o.Skel[i]
                            if a and b and f then local ap,aon=Camera:WorldToViewportPoint(a.Position); local bp,bon=Camera:WorldToViewportPoint(b.Position); if aon and bon then draw2DLine(f,Vector2.new(ap.X,ap.Y),Vector2.new(bp.X,bp.Y),col,1.2) end end
                        end
                    end
                else hideVisual(o) end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    local o=ExtraVisualObjects[p]; if o then pcall(function() o.Tracer:Destroy(); o.Box:Destroy(); o.HealthBG:Destroy(); o.HL:Destroy(); for _,f in ipairs(o.Skel) do f:Destroy() end end); ExtraVisualObjects[p]=nil end
end)

--========================================================
-- SHADERS WORLD FX ADD-ON
--========================================================
section(Shaders,"WORLD FX / SCENE CONTROL")
local Terrain=workspace:FindFirstChildOfClass("Terrain")
local OriginalWater = Terrain and {Color=Terrain.WaterColor,Transparency=Terrain.WaterTransparency,WaveSize=Terrain.WaterWaveSize,WaveSpeed=Terrain.WaterWaveSpeed,Reflectance=Terrain.WaterReflectance} or nil
local Clouds=Terrain and Terrain:FindFirstChildOfClass("Clouds")

button(Shaders,"Acqua: Realistic / Water",function()
    if Terrain then Terrain.WaterColor=Color3.fromRGB(34,104,145); Terrain.WaterTransparency=.22; Terrain.WaterReflectance=.45; Terrain.WaterWaveSize=.18; Terrain.WaterWaveSpeed=12 end
end)
button(Shaders,"Acqua: Deep Space",function()
    if Terrain then Terrain.WaterColor=Color3.fromRGB(39,20,86); Terrain.WaterTransparency=.28; Terrain.WaterReflectance=.55; Terrain.WaterWaveSize=.14; Terrain.WaterWaveSpeed=8 end
end)
button(Shaders,"Reset Acqua / Reset Water",function()
    if Terrain and OriginalWater then Terrain.WaterColor=OriginalWater.Color; Terrain.WaterTransparency=OriginalWater.Transparency; Terrain.WaterReflectance=OriginalWater.Reflectance; Terrain.WaterWaveSize=OriginalWater.WaveSize; Terrain.WaterWaveSpeed=OriginalWater.WaveSpeed end
end)
slider(Shaders,"Ora del giorno / Time of Day",0,24,math.floor(Lighting.ClockTime),function(v) Lighting.ClockTime=v end)
slider(Shaders,"Atmosphere Contrast",0,50,10,function(v)
    local cc=Lighting:FindFirstChild("UltraNovaManualContrast") or Instance.new("ColorCorrectionEffect"); cc.Name="UltraNovaManualContrast"; cc.Parent=Lighting; cc.Contrast=v/100
end)
slider(Shaders,"Saturazione / Saturation",0,200,100,function(v)
    local cc=Lighting:FindFirstChild("UltraNovaManualSaturation") or Instance.new("ColorCorrectionEffect"); cc.Name="UltraNovaManualSaturation"; cc.Parent=Lighting; cc.Saturation=(v-100)/100
end)
button(Shaders,"Nuvole cinematiche / Cinematic Clouds",function()
    if Terrain then
        Clouds=Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",Terrain); Clouds.Cover=.48; Clouds.Density=.55; Clouds.Color=Color3.fromRGB(220,214,238)
    end
end)
button(Shaders,"Nuvole space / Space Clouds",function()
    if Terrain then
        Clouds=Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds",Terrain); Clouds.Cover=.62; Clouds.Density=.66; Clouds.Color=Color3.fromRGB(92,63,142)
    end
end)

--========================================================
-- SERVER PAGE
--========================================================
heading(ServerPage,"SERVER","Server tools • Hop • Small server • Live stats")
local ServerStatsCard,ServerStatsText=infoCard(ServerPage,"⌁ Server Status","")
task.spawn(function()
    while Gui.Parent do
        ServerStatsText.Text="Players: "..#Players:GetPlayers().." / "..Players.MaxPlayers.."\nPing: "..pingText().." • FPS: "..RuntimeFPS.."\nSession: "..uptimeText().."\nJobId: "..string.sub(game.JobId,1,18).."..."
        task.wait(.5)
    end
end)

local function fetchServers(sortOrder)
    local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder="..(sortOrder or "Asc").."&limit=100"
    local body=game:HttpGet(url)
    return HttpService:JSONDecode(body).data or {}
end

local function hopServer(mode)
    toast("Cerco server / Searching...",C.Cyan)
    task.spawn(function()
        local ok,servers=pcall(fetchServers,mode=="random" and "Desc" or "Asc")
        if not ok then toast("Server list unavailable",C.Red) return end
        local candidates={}
        for _,s in ipairs(servers) do if s.id~=game.JobId and s.playing<s.maxPlayers then table.insert(candidates,s) end end
        if #candidates==0 then toast("Nessun server trovato / No server found",C.Orange) return end
        local target
        if mode=="random" then target=candidates[math.random(1,#candidates)] else table.sort(candidates,function(a,b) return a.playing<b.playing end); target=candidates[1] end
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,target.id,LP) end)
    end)
end

button(ServerPage,"⟳ Rejoin",function() TeleportService:Teleport(game.PlaceId,LP) end)
button(ServerPage,"⇄ Server Hop",function() hopServer("random") end)
button(ServerPage,"⇣ Join Smallest Server",function() hopServer("small") end)
button(ServerPage,"Copia JobId / Copy JobId",function() if setclipboard then setclipboard(game.JobId) else toast(game.JobId,C.Cyan) end end)
button(ServerPage,"Copia PlaceId / Copy PlaceId",function() if setclipboard then setclipboard(tostring(game.PlaceId)) else toast(tostring(game.PlaceId),C.Cyan) end end)

--========================================================
-- PERFORMANCE PAGE
--========================================================
heading(PerformancePage,"PERFORMANCE","FPS • Ping • Low Graphics • Restore")
local PerfCard,PerfText=infoCard(PerformancePage,"⚡ Live Performance","")
task.spawn(function()
    while Gui.Parent do PerfText.Text="FPS: "..RuntimeFPS.."\nPing: "..pingText().."\nMemory: "..memoryText().."\nSession: "..uptimeText(); task.wait(.5) end
end)

local FpsCaps={30,45,60,90,120,144,240}; local FpsCapIndex=3
button(PerformancePage,"FPS Cap: 60",function(b)
    FpsCapIndex=FpsCapIndex%#FpsCaps+1; local cap=FpsCaps[FpsCapIndex]; b.Text="FPS Cap: "..cap
    if setfpscap then pcall(function() setfpscap(cap) end) else toast("setfpscap unsupported",C.Orange) end
end)

local PerfBackup={}
local ParticleBackup={}
local function backupPart(p) if not PerfBackup[p] then PerfBackup[p]={Material=p.Material,Reflectance=p.Reflectance,CastShadow=p.CastShadow} end end

button(PerformancePage,"Low Graphics",function()
    task.spawn(function()
        local n=0
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and not d:IsDescendantOf(character()) then
                backupPart(d); d.Material=Enum.Material.SmoothPlastic; d.Reflectance=0; d.CastShadow=false; n+=1
                if n%350==0 then task.wait() end
            end
        end
        Lighting.GlobalShadows=false; toast("Low Graphics ON",C.Green)
    end)
end)

button(PerformancePage,"Disable Particles",function()
    for _,d in ipairs(workspace:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then if ParticleBackup[d]==nil then ParticleBackup[d]=d.Enabled end; d.Enabled=false end
    end
    toast("Particles OFF",C.Green)
end)

button(PerformancePage,"Disable Shadows",function() Lighting.GlobalShadows=false; for _,d in ipairs(workspace:GetDescendants()) do if d:IsA("BasePart") then backupPart(d); d.CastShadow=false end end end)

button(PerformancePage,"POTATO MODE",function()
    Lighting.GlobalShadows=false
    task.spawn(function()
        local n=0
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and not d:IsDescendantOf(character()) then
                backupPart(d); d.Material=Enum.Material.SmoothPlastic; d.Reflectance=0; d.CastShadow=false; n+=1
                if n%400==0 then task.wait() end
            end
            if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then if ParticleBackup[d]==nil then ParticleBackup[d]=d.Enabled end; d.Enabled=false end
        end
        toast("POTATO MODE 🥔",C.Orange)
    end)
end)

button(PerformancePage,"Restore Graphics",function()
    for p,v in pairs(PerfBackup) do if p and p.Parent then p.Material=v.Material; p.Reflectance=v.Reflectance; p.CastShadow=v.CastShadow end end; PerfBackup={}
    for d,v in pairs(ParticleBackup) do if d and d.Parent then d.Enabled=v end end; ParticleBackup={}
    Lighting.GlobalShadows=original.GlobalShadows
    toast("Graphics restored",C.Cyan)
end)

--========================================================
-- TOOLS PAGE
--========================================================
heading(ToolsPage,"TOOLS","Coordinates • Waypoints • Clipboard • Session")
local CoordCard,CoordText=infoCard(ToolsPage,"＋ Coordinates","")
local CoordHudEnabled=false
local CoordHud=Instance.new("TextLabel"); CoordHud.Size=UDim2.fromOffset(250,30); CoordHud.Position=UDim2.new(.5,-125,0,10); CoordHud.BackgroundColor3=C.Space2; CoordHud.BackgroundTransparency=.25; CoordHud.TextColor3=C.Cyan; CoordHud.Font=Enum.Font.GothamBold; CoordHud.TextSize=11; CoordHud.Visible=false; CoordHud.ZIndex=75; CoordHud.Parent=Gui; corner(CoordHud,10)

task.spawn(function()
    while Gui.Parent do
        local r=root(); local txt="Position unavailable"
        if r then txt=string.format("X %.1f   Y %.1f   Z %.1f",r.Position.X,r.Position.Y,r.Position.Z) end
        CoordText.Text=txt.."\nSession: "..uptimeText(); CoordHud.Text=txt; CoordHud.Visible=CoordHudEnabled; task.wait(.15)
    end
end)

toggle(ToolsPage,"Coordinates HUD",false,function(on) CoordHudEnabled=on end)
button(ToolsPage,"Copia posizione / Copy Position",function()
    local r=root(); if not r then return end; local txt=string.format("%.3f, %.3f, %.3f",r.Position.X,r.Position.Y,r.Position.Z); if setclipboard then setclipboard(txt) else toast(txt,C.Cyan) end
end)
button(ToolsPage,"Copia CFrame / Copy CFrame",function()
    local r=root(); if not r then return end; local c={r.CFrame:GetComponents()}; local out="CFrame.new("..table.concat(c,", ")..")"; if setclipboard then setclipboard(out) else toast("CFrame ready",C.Cyan) end
end)
button(ToolsPage,"Copia timestamp / Copy Timestamp",function()
    local t=os.date("!%Y-%m-%dT%H:%M:%SZ"); if setclipboard then setclipboard(t) else toast(t,C.Cyan) end
end)

local Waypoints={}
for i=1,5 do
    button(ToolsPage,"Save Waypoint "..i,function()
        local r=root(); if r then Waypoints[i]=r.CFrame; toast("Waypoint "..i.." saved",C.Green) end
    end)
    button(ToolsPage,"Go Waypoint "..i,function()
        local r=root(); if r and Waypoints[i] then r.CFrame=Waypoints[i] else toast("Waypoint "..i.." empty",C.Orange) end
    end)
end

--========================================================
-- SETTINGS PAGE
--========================================================
heading(SettingsPage,"SETTINGS","Themes • UI • Motion • Language • Profiles")

local ThemeOrder={"Purple","Blue","Cyan","Red","AMOLED"}; local ThemeIndex=1
local Themes={
    Purple={Space=Color3.fromRGB(7,5,17),Space2=Color3.fromRGB(13,8,30),Panel=Color3.fromRGB(20,14,43),Panel2=Color3.fromRGB(29,19,60),Purple=Color3.fromRGB(151,77,255),PurpleDark=Color3.fromRGB(97,46,191),Cyan=Color3.fromRGB(93,220,255),Blue=Color3.fromRGB(62,148,255)},
    Blue={Space=Color3.fromRGB(4,8,18),Space2=Color3.fromRGB(7,16,34),Panel=Color3.fromRGB(12,25,48),Panel2=Color3.fromRGB(18,36,67),Purple=Color3.fromRGB(69,130,255),PurpleDark=Color3.fromRGB(37,82,190),Cyan=Color3.fromRGB(92,226,255),Blue=Color3.fromRGB(55,145,255)},
    Cyan={Space=Color3.fromRGB(3,12,15),Space2=Color3.fromRGB(5,24,29),Panel=Color3.fromRGB(9,37,42),Panel2=Color3.fromRGB(12,51,58),Purple=Color3.fromRGB(45,230,236),PurpleDark=Color3.fromRGB(20,145,157),Cyan=Color3.fromRGB(155,255,255),Blue=Color3.fromRGB(45,175,225)},
    Red={Space=Color3.fromRGB(17,5,8),Space2=Color3.fromRGB(32,8,13),Panel=Color3.fromRGB(48,14,20),Panel2=Color3.fromRGB(66,20,29),Purple=Color3.fromRGB(255,72,92),PurpleDark=Color3.fromRGB(182,38,57),Cyan=Color3.fromRGB(255,173,184),Blue=Color3.fromRGB(226,71,115)},
    AMOLED={Space=Color3.fromRGB(0,0,0),Space2=Color3.fromRGB(2,2,4),Panel=Color3.fromRGB(8,8,12),Panel2=Color3.fromRGB(15,15,22),Purple=Color3.fromRGB(157,82,255),PurpleDark=Color3.fromRGB(90,42,170),Cyan=Color3.fromRGB(100,220,255),Blue=Color3.fromRGB(62,148,255)}
}

local function applyTheme(name)
    local t=Themes[name]; if not t then return end
    local old={Space=C.Space,Space2=C.Space2,Panel=C.Panel,Panel2=C.Panel2,Purple=C.Purple,PurpleDark=C.PurpleDark,Cyan=C.Cyan,Blue=C.Blue}
    for k,v in pairs(t) do C[k]=v end
    S.themeName=name
    for _,d in ipairs(Gui:GetDescendants()) do
        if d:IsA("GuiObject") then
            for k,ov in pairs(old) do if d.BackgroundColor3==ov and t[k] then d.BackgroundColor3=t[k] end end
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then if d.TextColor3==old.Cyan then d.TextColor3=C.Cyan elseif d.TextColor3==old.Purple then d.TextColor3=C.Purple end end
        elseif d:IsA("UIStroke") then
            if d.Color==old.Purple then d.Color=C.Purple elseif d.Color==old.Cyan then d.Color=C.Cyan elseif d.Color==old.Blue then d.Color=C.Blue end
        end
    end
    toast("Theme: "..name,C.Cyan)
end

button(SettingsPage,"Theme: PURPLE",function(b)
    ThemeIndex=ThemeIndex%#ThemeOrder+1; local name=ThemeOrder[ThemeIndex]; b.Text="Theme: "..string.upper(name); applyTheme(name)
end)

slider(SettingsPage,"Velocità linee / Line Speed %",40,220,100,function(v)
    S.lineSpeed=v/100; restartMainLineTweens(); restartMiniLineTweens()
end)

toggle(SettingsPage,"Line FX",true,function(on)
    S.lineFx=on; restartMainLineTweens(); restartMiniLineTweens()
end)

toggle(SettingsPage,"Reduce Motion",false,function(on)
    S.reduceMotion=on; Stars.Visible=not on; restartMainLineTweens(); restartMiniLineTweens()
end)

slider(SettingsPage,"Dimensione GUI / GUI Size %",70,130,100,function(v)
    S.guiScale=v/100; refreshScale()
end)

slider(SettingsPage,"Trasparenza GUI / GUI Transparency",0,65,0,function(v)
    S.guiTransparency=v/100
    for _,d in ipairs(Gui:GetDescendants()) do
        if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ScrollingFrame") then
            if d:GetAttribute("UltraNovaBaseTransparency")==nil then d:SetAttribute("UltraNovaBaseTransparency",d.BackgroundTransparency) end
            local base=d:GetAttribute("UltraNovaBaseTransparency") or 0
            if d.BackgroundTransparency<1 then d.BackgroundTransparency=math.clamp(base+S.guiTransparency*.55,0,.9) end
        end
    end
end)

slider(SettingsPage,"Dimensione mini button / Mini Size %",75,140,100,function(v)
    local s=v/100; Mini.Size=UDim2.fromOffset(112*s,40*s)
end)

local function snapshotOriginalTexts()
    for _,d in ipairs(Gui:GetDescendants()) do
        if (d:IsA("TextLabel") or d:IsA("TextButton")) and d:GetAttribute("UltraNovaOriginalText")==nil then d:SetAttribute("UltraNovaOriginalText",d.Text) end
    end
end

local function applyLanguageMode(mode)
    snapshotOriginalTexts(); S.languageMode=mode
    for _,d in ipairs(Gui:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local originalText=d:GetAttribute("UltraNovaOriginalText")
            if originalText then
                if mode=="Bilingual" then d.Text=originalText
                else
                    local a,b=string.match(originalText,"^(.-)%s/%s(.-)$")
                    if a and b then d.Text=(mode=="IT") and a or b else d.Text=originalText end
                end
            end
        end
    end
end

local LanguageIndex=1; local Languages={"Bilingual","IT","EN"}
button(SettingsPage,"Lingua / Language: IT+EN",function(b)
    LanguageIndex=LanguageIndex%#Languages+1; local mode=Languages[LanguageIndex]; applyLanguageMode(mode); b.Text="Language: "..mode
end)

slider(SettingsPage,"Volume Menu Ambience",0,30,11,function(v) S.menuMusicVolume=v/100; syncMenuAudio() end)

section(SettingsPage,"PROFILES")
button(SettingsPage,"Profile: Default",function()
    S.speed=16; S.jump=50; S.gravity=196.2; S.flySpeed=55; workspace.Gravity=S.gravity; Camera.FieldOfView=70; applyTheme("Purple"); toast("Default profile",C.Cyan)
end)
button(SettingsPage,"Profile: Performance",function()
    S.speed=22; S.jump=55; Lighting.GlobalShadows=false; S.reduceMotion=true; Stars.Visible=false; restartMainLineTweens(); restartMiniLineTweens(); toast("Performance profile",C.Green)
end)
button(SettingsPage,"Profile: Visual",function()
    for _,p in ipairs(ShaderPresets) do if p.Name=="Deep Space" then applyShaderPreset(p) break end end; S.esp=true; refreshEsp(); toast("Visual profile",C.Purple)
end)
button(SettingsPage,"Profile: Movement",function()
    S.speed=32; S.jump=80; S.gravity=145; S.flySpeed=90; workspace.Gravity=S.gravity; toast("Movement profile",C.Cyan)
end)

local SETTINGS_FILE="UltraNova_v3_2_settings.json"
button(SettingsPage,"Save Custom Settings",function()
    if not writefile then toast("writefile unsupported",C.Orange) return end
    local data={speed=S.speed,jump=S.jump,gravity=S.gravity,flySpeed=S.flySpeed,fov=S.fov,guiScale=S.guiScale,lineSpeed=S.lineSpeed,theme=S.themeName,menuMusic=S.menuMusic,menuVolume=S.menuMusicVolume}
    local ok=pcall(function() writefile(SETTINGS_FILE,HttpService:JSONEncode(data)) end); toast(ok and "Settings saved" or "Save failed",ok and C.Green or C.Red)
end)
button(SettingsPage,"Load Custom Settings",function()
    if not readfile or (isfile and not isfile(SETTINGS_FILE)) then toast("No saved settings",C.Orange) return end
    local ok,data=pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
    if ok and data then S.speed=data.speed or S.speed; S.jump=data.jump or S.jump; S.gravity=data.gravity or S.gravity; S.flySpeed=data.flySpeed or S.flySpeed; S.fov=data.fov or S.fov; S.guiScale=data.guiScale or S.guiScale; S.lineSpeed=data.lineSpeed or S.lineSpeed; S.menuMusic=(data.menuMusic~=false); S.menuMusicVolume=data.menuVolume or S.menuMusicVolume; workspace.Gravity=S.gravity; Camera.FieldOfView=S.fov; if data.theme then applyTheme(data.theme) end; refreshScale(); restartMainLineTweens(); restartMiniLineTweens(); syncMenuAudio(); toast("Settings loaded",C.Green) else toast("Load failed",C.Red) end
end)

--========================================================
-- COMMAND PALETTE / SEARCH
--========================================================
local SearchButton=Instance.new("TextButton")
SearchButton.Size=UDim2.fromOffset(40,34); SearchButton.Position=UDim2.new(1,-94,.5,-17); SearchButton.BackgroundColor3=C.Panel2; SearchButton.Text="⌕"; SearchButton.TextColor3=C.White; SearchButton.TextSize=18; SearchButton.Font=Enum.Font.GothamBold; SearchButton.ZIndex=11; SearchButton.Parent=Header; corner(SearchButton,10)

local SearchOverlay=Instance.new("Frame")
SearchOverlay.Size=UDim2.fromOffset(390,360); SearchOverlay.Position=UDim2.fromScale(.5,.5); SearchOverlay.AnchorPoint=Vector2.new(.5,.5); SearchOverlay.BackgroundColor3=C.Space2; SearchOverlay.Visible=false; SearchOverlay.ZIndex=160; SearchOverlay.Parent=Gui; corner(SearchOverlay,16); stroke(SearchOverlay,C.Purple,1.4,.08)
local SearchBox=Instance.new("TextBox"); SearchBox.Size=UDim2.new(1,-60,0,42); SearchBox.Position=UDim2.fromOffset(10,10); SearchBox.BackgroundColor3=C.Panel; SearchBox.PlaceholderText="Search UltraNova..."; SearchBox.Text=""; SearchBox.TextColor3=C.White; SearchBox.PlaceholderColor3=C.Soft; SearchBox.Font=Enum.Font.Gotham; SearchBox.TextSize=13; SearchBox.ClearTextOnFocus=false; SearchBox.ZIndex=161; SearchBox.Parent=SearchOverlay; corner(SearchBox,10)
local SearchClose=Instance.new("TextButton"); SearchClose.Size=UDim2.fromOffset(38,38); SearchClose.Position=UDim2.new(1,-48,0,12); SearchClose.BackgroundColor3=C.Panel2; SearchClose.Text="×"; SearchClose.TextColor3=C.White; SearchClose.ZIndex=161; SearchClose.Parent=SearchOverlay; corner(SearchClose,10)
local SearchResults=Instance.new("ScrollingFrame"); SearchResults.Size=UDim2.new(1,-20,1,-70); SearchResults.Position=UDim2.fromOffset(10,60); SearchResults.BackgroundTransparency=1; SearchResults.BorderSizePixel=0; SearchResults.AutomaticCanvasSize=Enum.AutomaticSize.Y; SearchResults.CanvasSize=UDim2.fromOffset(0,0); SearchResults.ScrollBarThickness=3; SearchResults.ZIndex=161; SearchResults.Parent=SearchOverlay; local SRList=Instance.new("UIListLayout"); SRList.Padding=UDim.new(0,6); SRList.Parent=SearchResults

local function refreshSearch()
    for _,d in ipairs(SearchResults:GetChildren()) do if d:IsA("TextButton") then d:Destroy() end end
    local q=string.lower(SearchBox.Text or ""); if #q<1 then return end
    local shown=0
    for _,entry in ipairs(ControlRegistry) do
        if string.find(string.lower(entry.Text),q,1,true) then
            shown+=1; if shown>25 then break end
            local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-5,0,38); b.BackgroundColor3=C.Panel; b.Text=entry.Page.."  •  "..entry.Text; b.TextColor3=C.White; b.TextSize=11; b.TextXAlignment=Enum.TextXAlignment.Left; b.Font=Enum.Font.Gotham; b.ZIndex=162; b.Parent=SearchResults; corner(b,9)
            b.MouseButton1Click:Connect(function()
                SearchOverlay.Visible=false; Main.Visible=true; Mini.Visible=false; switchPage(entry.Page)
                local page=Pages[entry.Page]
                if page and entry.Frame and entry.Frame.Parent==page then page.CanvasPosition=Vector2.new(0,math.max(0,entry.Frame.AbsolutePosition.Y-page.AbsolutePosition.Y+page.CanvasPosition.Y-80)) end
            end)
        end
    end
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshSearch)
SearchButton.MouseButton1Click:Connect(function() SearchOverlay.Visible=true; SearchBox:CaptureFocus() end)
SearchClose.MouseButton1Click:Connect(function() SearchOverlay.Visible=false end)

--========================================================
-- QUICK MENU (long press UltraNova mini button)
--========================================================
local QuickMenu=Instance.new("Frame")
QuickMenu.Size=UDim2.fromOffset(190,255); QuickMenu.Position=UDim2.new(0,16,.52,26); QuickMenu.BackgroundColor3=C.Space2; QuickMenu.Visible=false; QuickMenu.ZIndex=145; QuickMenu.Parent=Gui; corner(QuickMenu,15); stroke(QuickMenu,C.Purple,1.3,.08)
local QL=Instance.new("UIListLayout"); QL.Padding=UDim.new(0,6); QL.Parent=QuickMenu; padding(QuickMenu,8,8,8,8)
local function qButton(text,fn) local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,40); b.BackgroundColor3=C.Panel; b.Text=text; b.TextColor3=C.White; b.TextSize=11; b.Font=Enum.Font.GothamSemibold; b.ZIndex=146; b.Parent=QuickMenu; corner(b,9); b.MouseButton1Click:Connect(fn); return b end
qButton("Fly ON/OFF",function() S.fly=not S.fly; FlyPad.Visible=S.fly; toast("Fly: "..(S.fly and "ON" or "OFF"),C.Purple) end)
qButton("Noclip ON/OFF",function() S.noclip=not S.noclip; toast("Noclip: "..(S.noclip and "ON" or "OFF"),C.Cyan) end)
qButton("ESP ON/OFF",function() S.esp=not S.esp; refreshEsp(); toast("ESP: "..(S.esp and "ON" or "OFF"),C.Cyan) end)
qButton("Fullbright",function() S.fullbright=not S.fullbright; if S.fullbright then Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.GlobalShadows=false else Lighting.Brightness=original.Brightness; Lighting.ClockTime=original.ClockTime; Lighting.GlobalShadows=original.GlobalShadows end end)
qButton("Open UltraNova",function() QuickMenu.Visible=false; Mini.Visible=false; Main.Visible=true end)

local miniHoldStart=0
Mini.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
        miniHoldStart=os.clock()
        task.delay(.58,function()
            if miniDragging and not miniMoved and os.clock()-miniHoldStart>=.55 then
                QuickMenu.Position=UDim2.fromOffset(math.clamp(Mini.AbsolutePosition.X,4,Camera.ViewportSize.X-QuickMenu.AbsoluteSize.X-4),math.clamp(Mini.AbsolutePosition.Y+Mini.AbsoluteSize.Y+5,4,Camera.ViewportSize.Y-QuickMenu.AbsoluteSize.Y-4))
                QuickMenu.Visible=not QuickMenu.Visible
                miniMoved=true -- prevents normal click opening the main window
            end
        end)
    end
end)

-- Language snapshot after all controls exist.
task.defer(snapshotOriginalTexts)

--========================================================
-- RESPAWN REAPPLY
--========================================================
LP.CharacterAdded:Connect(function()
    task.wait(.8)

    local h = humanoid()
    if h then
        h.WalkSpeed = S.speed
        pcall(function()
            h.UseJumpPower = true
            h.JumpPower = S.jump
        end)
    end

    workspace.Gravity = S.gravity

    if S.localInvisible then
        local c = character()
        for _,d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then d.LocalTransparencyModifier = 1 end
        end
    end

    collisionBackup = {}
    refreshEsp()
end)

--========================================================
-- CLEANUP WHEN HUB REMOVED
--========================================================
Gui.AncestryChanged:Connect(function(_,parent)
    if parent ~= nil then return end

    S.fly = false
    S.noclip = false
    S.airWalk = false
    S.esp = false
    S.aimbot = false
    S.silentAim = false

    pcall(function()
        AimOverlay:Destroy()
    end)

    pcall(function()
        stopDance()
        DanceSound:Destroy()
    end)

    pcall(function()
        resetShader()
    end)

    pcall(function()
        if ShaderWorldFolder and ShaderWorldFolder.Parent then
            ShaderWorldFolder:Destroy()
        end
    end)

    if AirPlatform then
        pcall(function() AirPlatform:Destroy() end)
    end


    pcall(function() MenuAmbience:Destroy(); MenuWhoosh:Destroy() end)
    pcall(function() ExtraVisualGui:Destroy(); VisualWorldFolder:Destroy() end)
    pcall(function() Radar:Destroy(); HealthMonitorHud:Destroy(); CoordHud:Destroy(); FreeCamPad:Destroy() end)
    pcall(function() if WaterWalkPart then WaterWalkPart:Destroy() end end)
    pcall(function() if S.freezePosition and root() then root().Anchored=false end end)
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true) end)
    clearEsp()
end)

--========================================================
-- START
--========================================================
switchPage("Home")
toast("UltraNova Hub v3.2 ✦",C.Purple)
