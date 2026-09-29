-- FVP DRONE - MOBILE ONLY CLEAN BUILD
-- Roblox LocalScript
-- Mobile controls only: joystick, yaw, throttle, disarm.
-- Touch input only.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local state = {
    active = false,
    pitch = 0,
    roll = 0,
    yaw = 0,
    throttle = 0,
    battery = 16.8,
    speed = 0,
    altitude = 0,
    started = 0,
    position = camera.CFrame.Position,
    velocity = Vector3.zero,
    yawAngle = 0,
    pitchAngle = 0,
    rollAngle = 0
}

local function new(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local gui = new("ScreenGui", {
    Name = "FVP_MobileOnly",
    ResetOnSpawn = false,
    IgnoreGuiInset = true
}, playerGui)

local root = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1
}, gui)

local menuButton = new("TextButton", {
    Size = UDim2.fromOffset(90, 44),
    Position = UDim2.fromOffset(12, 12),
    Text = "FVP",
    TextScaled = true,
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    TextColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0
}, root)

local menu = new("Frame", {
    Size = UDim2.fromOffset(300, 430),
    Position = UDim2.fromOffset(12, 62),
    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
    BorderSizePixel = 0,
    Visible = false
}, root)

new("TextLabel", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    Text = "FVP // HARDTEKK SONGS",
    TextColor3 = Color3.new(1, 1, 1),
    TextScaled = true
}, menu)

local startButton = new("TextButton", {
    Size = UDim2.new(1, -20, 0, 44),
    Position = UDim2.fromOffset(10, 50),
    Text = "START FVP",
    TextScaled = true,
    BackgroundColor3 = Color3.fromRGB(35, 120, 70),
    TextColor3 = Color3.new(1, 1, 1),
    BorderSizePixel = 0
}, menu)

local songs = {
    {"Sensitive", "113386216095936"},
    {"Toly Summer", "78474811337135"},
    {"Hardtekk Pro", "86503267790406"},
    {"Hi Roblox", "107094208500"},
    {"Holy War", "75485931767123"},
    {"I'm so fed up", "103072508653269"},
    {"VesNa", "139780461400228"},
    {"Walk in the park", "136362169566807"}
}

local music = new("Sound", {
    Name = "FVP_Music",
    Volume = 0.5,
    Looped = false
}, SoundService)

for index, song in ipairs(songs) do
    local button = new("TextButton", {
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.fromOffset(10, 102 + (index - 1) * 34),
        Text = song[1],
        TextScaled = true,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, menu)

    button.Activated:Connect(function()
        music.SoundId = "rbxassetid://" .. song[2]
        music:Play()
    end)
end

local osd = new("TextLabel", {
    Size = UDim2.fromOffset(285, 118),
    Position = UDim2.new(1, -297, 0, 12),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.3,
    TextColor3 = Color3.new(1, 1, 1),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextSize = 16,
    Text = "FVP OFF"
}, root)

local controls = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false
}, root)

local stickBase = new("Frame", {
    Size = UDim2.fromOffset(150, 150),
    Position = UDim2.new(0, 24, 1, -174),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0
}, controls)

local stick = new("Frame", {
    Size = UDim2.fromOffset(68, 68),
    Position = UDim2.fromOffset(41, 41),
    BackgroundColor3 = Color3.fromRGB(90, 90, 90),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0
}, stickBase)

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local stickTouch = nil

local function updateStick(position)
    local center = stickBase.AbsolutePosition + stickBase.AbsoluteSize / 2
    local dx = position.X - center.X
    local dy = position.Y - center.Y
    local radius = 50
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > radius then
        dx = dx / distance * radius
        dy = dy / distance * radius
    end

    stick.Position = UDim2.fromOffset(41 + dx, 41 + dy)
    state.roll = clamp(dx / radius, -1, 1)
    state.pitch = clamp(-dy / radius, -1, 1)
end

stickBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        stickTouch = input
        updateStick(input.Position)
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if input == stickTouch then
        updateStick(input.Position)
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    if input == stickTouch then
        stickTouch = nil
        stick.Position = UDim2.fromOffset(41, 41)
        state.pitch = 0
        state.roll = 0
    end
