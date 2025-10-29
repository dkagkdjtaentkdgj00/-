local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    TPSBall = nil,
    ReachEnabled = false,
    ReachDistance = 5,
    LegSettings = {
        Right = true,
        Left = true
    },
    Notifications = true
}

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "ONSCF 2.0",
    LoadingTitle = "Onscf Utilities",
    LoadingSubtitle = "By chimpugugu",
    Theme = "DarkBlue",
    ConfigurationSaving = {Enabled = true, FolderName = "onscfConfig", FileName = "TPS_UI"},
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Variables
local character, humanoidRootPart
task.wait(1)

local function getCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

-- Define GetTPSBall function
local function GetTPSBall()
    -- Try multiple possible ball names and locations
    local ballNames = {"TPS", "PSoccerBall", "SoccerBall", "Ball", "Football"}
    
    for _, name in ipairs(ballNames) do
        -- Check in TPSSystem
        local tpsSystem = workspace:FindFirstChild("TPSSystem")
        if tpsSystem then
            local ball = tpsSystem:FindFirstChild(name)
            if ball and ball:IsA("BasePart") then
                Config.TPSBall = ball
                return ball
            end
        end
        
        -- Check in Practice
        local practice = workspace:FindFirstChild("Practice")
        if practice then
            for _, obj in pairs(practice:GetChildren()) do
                if obj.Name == name and obj:IsA("BasePart") then
                    Config.TPSBall = obj
                    return obj
                end
            end
        end
        
        -- Check in workspace directly
        local ball = workspace:FindFirstChild(name)
        if ball and ball:IsA("BasePart") then
            Config.TPSBall = ball
            return ball
        end
    end
    
    -- Search all parts for something that looks like a ball
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name:lower():find("ball") or obj.Name:lower():find("tps")) then
            Config.TPSBall = obj
            return obj
        end
    end
    
    Config.TPSBall = nil
    return nil
end

getCharacter()
LocalPlayer.CharacterAdded:Connect(getCharacter)
LocalPlayer.CharacterRemoving:Connect(function()
    character = nil
    humanoidRootPart = nil
end)

-- Body parts for targeting
local bodyParts = {"Right Leg", "Left Leg", "Torso", "HumanoidRootPart", "Head", "Right Arm", "Left Arm"}

-- Create tabs
local ReactTab = Window:CreateTab("React")
local TeleporterTab = Window:CreateTab("Teleporter")
local MiscTab = Window:CreateTab("Miscellaneous")
local BallModTab = Window:CreateTab("Ball Modifications")
local ResolutionTab = Window:CreateTab("Resolution & FOV")
local ClumsyTab = Window:CreateTab("Clumsy")
local SpooferTab = Window:CreateTab("Spoofer")

ReactTab:CreateParagraph({
    Title = "FUCK MARS",
    Content = "zekite cant even protect his script 🤣"
})
-- React Tab
ReactTab:CreateSection("Main")
ReactTab:CreateDivider()


local function ExecuteReach()
    if not Config.ReachEnabled or not character or not humanoidRootPart then return end
    
    local ball = GetTPSBall()
    if not ball then return end
    
    local distance = (ball.Position - humanoidRootPart.Position).Magnitude
    if distance > Config.ReachDistance then return end
    
    -- Fire touch interest on body parts
    local function fireTouch(part)
        if part and part:IsA("BasePart") then
            pcall(function()
                firetouchinterest(part, ball, 0) -- Touch began
                task.wait()
                firetouchinterest(part, ball, 1) -- Touch ended
            end)
        end
    end
    
    -- Fire touch on selected body parts
    if Config.LegSettings.Right then
        local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
        if rightLeg then fireTouch(rightLeg) end
    end
    
    if Config.LegSettings.Left then
        local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
        if leftLeg then fireTouch(leftLeg) end
    end
end

RunService.Heartbeat:Connect(function()
    if not Config.TPSBall or not Config.TPSBall.Parent then
        GetTPSBall()
    end
end)

