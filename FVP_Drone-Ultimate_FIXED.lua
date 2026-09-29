--============================================================== -- RETRO
ANALOG FPV v4 -- FVP LAUNCHER + HARDTEKK MUSIC + ADVANCED OSD -- LOCAL
VISUAL / SIMULATION
--==============================================================

local Players = game:GetService("Players") local RunService =
game:GetService("RunService") local UserInputService =
game:GetService("UserInputService") local SoundService =
game:GetService("SoundService") local ContentProvider =
game:GetService("ContentProvider")

local Player = Players.LocalPlayer local Camera =
workspace.CurrentCamera local PlayerGui =
Player:WaitForChild("PlayerGui")

--============================================================== -- CONFIG
--==============================================================

local Config = { MaxSpeed = 140, MaxDistance = 600, CameraFOV = 110,
PitchRate = 2.8, RollRate = 3.0, YawRate = 2.5, ThrottlePower = 48,
Gravity = 19.62, Drag = 0.985, MinBattery = 13.2, MaxBattery = 16.8 }

--============================================================== -- STATE
--==============================================================

local State = { Active = false, Crashed = false, Position =
Vector3.zero, Velocity = Vector3.zero, Rotation = CFrame.new(), Throttle
= 0, HomePoint = Vector3.zero, Battery = Config.MaxBattery, RSSI = 99,
FlightTime = 0 }

local Input = { Pitch = 0, Roll = 0, Yaw = 0, Throttle = 0 }

local DroneModel = nil

--============================================================== -- SONGS
--==============================================================

local Songs = { {Name="Sensitive", Id="113386216095936"}, {Name="Toly
Summer", Id="78474811337135"}, {Name="Hardtekk Pro",
Id="86503267790406"}, {Name="Hi Roblox", Id="107094208500"}, {Name="Holy
War", Id="75485931767123"}, {Name="I’m so fed up",
Id="103072508653269"}, {Name="VesNa", Id="139780461400228"}, {Name="Walk
in the park", Id="136362169566807"} }

local SongIndex = 1 local SelectedSong = Songs[1]

local Music = Instance.new("Sound") Music.Name = "FVP_Hardtekk_Music"
Music.Volume = 0.65 Music.Looped = false Music.Parent = SoundService

local AudioStatus = "READY"

local function PlaySong(index) if index < 1 then index = #Songs end if
index > #Songs then index = 1 end

    SongIndex = index
    SelectedSong = Songs[SongIndex]

    Music:Stop()
    Music.SoundId = "rbxassetid://" .. SelectedSong.Id
    Music.TimePosition = 0

    local loaded = pcall(function()
        ContentProvider:PreloadAsync({Music})
    end)

    if loaded then
        local ok = pcall(function()
            Music:Play()
        end)
        AudioStatus = ok and "PLAYING" or "AUDIO UNAVAILABLE"
    else
        AudioStatus = "AUDIO UNAVAILABLE"
    end

end

local function ToggleMusic() if Music.IsPlaying then Music:Pause()
AudioStatus = "PAUSED" else if Music.SoundId == "" then
PlaySong(SongIndex) else local ok = pcall(function() Music:Resume() end)
AudioStatus = ok and "PLAYING" or "AUDIO UNAVAILABLE" end end end

Music.Ended:Connect(function() if State.Active or Music.Looped == false
then PlaySong(SongIndex + 1) end end)

--============================================================== -- MAIN
FVP GUI --==============================================================

local Gui = Instance.new("ScreenGui") Gui.Name = "FVP_Complete_System"
Gui.ResetOnSpawn = false Gui.IgnoreGuiInset = true Gui.DisplayOrder =
9999 Gui.Parent = PlayerGui

local Launcher = Instance.new("TextButton") Launcher.Size =
UDim2.fromOffset(90,42) Launcher.Position = UDim2.fromOffset(12,12)
Launcher.BackgroundColor3 = Color3.fromRGB(12,16,14) Launcher.Text =
"FVP" Launcher.TextColor3 = Color3.fromRGB(0,255,120) Launcher.TextSize
= 20 Launcher.Font = Enum.Font.Code Launcher.Parent = Gui

local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0,8)
lc.Parent = Launcher

local ls = Instance.new("UIStroke") ls.Color = Color3.fromRGB(0,255,120)
ls.Parent = Launcher

local Menu = Instance.new("Frame") Menu.Size = UDim2.fromOffset(390,540)
Menu.Position = UDim2.fromOffset(12,62) Menu.BackgroundColor3 =
Color3.fromRGB(7,11,9) Menu.Visible = false Menu.Parent = Gui

local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,10)
mc.Parent = Menu

