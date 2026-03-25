request = request or http_request or syn.request

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local webhook = "https://discord.com/api/webhooks/1462962958299693141/rJtPJoLjpWSOHQ8ilzencmYJcQ_vfRqQsM5fzTVWvQ4A7gZwPiSo-KWI915D4kQc_G8-"

local cache = {}

local function sendWebhook(text)
    if cache[text] then return end
    cache[text] = true
    task.delay(5, function() cache[text] = nil end)

    request({
        Url = webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = "🎣 ULTRA RARE\n"..text
        })
    })
end

local function isUltra(text)
    text = tostring(text):lower()
    return text:find("secret") or text:find("forgotten")
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

PlayerGui.ChildAdded:Connect(function(gui)
    task.wait(0.2)
    scanUI(gui)
end)

local backpack = player:WaitForChild("Backpack")

backpack.ChildAdded:Connect(function(item)
    if isUltra(item.Name) then
        sendWebhook(item.Name)
    end
end)

print("🔥 GitHub Webhook aktif!")