RunService.RenderStepped:Connect(function()
    if Config.ReachEnabled then pcall(ExecuteReach) end
end)

ReactTab:CreateToggle({
    Name = "Enable Firetouch",
    CurrentValue = false,
    Callback = function(value)
        Config.ReachEnabled = value
        if Config.Notifications then
            Rayfield:Notify({Title="Reach", Content=value and "Reach Enabled" or "Reach Disabled", Duration=2})
        end
    end
})

ReactTab:CreateSlider({
    Name = "Firetouch",
    Range = {1,10},
    Increment = 0.2,
    Suffix = "Magnitude",
    CurrentValue = Config.ReachDistance,
    Callback = function(value)
        Config.ReachDistance = value
        if Config.Notifications then
            Rayfield:Notify({Title="Reach Distance", Content="Distance set to "..value.." studs", Duration=2})
        end
    end
})

ReactTab:CreateToggle({
    Name = "Use Right Leg",
    CurrentValue = Config.LegSettings.Right,
    Callback = function(value)
        Config.LegSettings.Right = value
    end
})

ReactTab:CreateToggle({
    Name = "Use Left Leg",
    CurrentValue = Config.LegSettings.Left,
    Callback = function(value)
        Config.LegSettings.Left = value
    end
})

ReactTab:CreateButton({
    Name = "Find Ball Manually",
    Callback = function()
        local ball = GetTPSBall()
        if ball then
            Rayfield:Notify({
                Title = "Ball Found",
                Content = "Found: " .. ball.Name,
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Ball Not Found",
                Content = "Could not locate any ball",
                Duration = 3
            })
        end
    end
})

ReactTab:CreateSection("Reacts")
ReactTab:CreateDivider()

-- Ball interaction system
local function onBallTouch(ball, tool, targetParts)
    if not character or not humanoidRootPart then return end
    
    for _, partName in ipairs(targetParts) do
        local part = character:FindFirstChild(partName)
        if part then
            ball.CFrame = part.CFrame
            ball.Velocity = Vector3.new(1, 1, 1)
        end
    end
end

-- the main react
ReactTab:CreateButton({
    Name = "Main React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(2, 2, 2)
            end
        end)

        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(2, 2, 2)
                    end
                end
            end
        end)
    end
})

-- React Kill
ReactTab:CreateButton({
    Name = "React Kill (ballsound gone)",
    Callback = function()
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if not checkcaller() and getnamecallmethod() == "FireServer" and self == workspace.FE.Scorer.RemoteEvent then
                for i = 1, 10 do
                    if workspace:FindFirstChild("FE") then
                        local fe = workspace.FE
                        if fe:FindFirstChild("Keep") and fe.Keep:FindFirstChild("GK") then
                            pcall(function() fe.Keep.GK:FireServer(unpack(args)) end)
                        end
                        if fe:FindFirstChild("GK") then
                            if fe.GK:FindFirstChild("BGKSaves") then pcall(function() fe.GK.BGKSaves:FireServer(unpack(args)) end) end
                            if fe.GK:FindFirstChild("BGKP") then pcall(function() fe.GK.BGKP:FireServer(unpack(args)) end) end
                            if fe.GK:FindFirstChild("GGKP") then pcall(function() fe.GK.GGKP:FireServer(unpack(args)) end) end
                        end
                    end
                end
                return
            end
            return oldNC(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
})

-- Alternative React options
ReactTab:CreateSection("ALTERNATIVES")
ReactTab:CreateDivider()

ReactTab:CreateButton({
    Name = "Prztxl React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(2.5, 2.5, 2.5)
            end
        end)

        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(2.5, 2.5, 2.5)
                    end
                end
            end
        end)
    end
})

ReactTab:CreateButton({
    Name = "Mars React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(3, 3, 3)
            end
        end)

        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(3, 3, 3)
                    end
                end
            end
        end)
    end
})

ReactTab:CreateButton({
    Name = "Sourenos React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(1.5, 1.5, 1.5)
            end
        end)

        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(1.5, 1.5, 1.5)
                    end
                end
            end
        end)
    end
})