local ms = Instance.new("UIStroke") ms.Color = Color3.fromRGB(0,255,120)
ms.Parent = Menu

local Title = Instance.new("TextLabel") Title.Size =
UDim2.new(1,-20,0,38) Title.Position = UDim2.fromOffset(10,7)
Title.BackgroundTransparency = 1 Title.Text = "FVP // HARDTEKK PLAYER"
Title.TextColor3 = Color3.fromRGB(0,255,120) Title.TextSize = 20
Title.Font = Enum.Font.Code Title.TextXAlignment =
Enum.TextXAlignment.Left Title.Parent = Menu

local Current = Instance.new("TextLabel") Current.Size =
UDim2.new(1,-20,0,25) Current.Position = UDim2.fromOffset(10,43)
Current.BackgroundTransparency = 1 Current.Text = "♪" ..
SelectedSong.Name Current.TextColor3 = Color3.fromRGB(190,255,205)
Current.TextSize = 14 Current.Font = Enum.Font.Code
Current.TextXAlignment = Enum.TextXAlignment.Left Current.Parent = Menu

--============================================================== -- SONG
LIST --==============================================================

local List = Instance.new("ScrollingFrame") List.Size =
UDim2.new(1,-20,0,250) List.Position = UDim2.fromOffset(10,75)
List.BackgroundTransparency = 1 List.BorderSizePixel = 0
List.ScrollBarThickness = 4 List.Parent = Menu

local Layout = Instance.new("UIListLayout") Layout.Padding =
UDim.new(0,5) Layout.Parent = List

local SongButtons = {}

for i, song in ipairs(Songs) do local b = Instance.new("TextButton")
b.Size = UDim2.new(1,-8,0,38) b.BackgroundColor3 =
Color3.fromRGB(18,24,20) b.Text = string.format("%02d ♪ %s", i,
song.Name) b.TextColor3 = Color3.fromRGB(225,255,230) b.TextSize = 14
b.Font = Enum.Font.Code b.TextXAlignment = Enum.TextXAlignment.Left
b.Parent = List

    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0,10)
    p.Parent = b

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b

    SongButtons[i] = b

    b.MouseButton1Click:Connect(function()
        PlaySong(i)
        Current.Text = "♪ " .. SelectedSong.Name
    end)

end

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
List.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 8)
end)

--============================================================== -- PLAYER
CONTROLS --==============================================================

local function MakeControl(text, x) local b = Instance.new("TextButton")
b.Size = UDim2.fromOffset(58,38) b.Position = UDim2.fromOffset(x,335)
b.BackgroundColor3 = Color3.fromRGB(18,25,20) b.Text = text b.TextColor3
= Color3.fromRGB(0,255,120) b.TextSize = 17 b.Font = Enum.Font.Code
b.Parent = Menu

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b
    return b

end

local Prev = MakeControl("◀", 10) local PlayPause = MakeControl("▶", 76)
local Next = MakeControl("▶▶", 142) local Stop = MakeControl("■", 208)

Prev.MouseButton1Click:Connect(function() PlaySong(SongIndex - 1)
Current.Text = "♪" .. SelectedSong.Name end)