end)

local function makeControlButton(text, position, size)
    return new("TextButton", {
        Size = size,
        Position = position,
        Text = text,
        TextScaled = true,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    }, controls)
end

local yawLeft = makeControlButton(
    "↶",
    UDim2.new(1, -165, 1, -132),
    UDim2.fromOffset(70, 54)
)

local yawRight = makeControlButton(
    "↷",
    UDim2.new(1, -85, 1, -132),
    UDim2.fromOffset(70, 54)
)

local throttleUp = makeControlButton(
    "THR +",
    UDim2.new(1, -175, 1, -70),
    UDim2.fromOffset(80, 50)
)

local throttleDown = makeControlButton(
    "THR -",
    UDim2.new(1, -85, 1, -70),
    UDim2.fromOffset(80, 50)
)

local disarm = makeControlButton(
    "DISARM",
    UDim2.new(0.5, -50, 1, -60),
    UDim2.fromOffset(100, 45)
)

local function hold(button, field, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            state[field] = value
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            state[field] = 0
        end
    end)
end

-- IMPORTANT: yaw buttons change yaw; throttle buttons change throttle.
hold(yawLeft, "yaw", -1)
hold(yawRight, "yaw", 1)
hold(throttleUp, "throttle", 1)
hold(throttleDown, "throttle", -1)

local function stopDrone()
    state.active = false
    state.pitch = 0
    state.roll = 0
    state.yaw = 0
    state.throttle = 0
    controls.Visible = false
    menu.Visible = true
end

local function startDrone()
    state.active = true
    state.battery = 16.8
    state.speed = 0
    state.started = os.clock()
    state.position = camera.CFrame.Position
    state.velocity = Vector3.zero
    state.yawAngle = 0
    state.pitchAngle = 0
    state.rollAngle = 0
    state.throttle = 0
    menu.Visible = false
    controls.Visible = true
end

startButton.Activated:Connect(startDrone)
disarm.Activated:Connect(stopDrone)

menuButton.Activated:Connect(function()
    menu.Visible = not menu.Visible
end)

RunService.RenderStepped:Connect(function(dt)
    if not state.active then
        osd.Text = "FVP OFF"
        return
    end

    -- Convert button input into a persistent throttle level.
    local throttleRate = 0.55
    state.throttleLevel = clamp(
        (state.throttleLevel or 0) + state.throttle * throttleRate * dt,
        0,
        1
    )

    local cameraForward = camera.CFrame.LookVector
    local cameraRight = camera.CFrame.RightVector

    local horizontal =
        cameraForward * (-state.pitch) +
        cameraRight * state.roll

    state.velocity += horizontal * 70 * dt
    state.velocity += Vector3.new(
        0,
        (state.throttleLevel * 115 - 38) * dt,
        0
    )

    state.velocity *= math.max(0, 1 - dt * 1.7)
    state.position += state.velocity * dt

    state.yawAngle += state.yaw * dt * 1.8
    state.pitchAngle = clamp(
        state.pitchAngle + state.pitch * dt * 1.4,
        -0.8,
        0.8
    )
    state.rollAngle = clamp(
        state.rollAngle + state.roll * dt * 1.4,
        -0.8,
        0.8
    )

    state.speed = state.velocity.Magnitude
    state.altitude = math.max(0, state.position.Y)
    state.battery = math.max(
        13.2,
        state.battery - dt * (0.018 + state.throttleLevel * 0.04)
    )

    camera.CFrame =
        CFrame.new(state.position) *
        CFrame.Angles(
            state.pitchAngle,
            state.yawAngle,
            state.rollAngle
        )

    local elapsed = math.floor(os.clock() - state.started)
    osd.Text = string.format(
        "FVP // ARM\nSPD: %03d\nALT: %03d\nBAT: %.1fV\nTHR: %02d%%\nTIME: %02d:%02d",
        state.speed,
        state.altitude,
        state.battery,
        (state.throttleLevel or 0) * 100,
        math.floor(elapsed / 60),
        elapsed % 60
    )
end)