ReactTab:CreateButton({
    Name = "Dreelovv React",
    Callback = function()
        pcall(function()
            local tpsPart = workspace.TPSSystem and workspace.TPSSystem:FindFirstChild("TPS")
            if tpsPart then
                tpsPart.Velocity = Vector3.new(3.5, 3.5, 3.5)
            end
        end)

        pcall(function()
            for _, ball in pairs(workspace.Practice:GetChildren()) do
                if ball.Name == "PSoccerBall" and ball:IsA("BasePart") then
                    if ball and ball.Parent then
                        ball.Velocity = Vector3.new(3.5, 3.5, 3.5)
                    end
                end
            end
        end)
    end
})

-- Teleporter Tab
TeleporterTab:CreateButton({
    Name = "Free Teleporter Gamepass",
    Callback = function()
        local gkSystem = Workspace:FindFirstChild("GKSystem")
        if not gkSystem then
            Rayfield:Notify({
                Title = "Error",
                Content = "Teleportation failed.",
                Duration = 3,
                Image = 4483362458
            })
            return
        end
        
        local playerTeam = LocalPlayer.Team.Name
        local targetSide = playerTeam == "Blue Side" and "Green Side" or "Blue Side"
        
        for _, obj in ipairs(gkSystem:GetChildren()) do
            if obj:FindFirstChild("FixPK") and obj:IsA("BasePart") then
                character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                
                local ff = Instance.new("ForceField")
                ff.Parent = character
                
                task.wait(0.1)
                ff:Destroy()
                break
            end
        end
        
        Rayfield:Notify({
            Title = "Teleported",
            Content = "You have been teleported using the free teleporter.",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Miscellaneous Tab
MiscTab:CreateButton({
    Name = "React, FOV, Ball Texture, Ball Sound (ethernality.wtf)",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/8Jp2M7yg"))()
    end,
})

MiscTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- Ball Modifications Tab
BallModTab:CreateSection("BALL MODIFICATION")
BallModTab:CreateDivider()

local BallSize = 2
BallModTab:CreateSlider({
    Name = "Adjust Ball Size",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "studs",
    CurrentValue = 2,
    Flag = "BallSizeSlider",
    Callback = function(value)
        BallSize = value
    end,
})

-- Resolution & FOV Tab
getgenv().Resolution = ".gg/scripters"

ResolutionTab:CreateToggle({
    Name = "Enable Stretched Resolution",
    CurrentValue = false,
    Flag = "StretchedResolutionToggle",
    Callback = function(value)
        getgenv().Resolution = {
            [".gg/scripters"] = 0.65
        }

        local Camera = workspace.CurrentCamera
        if getgenv().gg_scripters == nil then
            game:GetService("RunService").RenderStepped:Connect(
                function()
                    Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
                end
            )
        end
        getgenv().gg_scripters = "Aori0001"
    end,
})

ResolutionTab:CreateSlider({
    Name = "Field of View",
    Range = {1, 120},
    Increment = 1,
    Suffix = "FOV",
    CurrentValue = Workspace.CurrentCamera.FieldOfView,
    Flag = "FOVSlider",
    Callback = function(value)
        Workspace.CurrentCamera.FieldOfView = value
    end,
})

-- Clumsy Tab
ClumsyTab:CreateInput({
    Name = "Clumsy",
    PlaceholderText = "Enter lag value",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        local lagValue = tonumber(text)
        if lagValue then
            settings():GetService("NetworkSettings").IncomingReplicationLag = lagValue
            Rayfield:Notify({
                Title = "Clumsy",
                Content = "Incoming replication lag set to " .. lagValue,
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Spoofer Tab
SpooferTab:CreateInput({
    Name = "Set XP Value ( PATCHED )",
    CurrentValue = "0",
    PlaceholderText = "Enter XP Value",
    RemoveTextAfterFocusLost = true,
    Flag = "XPInput",
    Callback = function(text)
        -- XP spoofing logic
    end,
})