PlayPause.MouseButton1Click:Connect(function() ToggleMusic() end)

Next.MouseButton1Click:Connect(function() PlaySong(SongIndex + 1)
Current.Text = "♪" .. SelectedSong.Name end)

Stop.MouseButton1Click:Connect(function() Music:Stop() AudioStatus =
"STOPPED" end)

local Status = Instance.new("TextLabel") Status.Size =
UDim2.new(1,-20,0,24) Status.Position = UDim2.fromOffset(10,380)
Status.BackgroundTransparency = 1 Status.Text = "AUDIO: READY"
Status.TextColor3 = Color3.fromRGB(150,255,180) Status.TextSize = 13
Status.Font = Enum.Font.Code Status.TextXAlignment =
Enum.TextXAlignment.Left Status.Parent = Menu

--============================================================== -- VOLUME
--==============================================================

local VolMinus = MakeControl("-", 10) VolMinus.Position =
UDim2.fromOffset(285,335)

local VolPlus = MakeControl("+", 351) VolPlus.Position =
UDim2.fromOffset(285,335)

local VolumeText = Instance.new("TextLabel") VolumeText.Size =
UDim2.fromOffset(120,30) VolumeText.Position = UDim2.fromOffset(280,380)
VolumeText.BackgroundTransparency = 1 VolumeText.Text = "VOL 65%"
VolumeText.TextColor3 = Color3.fromRGB(0,255,120) VolumeText.TextSize =
13 VolumeText.Font = Enum.Font.Code VolumeText.TextXAlignment =
Enum.TextXAlignment.Center VolumeText.Parent = Menu

VolMinus.MouseButton1Click:Connect(function() Music.Volume =
math.clamp(Music.Volume - 0.05, 0, 1) end)

VolPlus.MouseButton1Click:Connect(function() Music.Volume =
math.clamp(Music.Volume + 0.05, 0, 1) end)

--============================================================== --
PROGRESS --==============================================================

local ProgressBG = Instance.new("Frame") ProgressBG.Size =
UDim2.new(1,-20,0,8) ProgressBG.Position = UDim2.fromOffset(10,415)
ProgressBG.BackgroundColor3 = Color3.fromRGB(30,35,31)
ProgressBG.BorderSizePixel = 0 ProgressBG.Parent = Menu

local Progress = Instance.new("Frame") Progress.Size =
UDim2.fromScale(0,1) Progress.BackgroundColor3 =
Color3.fromRGB(0,255,120) Progress.BorderSizePixel = 0 Progress.Parent =
ProgressBG

local TimeText = Instance.new("TextLabel") TimeText.Size =
UDim2.new(1,-20,0,24) TimeText.Position = UDim2.fromOffset(10,427)
TimeText.BackgroundTransparency = 1 TimeText.Text = "00:00 / 00:00"
TimeText.TextColor3 = Color3.fromRGB(160,255,180) TimeText.TextSize = 12
TimeText.Font = Enum.Font.Code TimeText.TextXAlignment =
Enum.TextXAlignment.Left TimeText.Parent = Menu

--============================================================== -- START
FVP --==============================================================

local Start = Instance.new("TextButton") Start.Size =
UDim2.new(1,-20,0,52) Start.Position = UDim2.new(0,10,1,-62)
Start.BackgroundColor3 = Color3.fromRGB(0,115,62) Start.Text = "▶ START
FVP" Start.TextColor3 = Color3.fromRGB(255,255,255) Start.TextSize = 20
Start.Font = Enum.Font.Code Start.Parent = Menu

local sc = Instance.new("UICorner") sc.CornerRadius = UDim.new(0,8)
sc.Parent = Start

Launcher.MouseButton1Click:Connect(function() Menu.Visible = not
Menu.Visible end)

--============================================================== -- FPV
OSD --==============================================================

