print("versik loader v5")
local KEY_FILE = "versik/key.txt"
local DEFAULT_URL = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/AP.lua"

local function trim(s)
    return (tostring(s or ""):gsub("%s+", ""))
end

local ok, Panda = pcall(function()
    return loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
end)
if not ok or type(Panda) ~= "table" then
    return warn("[Panda] Library failed to initialize.")
end
pcall(Panda.configure, { serviceId = "verstik" })

-- tries dot-call first, then colon-call, so either API style works
local function validKey(k)
    if k == "" then return false end
    local ok, res = pcall(Panda.validate, k)
    if not (ok and type(res) == "table") then
        ok, res = pcall(Panda.validate, Panda, k)
    end
    return ok and type(res) == "table" and res.success == true
end

local function saveKey(k)
    pcall(function()
        if not isfolder("versik") then makefolder("versik") end
        writefile(KEY_FILE, k)
    end)
end

local function loadSavedKey()
    local ok, data = pcall(function()
        if isfile and isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    return ok and trim(data) or ""
end

local function runPayload()
    local urls = {
        [142823291] = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/mm2.lua",
        [155615604] = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/Prisonlife.lua",
        [107535308163741] = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/huss-valley.lua",
        [286090429] = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/Arsenal"
    }
    local url = urls[game.PlaceId] or DEFAULT_URL
    local ok, src = pcall(game.HttpGet, game, url)
    if not ok then return warn("[Panda] Fetch failed: " .. tostring(src)) end
    local fn, err = loadstring(src)
    if not fn then return warn("[Panda] Compile failed: " .. tostring(err)) end
    local ok2, e = xpcall(fn, debug.traceback)
    if not ok2 then warn("[Panda] Script error: " .. tostring(e)) end
end

local function showKeyUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "VersikKeyUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true

    local parent
    pcall(function() if gethui then parent = gethui() end end)
    if not parent then
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        parent = ok and cg or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 150)
    frame.Position = UDim2.new(0.5, -160, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Versik | Enter Key"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -30, 0, 32)
    box.Position = UDim2.fromOffset(15, 38)
    box.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    box.BorderSizePixel = 0
    box.PlaceholderText = "paste key"
    box.Text = ""
    box.ClearTextOnFocus = false
    box.TextColor3 = Color3.new(1, 1, 1)
    box.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -30, 0, 16)
    status.Position = UDim2.fromOffset(15, 76)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 90, 90)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 32)
    btn.Position = UDim2.fromOffset(15, 102)
    btn.BackgroundColor3 = Color3.fromRGB(70, 110, 255)
    btn.BorderSizePixel = 0
    btn.Text = "VALIDATE"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local busy = false
    local function submit()
        if busy then return end
        busy = true
        status.TextColor3 = Color3.fromRGB(200, 200, 210)
        status.Text = "checking..."
        local k = trim(box.Text)
        if validKey(k) then
            saveKey(k)
            gui:Destroy()
            runPayload()
        else
            status.TextColor3 = Color3.fromRGB(255, 90, 90)
            status.Text = "invalid key"
            busy = false
        end
    end

    btn.MouseButton1Click:Connect(submit)
    box.FocusLost:Connect(function(enter) if enter then submit() end end)
end

local genv = (getgenv and getgenv()) or _G
local key = trim(genv.verstik)
if not validKey(key) then
    key = loadSavedKey()
    if not validKey(key) then return showKeyUI() end
end
saveKey(key)
runPayload()
