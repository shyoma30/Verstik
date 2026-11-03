local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local FOLDER, FILE = "versik", "versik/key.txt"

-- fs helpers (executor workspace)
local function ensureFolder()
    pcall(function()
        if isfolder and not isfolder(FOLDER) then makefolder(FOLDER) end
    end)
end

local function readKey()
    local ok, data = pcall(function()
        if isfile and isfile(FILE) then return readfile(FILE) end
    end)
    if ok and type(data) == "string" then
        data = data:gsub("%s+", "")
        if data ~= "" then return data end
    end
end

local function saveKey(k)
    ensureFolder()
    pcall(writefile, FILE, k)
end

local function wipeKey()
    pcall(function() if isfile and isfile(FILE) then delfile(FILE) end end)
end

-- auth lib
local okLib, PUSL = pcall(function()
    return loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
end)
if not okLib or type(PUSL) ~= "table" or type(PUSL.configure) ~= "function" then
    return warn("[Panda] Library failed to initialize.")
end
PUSL.configure({ serviceId = "verstik" })

local function check(k)
    local ok, res = pcall(PUSL.validate, k)
    return ok and type(res) == "table" and res.success == true
end

-- main payload
local function runMain()
    print("[Panda] Key validated.")
    local games = {
        [142823291]       = "https://pastebin.com/raw/sCTg2jJc", -- mm2
        [107535308163741] = "https://your-real-url-here",
        [537413528]       = "https://your-real-url-here",
    }
    local url = games[game.PlaceId]
    if not url then return warn("[Panda] Unsupported place: " .. game.PlaceId) end
    local fn = loadstring(game:HttpGet(url))
    if fn then fn() else warn("[Panda] Game script failed to compile.") end
end

-- 1) env key, 2) saved key, 3) UI
local envKey = getgenv().verstik
if type(envKey) == "string" and envKey ~= "" and check(envKey) then
    saveKey(envKey)
    return runMain()
end

local saved = readKey()
if saved then
    if check(saved) then return runMain() end
    wipeKey() -- expired or revoked
end

-- UI
local parent = (gethui and gethui()) or game:GetService("CoreGui")
if not pcall(function() return parent.Name end) then parent = LocalPlayer.PlayerGui end

local old = parent:FindFirstChild("VersikKeyUI")
if old then old:Destroy() end

local function make(class, props, par)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = par
    return o
end

local gui = make("ScreenGui", {
    Name = "VersikKeyUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100,
}, parent)

local box = make("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(360, 210), BackgroundColor3 = Color3.fromRGB(10, 11, 24),
    BorderSizePixel = 0,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 14) }, box)
make("UIStroke", { Color = Color3.fromRGB(70, 140, 255), Thickness = 2 }, box)

local title = make("TextLabel", {
    Position = UDim2.fromOffset(20, 14), Size = UDim2.new(1, -40, 0, 26),
    BackgroundTransparency = 1, Text = "VERSIK HUB  ·  KEY",
    TextColor3 = Color3.fromRGB(245, 247, 255), TextSize = 18,
    Font = Enum.Font.GothamBlack, TextXAlignment = Enum.TextXAlignment.Left,
}, box)

local input = make("TextBox", {
    Position = UDim2.fromOffset(20, 56), Size = UDim2.new(1, -40, 0, 38),
    BackgroundColor3 = Color3.fromRGB(26, 28, 56), BorderSizePixel = 0,
    Text = "", PlaceholderText = "paste key here", PlaceholderColor3 = Color3.fromRGB(150, 156, 182),
    TextColor3 = Color3.fromRGB(245, 247, 255), TextSize = 13, Font = Enum.Font.Gotham,
    ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
}, box)
make("UICorner", { CornerRadius = UDim.new(0, 9) }, input)
make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, input)

local status = make("TextLabel", {
    Position = UDim2.fromOffset(20, 100), Size = UDim2.new(1, -40, 0, 18),
    BackgroundTransparency = 1, Text = "", TextSize = 11, Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(150, 156, 182), TextXAlignment = Enum.TextXAlignment.Left,
}, box)

local function button(text, x, w, color)
    local b = make("TextButton", {
        Position = UDim2.fromOffset(x, 140), Size = UDim2.fromOffset(w, 38),
        BackgroundColor3 = color, BorderSizePixel = 0, Text = text,
        TextColor3 = Color3.fromRGB(245, 247, 255), TextSize = 12,
        Font = Enum.Font.GothamBold, AutoButtonColor = true,
    }, box)
    make("UICorner", { CornerRadius = UDim.new(0, 9) }, b)
    return b
end

local submit  = button("VALIDATE", 20, 150, Color3.fromRGB(70, 140, 255))
local getKey  = button("GET KEY", 190, 150, Color3.fromRGB(26, 28, 56))

local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color or Color3.fromRGB(150, 156, 182)
end

-- drag
do
    local UIS = game:GetService("UserInputService")
    local dragging, start, startPos
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, startPos = true, i.Position, box.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            box.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

getKey.Activated:Connect(function()
    local ok, url = pcall(PUSL.getKeyUrl)
    if ok and type(url) == "string" then
        local copied = pcall(setclipboard, url)
        setStatus(copied and "Key link copied." or url, Color3.fromRGB(70, 140, 255))
    else
        setStatus("Couldn't get key link.", Color3.fromRGB(255, 75, 90))
    end
end)

local busy = false
local function attempt()
    if busy then return end
    local k = input.Text:gsub("%s+", "")
    if k == "" then return setStatus("Paste a key first.", Color3.fromRGB(255, 75, 90)) end

    busy = true
    setStatus("Validating...")
    task.spawn(function()
        if check(k) then
            saveKey(k)
            setStatus("Valid. Loading.", Color3.fromRGB(70, 220, 130))
            task.wait(0.4)
            gui:Destroy()
            local ok, err = pcall(runMain)
            if not ok then warn("[Panda] Script error: " .. tostring(err)) end
        else
            setStatus("Invalid or expired key.", Color3.fromRGB(255, 75, 90))
            busy = false
        end
    end)
end

submit.Activated:Connect(attempt)
input.FocusLost:Connect(function(enter) if enter then attempt() end end)