local OSD = Instance.new("Frame") OSD.Size = UDim2.fromScale(1,1)
OSD.BackgroundTransparency = 1 OSD.Visible = false OSD.Parent = Gui

local function Label(parent,text,size,pos,textSize) local l =
Instance.new("TextLabel") l.Size = size l.Position = pos
l.BackgroundTransparency = 1 l.Text = text l.TextColor3 =
Color3.fromRGB(0,255,120) l.TextStrokeTransparency = 0.45 l.Font =
Enum.Font.Code l.TextSize = textSize or 16 l.Parent = parent return l
end

local TL = Label(OSD,"● ARM |
ACRO",UDim2.fromOffset(300,30),UDim2.fromOffset(18,15),17) local TR =
Label(OSD,"16.80V",UDim2.fromOffset(220,30),UDim2.new(1,-238,0,15),17)
TR.TextXAlignment = Enum.TextXAlignment.Right

local Timer =
Label(OSD,"00:00",UDim2.fromOffset(120,30),UDim2.new(.5,-60,0,18),17)
Timer.TextXAlignment = Enum.TextXAlignment.Center

local BL = Label(OSD,"SPD 000
KM/H",UDim2.fromOffset(260,30),UDim2.fromOffset(18,0),17) BL.Position =
UDim2.new(0,18,1,-48)

local BC = Label(OSD,"ALT 000
M",UDim2.fromOffset(260,30),UDim2.new(.5,-130,1,-48),17)
BC.TextXAlignment = Enum.TextXAlignment.Center

local BR = Label(OSD,"RSSI
099%",UDim2.fromOffset(260,30),UDim2.new(1,-278,1,-48),17)
BR.TextXAlignment = Enum.TextXAlignment.Right

-- Horizon

local Horizon = Instance.new("Frame") Horizon.Size =
UDim2.fromOffset(500,500) Horizon.Position = UDim2.fromScale(.5,.5)
Horizon.AnchorPoint = Vector2.new(.5,.5) Horizon.BackgroundTransparency
= 1 Horizon.Parent = OSD

local HorizonLine = Instance.new("Frame") HorizonLine.Size =
UDim2.fromOffset(420,2) HorizonLine.Position = UDim2.fromScale(.5,.5)
HorizonLine.AnchorPoint = Vector2.new(.5,.5)
HorizonLine.BackgroundColor3 = Color3.fromRGB(0,255,120)
HorizonLine.BorderSizePixel = 0 HorizonLine.Parent = Horizon

local PitchLines = {}

for pitch = -40,40,10 do if pitch ~= 0 then local line =
Instance.new("Frame") line.Size = UDim2.fromOffset(pitch % 20 == 0 and
90 or 55,2) line.AnchorPoint = Vector2.new(.5,.5) line.BackgroundColor3
= Color3.fromRGB(0,255,120) line.BorderSizePixel = 0 line.Parent =
Horizon

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.fromOffset(40,20)
        txt.AnchorPoint = Vector2.new(.5,.5)
        txt.BackgroundTransparency = 1
        txt.Text = tostring(math.abs(pitch))
        txt.TextColor3 = Color3.fromRGB(0,255,120)
        txt.TextSize = 12
        txt.Font = Enum.Font.Code
        txt.Parent = Horizon

        table.insert(PitchLines,{line=line,text=txt,pitch=pitch})
    end

end

-- Crosshair

local Cross = Instance.new("Frame") Cross.Size =
UDim2.fromOffset(120,120) Cross.Position = UDim2.fromScale(.5,.5)
Cross.AnchorPoint = Vector2.new(.5,.5) Cross.BackgroundTransparency = 1
Cross.Parent = OSD

local ch = Instance.new("Frame") ch.Size = UDim2.fromOffset(42,2)
ch.Position = UDim2.fromScale(.5,.5) ch.AnchorPoint = Vector2.new(.5,.5)
ch.BackgroundColor3 = Color3.fromRGB(0,255,120) ch.BorderSizePixel = 0
ch.Parent = Cross

local cv = Instance.new("Frame") cv.Size = UDim2.fromOffset(2,42)
cv.Position = UDim2.fromScale(.5,.5) cv.AnchorPoint = Vector2.new(.5,.5)
cv.BackgroundColor3 = Color3.fromRGB(0,255,120) cv.BorderSizePixel = 0
cv.Parent = Cross

-- Throttle

local ThrBG = Instance.new("Frame") ThrBG.Size =
UDim2.fromOffset(18,220) ThrBG.Position = UDim2.new(1,-48,.5,0)
ThrBG.AnchorPoint = Vector2.new(0,.5) ThrBG.BackgroundColor3 =
Color3.fromRGB(20,25,21) ThrBG.BackgroundTransparency = .3
ThrBG.BorderSizePixel = 1 ThrBG.Parent = OSD

local ThrFill = Instance.new("Frame") ThrFill.Size = UDim2.new(1,0,0,0)
ThrFill.Position = UDim2.new(0,0,1,0) ThrFill.AnchorPoint =
Vector2.new(0,1) ThrFill.BackgroundColor3 = Color3.fromRGB(0,255,120)
ThrFill.BorderSizePixel = 0 ThrFill.Parent = ThrBG

Label(OSD,"THR",UDim2.fromOffset(45,20),UDim2.new(1,-75,.5,115),12)

-- Battery

local BatBG = Instance.new("Frame") BatBG.Size =
UDim2.fromOffset(180,10) BatBG.Position = UDim2.new(.5,-90,1,-78)
BatBG.BackgroundColor3 = Color3.fromRGB(30,35,31) BatBG.BorderSizePixel
= 0 BatBG.Parent = OSD

local BatFill = Instance.new("Frame") BatFill.Size =
UDim2.fromScale(1,1) BatFill.BackgroundColor3 =
Color3.fromRGB(0,255,120) BatFill.BorderSizePixel = 0 BatFill.Parent =
BatBG

-- RSSI

local RSSIBG = Instance.new("Frame") RSSIBG.Size =
UDim2.fromOffset(120,8) RSSIBG.Position = UDim2.new(1,-145,1,-76)
RSSIBG.BackgroundColor3 = Color3.fromRGB(30,35,31)
RSSIBG.BorderSizePixel = 0 RSSIBG.Parent = OSD

local RSSIFill = Instance.new("Frame") RSSIFill.Size =
UDim2.fromScale(1,1) RSSIFill.BackgroundColor3 =
Color3.fromRGB(0,255,120) RSSIFill.BorderSizePixel = 0 RSSIFill.Parent =
RSSIBG

local SignalLost = Label(OSD,"!!! SIGNAL LOST
!!!",UDim2.fromOffset(500,80),UDim2.fromScale(.5,.5),42)
SignalLost.AnchorPoint = Vector2.new(.5,.5) SignalLost.TextXAlignment =
Enum.TextXAlignment.Center SignalLost.TextColor3 =
Color3.fromRGB(255,0,0) SignalLost.Visible = false

--============================================================== -- DRONE
MODEL --==============================================================

local function SpawnDrone() if DroneModel then DroneModel:Destroy() end

    DroneModel = Instance.new("Model")
    DroneModel.Name = "FVP_DRONE"
    DroneModel.Parent = workspace

    local body = Instance.new("Part")
    body.Name = "Frame"
    body.Size = Vector3.new(1.6,.18,1.6)
    body.Color = Color3.fromRGB(15,15,15)
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = true
    body.CanCollide = false
    body.Parent = DroneModel

    DroneModel.PrimaryPart = body

end

--============================================================== -- FPV
START / STOP
--==============================================================

function ToggleDrone() if State.Active then State.Active = false
OSD.Visible = false Camera.CameraType = Enum.CameraType.Custom

        if DroneModel then
            DroneModel:Destroy()
            DroneModel = nil
        end
        return
    end

    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    State.Active = true
    State.Crashed = false
    State.Position = root.Position + Vector3.new(0,5,-5)
    State.HomePoint = State.Position
    State.Velocity = Vector3.zero
    State.Rotation = CFrame.new(State.Position)
    State.Throttle = 0
    State.Battery = Config.MaxBattery
    State.RSSI = 99
    State.FlightTime = 0

    SpawnDrone()

    Menu.Visible = false
    OSD.Visible = true

    Camera.CameraType = Enum.CameraType.Scriptable

    -- Müzik çalmıyorsa seçili şarkıyı başlat.
    -- Çalıyorsa aynen devam eder.
    if not Music.IsPlaying then
        PlaySong(SongIndex)
    end

end

Start.MouseButton1Click:Connect(function() ToggleDrone() end)

--============================================================== --
KEYBOARD --==============================================================

UserInputService.InputBegan:Connect(function(input,gpe) if gpe then
return end

    if input.KeyCode == Enum.KeyCode.F then
        ToggleDrone()
        return
    end

    if input.KeyCode == Enum.KeyCode.W then
        Input.Pitch = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        Input.Pitch = -1
    elseif input.KeyCode == Enum.KeyCode.A then
        Input.Roll = -1
    elseif input.KeyCode == Enum.KeyCode.D then
        Input.Roll = 1
    elseif input.KeyCode == Enum.KeyCode.Q then
        Input.Yaw = -1
    elseif input.KeyCode == Enum.KeyCode.E then
        Input.Yaw = 1
    elseif input.KeyCode == Enum.KeyCode.Space then
        Input.Throttle = 1
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        Input.Throttle = -1
    end

end)

UserInputService.InputEnded:Connect(function(input) if input.KeyCode ==
Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then Input.Pitch = 0
elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode ==
Enum.KeyCode.D then Input.Roll = 0 elseif input.KeyCode ==
Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.E then Input.Yaw = 0
elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode ==
Enum.KeyCode.LeftShift then Input.Throttle = 0 end end)

--============================================================== -- CRASH
--==============================================================

local function Crash() if State.Crashed then return end

    State.Crashed = true
    SignalLost.Visible = true

    task.delay(3,function()
        State.Active = false
        State.Crashed = false
        SignalLost.Visible = false
        OSD.Visible = false
        Camera.CameraType = Enum.CameraType.Custom

        if DroneModel then
            DroneModel:Destroy()
            DroneModel = nil
        end
    end)

end

--============================================================== --
HORIZON --==============================================================

local function UpdateHorizon() local look = State.Rotation.LookVector
local up = State.Rotation.UpVector local right =
State.Rotation.RightVector

    local pitch = math.deg(math.asin(math.clamp(-look.Y,-1,1)))
    local roll = math.deg(math.atan2(right.Y,up.Y))

    Horizon.Rotation = -roll

    HorizonLine.Position = UDim2.new(.5,0,.5,pitch*4)

    for _,data in ipairs(PitchLines) do
        local y = .5 + ((data.pitch - pitch)/40)
        data.line.Position = UDim2.new(.5,0,y,0)
        data.text.Position = UDim2.new(.5,data.pitch > 0 and -65 or 65,y,0)
    end

end

--============================================================== -- OSD
UPDATE --==============================================================

local function UpdateOSD() local speed =
math.floor(State.Velocity.Magnitude * 3.6) local alt =
math.max(0,State.Position.Y)

    TL.Text = "● ARM  |  ACRO  |  4S"
    TR.Text = string.format("%.2FV",State.Battery)

    local mins = math.floor(State.FlightTime/60)
    local secs = math.floor(State.FlightTime%60)
    Timer.Text = string.format("%02d:%02d",mins,secs)

    BL.Text = string.format("SPD %03d KM/H",speed)
    BC.Text = string.format("ALT %03d M",alt)
    BR.Text = string.format("RSSI %03d%%",State.RSSI)

    ThrFill.Size = UDim2.new(1,0,State.Throttle,0)

    local battery = math.clamp(
        (State.Battery-Config.MinBattery) /
        (Config.MaxBattery-Config.MinBattery),0,1
    )

    BatFill.Size = UDim2.new(battery,0,1,0)
    RSSIFill.Size = UDim2.new(State.RSSI/100,0,1,0)

    UpdateHorizon()

end

--============================================================== --
PHYSICS --==============================================================

local function Update(dt) if not State.Active or State.Crashed or not
DroneModel then return end

    State.FlightTime += dt

    State.Throttle = math.clamp(
        State.Throttle + Input.Throttle*dt*1.8,
        0,1
    )

    State.Rotation =
        State.Rotation *
        CFrame.Angles(
            math.rad(Input.Pitch*Config.PitchRate),
            math.rad(Input.Yaw*Config.YawRate),
            math.rad(Input.Roll*Config.RollRate)
        )

    local thrust =
        State.Rotation.UpVector *
        (State.Throttle*Config.ThrottlePower)

    local gravity = Vector3.new(0,-Config.Gravity,0)

    State.Velocity =
        State.Velocity +
        (thrust+gravity)*dt

    State.Velocity =
        State.Velocity *
        math.pow(Config.Drag,dt*60)

    if State.Velocity.Magnitude > Config.MaxSpeed then
        State.Velocity =
            State.Velocity.Unit *
            Config.MaxSpeed
    end

    local movement = State.Velocity*dt

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        DroneModel,
        Player.Character
    }

    local hit = workspace:Raycast(
        State.Position,
        movement,
        params
    )

    if hit then
        Crash()
        return
    end

    State.Position += movement

    local distance =
        (State.Position-State.HomePoint).Magnitude

    if distance > Config.MaxDistance then
        Crash()
        return
    end

    local rotationOnly =
        State.Rotation-State.Rotation.Position

    local droneCF =
        CFrame.new(State.Position) *
        rotationOnly

    DroneModel:PivotTo(droneCF)

    Camera.CFrame =
        droneCF *
        CFrame.new(0,.1,-.45)

    Camera.FieldOfView = Config.CameraFOV

    State.Battery =
        math.max(
            Config.MinBattery,
            State.Battery -
            State.Throttle*dt*.025
        )

    State.RSSI =
        math.clamp(
            100-(distance/Config.MaxDistance*70),
            20,99
        )

    UpdateOSD()

end

--============================================================== -- GUI
UPDATE --==============================================================

local function UpdateMusicGUI() Status.Text = "AUDIO:" .. AudioStatus
Current.Text = "♪" .. SelectedSong.Name

    VolumeText.Text =
        string.format("VOL %d%%",math.floor(Music.Volume*100))

    if Music.TimeLength > 0 then
        local progress =
            math.clamp(
                Music.TimePosition/Music.TimeLength,
                0,1
            )

        Progress.Size =
            UDim2.new(progress,0,1,0)

        local p1 = math.floor(Music.TimePosition)
        local p2 = math.floor(Music.TimeLength)

        TimeText.Text =
            string.format(
                "%02d:%02d / %02d:%02d",
                math.floor(p1/60),p1%60,
                math.floor(p2/60),p2%60
            )
    else
        Progress.Size = UDim2.fromScale(0,1)
        TimeText.Text = "00:00 / --:--"
    end

end

--============================================================== -- RENDER
LOOP --==============================================================

local RenderEvent = RunService.PreRender or RunService.RenderStepped

RenderEvent:Connect(function(dt) dt = math.min(dt,0.1)

    Update(dt)
    UpdateMusicGUI()

end)

print("[FVP] Complete system loaded.") print("[FVP] F = ARM / DISARM")
