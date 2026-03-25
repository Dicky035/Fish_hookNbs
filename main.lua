request = request or http_request or syn.request

if not request then
    warn("Executor tidak support HTTP Request")
    return
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

-- 📁 FILE SAVE
local fileName = "fish_webhook.txt"
local webhook = ""

if isfile and isfile(fileName) then
    webhook = readfile(fileName)
end

local function saveWebhook(url)
    if writefile then
        writefile(fileName, url)
        print("Webhook tersimpan!")
    end
end

-- 🎯 RARITY
local rarityEnabled = {
    secret = true,
    forgotten = true,
    mythic = true,
    legendary = true
}

local cache = {}

-- 🧠 EXTRACT INFO IKAN
local function extractInfo(text)
    text = tostring(text)

    local name = text
    local weight = text:match("(%d+%.?%d*%s?kg)")
    local mutation = text:match("[Mm]utation[:%s]+([%w%s]+)")

    local result = "🐟 "..name

    if weight then
        result = result .. "\n⚖️ "..weight
    end

    if mutation then
        result = result .. "\n✨ "..mutation
    end

    return result
end

-- 📡 SEND WEBHOOK
local function sendWebhook(text)
    if webhook == "" then return end

    local info = extractInfo(text)

    if cache[info] then return end
    cache[info] = true
    task.delay(5, function() cache[info] = nil end)

    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = "🎣 NBS FISH LOG\n"..info
        })
    })

    -- update UI log
    if logBox then
        logBox.Text = info
    end
end

local function isUltra(text)
    text = tostring(text):lower()

    for rarity, enabled in pairs(rarityEnabled) do
        if enabled and text:find(rarity) then
            return true
        end
    end

    return false
end

local function scanUI(gui)
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            if isUltra(v.Text) then
                sendWebhook(v.Text)
            end
        end
    end
end

-- 🔥 UI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "NBS_UI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 360)
main.Position = UDim2.new(0.35, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(20,20,25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- HEADER
local header = Instance.new("TextLabel", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundTransparency = 1
header.Text = "NBS PANEL"
header.TextColor3 = Color3.fromRGB(0,255,150)
header.Font = Enum.Font.GothamBold
header.TextSize = 20

-- INPUT
local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-20,0,35)
input.Position = UDim2.new(0,10,0,50)
input.Text = webhook
input.PlaceholderText = "Webhook..."
input.BackgroundColor3 = Color3.fromRGB(30,30,35)
input.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", input)

-- SAVE
local save = Instance.new("TextButton", main)
save.Size = UDim2.new(1,-20,0,30)
save.Position = UDim2.new(0,10,0,90)
save.Text = "SAVE WEBHOOK"
save.BackgroundColor3 = Color3.fromRGB(0,200,120)
Instance.new("UICorner", save)

save.MouseButton1Click:Connect(function()
    webhook = input.Text
    saveWebhook(webhook)
end)

-- TEST
local test = Instance.new("TextButton", main)
test.Size = UDim2.new(1,-20,0,30)
test.Position = UDim2.new(0,10,0,130)
test.Text = "TEST WEBHOOK"
test.BackgroundColor3 = Color3.fromRGB(0,150,255)
Instance.new("UICorner", test)

test.MouseButton1Click:Connect(function()
    sendWebhook("TEST MESSAGE ✅")
end)

-- RARITY
local y = 170
for rarity,_ in pairs(rarityEnabled) do
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,28)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = "ON "..rarity
    btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        rarityEnabled[rarity] = not rarityEnabled[rarity]
        btn.Text = (rarityEnabled[rarity] and "ON " or "OFF ")..rarity
    end)

    y = y + 32
end

-- 📊 LOG BOX
logBox = Instance.new("TextLabel", main)
logBox.Size = UDim2.new(1,-20,0,60)
logBox.Position = UDim2.new(0,10,1,-70)
logBox.BackgroundColor3 = Color3.fromRGB(25,25,30)
logBox.TextColor3 = Color3.new(1,1,1)
logBox.TextScaled = true
logBox.Text = "No Fish Yet..."
Instance.new("UICorner", logBox)

-- DETECTION
PlayerGui.ChildAdded:Connect(function(gui)
    task.spawn(function()
        for i = 1,5 do
            scanUI(gui)
            task.wait(0.5)
        end
    end)
end)

backpack.ChildAdded:Connect(function(item)
    if isUltra(item.Name) then
        sendWebhook(item.Name)
    end
end)

print("🔥 NBS FINAL VERSION AKTIF!")
