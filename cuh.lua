local Success, Error = pcall(function()

    repeat wait() until game:IsLoaded()

    if is_sirhurt_closure then
        error("Hi sirhurt user, fnaf ur self.")
    end

    -- #region // No Console Log    
    game:GetService("RunService").RenderStepped:Connect(function()
        for _, Connection in next, getconnections(game:GetService("ScriptContext").Error) do
            Connection:Disable()
        end
        
        for _, Connection in next, getconnections(game:GetService("LogService").MessageOut) do
            Connection:Disable()
        end
    end)
    -- #endregion

    -- #region // Services

    local game                              = game;
    local GetService                        = game.GetService;

    local Workspace                         = GetService(game, "Workspace");
    local Players                           = GetService(game, "Players");
    local ReplicatedStorage                 = GetService(game, "ReplicatedStorage");
    local StarterGui                        = GetService(game, "StarterGui");

    local LogService                        = GetService(game, "LogService");
    local HttpService                       = GetService(game, "HttpService");
    local ScriptContext                     = GetService(game, "ScriptContext");

    -- #endregion

    -- #region // Variables

    local Settings                          = { GunMods = { NoRecoil = false, InstantEquip = false, Spread = false, AutoMode = false, SpreadAmount = 0 }, DownedChat = false, KillChat = false, DownedMSG = "", KillMSG = "", IsDead = true, AutoPickCash = false, AutoPickTools = false, AutoPickScrap = false, InfiniteStamina = false, NoJumpCooldown = false, NoFailLockpick = false, ShowChatLogs = false, NoFlashbang  = false, NoSmoke = false, UnlockDoorsNearby = false, OpenDoorsNearby = false, FullBright = false, CamFovToggled = false, CamFov = 70, InfinitePepperSpray = false, PepperSprayAura = false, WalkSpeed = {Enabled = false, Amount = 16}, JumpPower = {Enabled = false, Amount = 50} };
    local ESPSettings                       = { PlayerESP = { TracersOn = false, BoxesOn = false, NamesOn = false, FaceCamOn = false }, ScrapESP = { Enabled = false, Distance = 500, RareOnly = false, GoodOnly = false, BadOnly = false }, SafeESP = { Enabled = false, Distance = 500, BigOnly = false, SmallOnly = false }, RegisterESP = { Enabled = false, Distance = 500 } };

        -- #region Silent Aim
        local SilentSettings                    = { Main = { Enabled = false, TeamCheck = false, VisibleCheck = false, TargetPart = "Torso" }, FOVSettings = { Visible = true, Radius = 80 } };
        local ValidTargetParts                  = {"Head", "Torso"};

        local Player                            = Players.LocalPlayer;
        local Character                         = Player.Character;
        local Mouse                             = Player:GetMouse()
        local Cam                               = workspace.CurrentCamera;

        local WorldToScreen                     = Cam.WorldToScreenPoint
        local WorldToViewportPoint              = Cam.WorldToViewportPoint
        local GetPartsObscuringTarget           = Cam.GetPartsObscuringTarget

        local RequiredArgs = {
            ArgCountRequired = 3,
            Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
            }
        }

        local SilentAIMFov = Drawing.new("Circle")
        SilentAIMFov.Thickness = 1
        SilentAIMFov.NumSides = 100
        SilentAIMFov.Radius = 180
        SilentAIMFov.Filled = false
        SilentAIMFov.Visible = false
        SilentAIMFov.ZIndex = 999
        SilentAIMFov.Transparency = 1
        SilentAIMFov.Color = _G.CriminalityInfo.SilentAimColor
        SilentSettings.Visible = false
        -- #endregion

    while not Character or not Character.Parent do
        Character = Player.Character
        wait()
    end

    -- #endregion

    -- #region // Functions
    function JoinDiscord()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JackeyBot/Aurora-Hub/main/Essentials/Autojoin.lua"))()
    end

    function BypassAnticheat()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JackeyBot/Aurora-Hub/main/Essentials/CriminalityACBypass.lua"))()
    end

        -- #region Silent Aim Functions
        local function GetPositionOnScreen(Vector)
            local Vec3, OnScreen = WorldToScreen(Cam, Vector)
            return Vector2.new(Vec3.X, Vec3.Y), OnScreen
        end
        
        local function ValidateArguments(Args, RayMethod)
            local Matches = 0

            if #Args < RayMethod.ArgCountRequired then
                return false
            end

            for Pos, Argument in next, Args do
                if typeof(Argument) == RayMethod.Args[Pos] then
                    Matches = Matches + 1
                end
            end

            return Matches >= RayMethod.ArgCountRequired
        end
        
        local function GetDirection(Origin, Position)
            return (Position - Origin).Unit * 1000
        end
        
        local function GetMousePosition()
            return Vector2.new(Mouse.X, Mouse.Y)
        end
        
        local function IsPlayerVisible(TargetPlayer)
            local PlayerCharacter = TargetPlayer.Character
            local LocalPlayerCharacter = Player.Character
            
            if not (PlayerCharacter or LocalPlayerCharacter) then return end 
            
            local PlayerRoot = game.FindFirstChild(PlayerCharacter, SilentSettings.Main.TargetPart) or game.FindFirstChild(PlayerCharacter, "HumanoidRootPart")
            
            if not PlayerRoot then return end 
            
            local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
            local ObscuringObjects = #GetPartsObscuringTarget(Cam, CastPoints, IgnoreList)
            
            return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
        end
        
        local function GetClosestPlayer()
            if not SilentSettings.Main.TargetPart then return end

            local Closest
            local DistanceToMouse

            for _, v in next, game.GetChildren(Players) do
                if v == Player then continue end
                if SilentSettings.Main.TeamCheck and v.Team == Player.Team then continue end
        
                local Character = v.Character
                if not Character then continue end
                
                if SilentSettings.Main.VisibleCheck and not IsPlayerVisible(v) then continue end
        
                local HumanoidRootPart = game.FindFirstChild(Character, "HumanoidRootPart")
                local Humanoid = game.FindFirstChild(Character, "Humanoid")
        
                if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end
        
                local ScreenPosition, OnScreen = GetPositionOnScreen(HumanoidRootPart.Position)
        
                if not OnScreen then continue end
        
                local Distance = (GetMousePosition() - ScreenPosition).Magnitude
                if Distance <= (DistanceToMouse or (SilentSettings.Main.Enabled and SilentSettings.FOVSettings.Radius) or 2000) then
                    Closest = ((SilentSettings.Main.TargetPart == "Random" and Character[ValidTargetParts[math.random(1, #ValidTargetParts)]]) or Character[SilentSettings.Main.TargetPart])
                    DistanceToMouse = Distance
                end
            end
            return Closest
        end
        -- #endregion

    -- #endregion

    if game:IsLoaded() then BypassAnticheat() JoinDiscord() end

    -- #region // Esp Handlers
    
        -- #region // ScrapESP 
        local function ScrapESP(Scrap)
            local ItemName = Drawing.new("Text")
            ItemName.Visible = false
            ItemName.Center = true
            ItemName.Outline = true
            ItemName.Font = 2
            ItemName.Size = 13
            ItemName.Color = Color3.new(1, 2.5, 2.5)
            ItemName.Text = "Scrap"
        
            local RarityText = Drawing.new("Text")
            RarityText.Visible = false
            RarityText.Center = true
            RarityText.Outline = true
            RarityText.Font = 2
            RarityText.Size = 13
            RarityText.Color = Color3.new(1, 2.5, 2.5)
            RarityText.Text = "Type"
        
            local DistanceText = Drawing.new("Text")
            DistanceText.Visible = false
            DistanceText.Center = true
            DistanceText.Outline = true
            DistanceText.Font = 2
            DistanceText.Size = 13
            DistanceText.Color = Color3.new(1, 2.5, 2.5)
            DistanceText.Text = "Distance"
        
            local function InfoUpdate()
                local Iu
        
                Iu = game:GetService("RunService").RenderStepped:Connect(function()
                    if not workspace:IsAncestorOf(Scrap) then
                        ItemName.Visible = false
                        RarityText.Visible = false
                        DistanceText.Visible = false
        
                        Iu:Disconnect()
                    else
                        local Vector, OnScreen = Cam:WorldToViewportPoint(Scrap:FindFirstChild("MeshPart").Position)
        
                        if OnScreen then
                            ItemName.Position = Vector2.new(Vector.X, Vector.Y - 30)
                            RarityText.Position = Vector2.new(Vector.X, Vector.Y - 20)
                            DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)
        
                            ItemName.Visible = false
                            RarityText.Visible = false
                            DistanceText.Visible = false
        
                            local ItemDistance = math.ceil((Scrap.MeshPart.Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)
        
                            if ESPSettings.ScrapESP.Enabled == true then
                                if ItemDistance < ESPSettings.ScrapESP.Distance then
                                    if tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 1 1 1 0 1 1 1 1 0 " then
                                        RarityText.Text = "Rarity: Bad"
                                        RarityText.Color = Color3.new(1, 2.5, 2.5)
            
                                        if ESPSettings.ScrapESP.BadOnly == true then
                                            ItemName.Visible = true
                                            RarityText.Visible = true
                                            DistanceText.Visible = true
                                        else
                                            ItemName.Visible = false
                                            RarityText.Visible = false
                                            DistanceText.Visible = false
                                        end
                                    elseif tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 0.184314 1 0.4 0 1 0.184314 1 0.4 0 " then
                                        RarityText.Text = "Rarity: Good"
                                        RarityText.Color = Color3.new(0, 2.5, 0)
            
                                        if ESPSettings.ScrapESP.GoodOnly == true then
                                            ItemName.Visible = true
                                            RarityText.Visible = true
                                            DistanceText.Visible = true
                                        else
                                            ItemName.Visible = false
                                            RarityText.Visible = false
                                            DistanceText.Visible = false
                                        end
                                    elseif tostring(Scrap:FindFirstChild("MeshPart"):FindFirstChild("Particle").Color) == "0 1 0.184314 0.184314 0 1 1 0.184314 0.184314 0 " then
                                        RarityText.Text = "Rarity: Rare"
                                        RarityText.Color = Color3.new(1, 0, 0)
            
                                        if ESPSettings.ScrapESP.RareOnly == true then
                                            ItemName.Visible = true
                                            RarityText.Visible = true
                                            DistanceText.Visible = true
                                        else
                                            ItemName.Visible = false
                                            RarityText.Visible = false
                                            DistanceText.Visible = false
                                        end
                                    end
                
                                    DistanceText.Text = "["..tostring(ItemDistance).."]"
                                else
                                    ItemName.Visible = false
                                    RarityText.Visible = false
                                    DistanceText.Visible = false
                                end
                            else
                                ItemName.Visible = false
                                RarityText.Visible = false
                                DistanceText.Visible = false

                                Iu:Disconnect()
                            end
                        else
                            ItemName.Visible = false
                            RarityText.Visible = false
                            DistanceText.Visible = false
                        end
                    end
                end)
            end
            coroutine.wrap(InfoUpdate)()
        end
        -- #endregion
        
        -- #region // SafeESP 
        local function SafeESP(Vault, RarityValue)
            local ItemName = Drawing.new("Text")
            ItemName.Visible = false
            ItemName.Center = true
            ItemName.Outline = true
            ItemName.Font = 2
            ItemName.Size = 13
            ItemName.Color = Color3.new(1, 2.5, 2.5)
            ItemName.Text = "Safe"
        
            local RarityText = Drawing.new("Text")
            RarityText.Visible = false
            RarityText.Center = true
            RarityText.Outline = true
            RarityText.Font = 2
            RarityText.Size = 13
            RarityText.Color = Color3.new(1, 2.5, 2.5)
            RarityText.Text = "Type"
        
            local StatusText = Drawing.new("Text")
            StatusText.Visible = false
            StatusText.Center = true
            StatusText.Outline = true
            StatusText.Font = 2
            StatusText.Size = 13
            StatusText.Color = Color3.new(1, 2.5, 2.5)
            StatusText.Text = "Status"
        
            local DistanceText = Drawing.new("Text")
            DistanceText.Visible = false
            DistanceText.Center = true
            DistanceText.Outline = true
            DistanceText.Font = 2
            DistanceText.Size = 13
            DistanceText.Color = Color3.new(1, 2.5, 2.5)
            DistanceText.Text = "Distance"
        
            local function InfoUpdate()
                local Iu
        
                Iu = game:GetService("RunService").RenderStepped:Connect(function()
                    if not workspace:IsAncestorOf(Vault) then
                        ItemName.Visible = false
                        RarityText.Visible = false
                        StatusText.Visible = false
                        DistanceText.Visible = false
        
                        Iu:Disconnect()
                    else
                        local Vector, OnScreen = Cam:WorldToViewportPoint(Vault:FindFirstChild("MainPart").Position)
        
                        if OnScreen then
                            ItemName.Position = Vector2.new(Vector.X, Vector.Y - 40)
                            RarityText.Position = Vector2.new(Vector.X, Vector.Y - 30)
                            StatusText.Position = Vector2.new(Vector.X, Vector.Y - 20)
                            DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)
        
                            ItemName.Visible = false
                            RarityText.Visible = false
                            StatusText.Visible = false
                            DistanceText.Visible = false
        
                            local ItemDistance = math.ceil((Vault:FindFirstChild("MainPart").Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)

                            if ESPSettings.SafeESP.Enabled == true then
                                if ItemDistance < ESPSettings.SafeESP.Distance then
                                    if RarityValue == 2 then
                                        RarityText.Text = "Rarity: Good"
                                        RarityText.Color = Color3.new(0, 2.5, 0)
            
                                        if ESPSettings.SafeESP.SmallOnly == true then
                                            ItemName.Visible = true
                                            RarityText.Visible = true
                                            StatusText.Visible = true
                                            DistanceText.Visible = true
                                        else
                                            ItemName.Visible = false
                                            RarityText.Visible = false
                                            StatusText.Visible = false
                                            DistanceText.Visible = false
                                        end
                                    elseif RarityValue == 3 then
                                        RarityText.Text = "Rarity: Rare"
                                        RarityText.Color = Color3.new(1, 0, 0)
            
                                        if ESPSettings.SafeESP.BigOnly == true then
                                            ItemName.Visible = true
                                            RarityText.Visible = true
                                            StatusText.Visible = true
                                            DistanceText.Visible = true
                                        else
                                            ItemName.Visible = false
                                            RarityText.Visible = false
                                            StatusText.Visible = false
                                            DistanceText.Visible = false
                                        end
                                    end
                
                                    DistanceText.Text = "["..tostring(ItemDistance).."]"
                                    
                                    if Vault.Values.Broken.Value == false then
                                        StatusText.Text = "NOT BROKEN"
                                    else
                                        StatusText.Text = "BROKEN"
                                    end
                                else
                                    ItemName.Visible = false
                                    RarityText.Visible = false
                                    StatusText.Visible = false
                                    DistanceText.Visible = false
                                end
                            else
                                ItemName.Visible = false
                                RarityText.Visible = false
                                StatusText.Visible = false
                                DistanceText.Visible = false

                                Iu:Disconnect()
                            end
                        else
                            ItemName.Visible = false
                            RarityText.Visible = false
                            StatusText.Visible = false
                            DistanceText.Visible = false
                        end
                    end
                end)
            end
            coroutine.wrap(InfoUpdate)()
        end
        -- #endregion
        
        -- #region // RegisterESP 
        local function RegisterESP(Register)
            local ItemName = Drawing.new("Text")
            ItemName.Visible = false
            ItemName.Center = true
            ItemName.Outline = true
            ItemName.Font = 2
            ItemName.Size = 13
            ItemName.Color = Color3.new(1, 2.5, 2.5)
            ItemName.Text = "Register"
        
            local StatusText = Drawing.new("Text")
            StatusText.Visible = false
            StatusText.Center = true
            StatusText.Outline = true
            StatusText.Font = 2
            StatusText.Size = 13
            StatusText.Color = Color3.new(1, 2.5, 2.5)
            StatusText.Text = "Status"
        
            local DistanceText = Drawing.new("Text")
            DistanceText.Visible = false
            DistanceText.Center = true
            DistanceText.Outline = true
            DistanceText.Font = 2
            DistanceText.Size = 13
            DistanceText.Color = Color3.new(1, 2.5, 2.5)
            DistanceText.Text = "Distance"
        
            local function InfoUpdate()
                local Iu
        
                Iu = game:GetService("RunService").RenderStepped:Connect(function()
                    if not workspace:IsAncestorOf(Register) then
                        ItemName.Visible = false
                        StatusText.Visible = false
                        DistanceText.Visible = false
        
                        Iu:Disconnect()
                    else
                        local Vector, OnScreen = Cam:WorldToViewportPoint(Register:FindFirstChild("MainPart").Position)
        
                        if OnScreen then
                            ItemName.Position = Vector2.new(Vector.X, Vector.Y - 30)
                            StatusText.Position = Vector2.new(Vector.X, Vector.Y - 20)
                            DistanceText.Position = Vector2.new(Vector.X, Vector.Y - 10)
        
                            ItemName.Visible = false
                            StatusText.Visible = false
                            DistanceText.Visible = false
        
                            local ItemDistance = math.ceil((Register:FindFirstChild("MainPart").Position - game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position).magnitude)
        
                            if ESPSettings.RegisterESP.Enabled == true then
                                if ItemDistance < ESPSettings.RegisterESP.Distance then
                                    ItemName.Visible = true
                                    StatusText.Visible = true
                                    DistanceText.Visible = true
            
                                    DistanceText.Text = "["..tostring(ItemDistance).."]"
                                    
                                    if Register.Values.Broken.Value == false then
                                        StatusText.Text = "NOT BROKEN"
                                    else
                                        StatusText.Text = "BROKEN"
                                    end
                                else
                                    ItemName.Visible = false
                                    StatusText.Visible = false
                                    DistanceText.Visible = false
                                end
                            else
                                ItemName.Visible = false
                                StatusText.Visible = false
                                DistanceText.Visible = false

                                Iu:Disconnect()
                            end
                        else
                            ItemName.Visible = false
                            StatusText.Visible = false
                            DistanceText.Visible = false
                        end
                    end
                end)
            end
            coroutine.wrap(InfoUpdate)()
        end
        -- #endregion
        
        -- #region // Scrap Added
        game:GetService("Workspace").Filter.SpawnedPiles.ChildAdded:Connect(function(Object)
            if ESPSettings.ScrapESP.Enabled == true then
                coroutine.wrap(ScrapESP)(Object)
            end
        end)
        -- #endregion
    
    -- #endregion

    -- #region // Objects

    local Framework                = loadstring(game:HttpGet("https://raw.githubusercontent.com/JackeyBot/Aurora-Hub/main/Libraries/UILib.lua", true))()
    local ESPFramework             = loadstring(game:HttpGet("https://raw.githubusercontent.com/JackeyBot/Aurora-Hub/main/Libraries/KiriotsESP.lua"))()
    local Watermark                = Framework:CreateWatermark("Aurora | {game} | {fps}")
    local Aurora                   = Framework:CreateWindow( "Aurora Hub", Vector2.new(492, 588), Enum.KeyCode.BackSlash )

    local General                  = Aurora:CreateTab("General")
    local Visuals                  = Aurora:CreateTab("Visuals")
    local TeleportsS               = Aurora:CreateTab("Teleports")
    local Credits                  = Aurora:CreateTab("Credits")
    
    local MainS                    = General:CreateSector("Main", "left")
    local PepperS                  = General:CreateSector("Pepper", "right")   
    local GunModsS                 = General:CreateSector("Gun Mods", "left") 
    local PlayerS                  = General:CreateSector("Player", "right")
    local SilentAimS               = General:CreateSector("Silent Aim", "right")

    local PlayerEspS               = Visuals:CreateSector("Player Visuals", "left")
    local ScrapEspS                = Visuals:CreateSector("Scrap Visuals", "right")
    local SafeEspS                 = Visuals:CreateSector("Safe Visuals", "left")
    local RegisterEspS             = Visuals:CreateSector("Register Visuals", "right")

    local CreditsS                 = Credits:CreateSector("Credits", "left")  
    local MiscS                    = Credits:CreateSector("Miscellaneous", "right") 

    local TeleportAreas1           = TeleportsS:CreateSector("Locations Inside", "left") 
    local TeleportAreas2           = TeleportsS:CreateSector("Locations Outside", "right") 
    local TeleportAreas3           = TeleportsS:CreateSector("Dealers", "left") 
    local TeleportAreas4           = TeleportsS:CreateSector("ATMs", "right")  

    -- #endregion

    -- #region // Codes
    
        -- #region Admin Detector
        game.Players.PlayerAdded:Connect(function(AdminUserCheck)
            if AdminUserCheck.UserId == 68246168 or AdminUserCheck.UserId == 955294 or AdminUserCheck.UserId == 1095419 or AdminUserCheck.UserId == 50585425 or AdminUserCheck.UserId == 48405917 or AdminUserCheck.UserId == 9212846 or AdminUserCheck.UserId == 47352513 or AdminUserCheck.UserId == 48058122 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Mod Alert\n"..AdminUserCheck.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif AdminUserCheck.UserId == 42066711 or AdminUserCheck.UserId == 513615792 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Contractors Alert\n"..AdminUserCheck.Name..", Is in the server"; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif AdminUserCheck.UserId == 151691292 or AdminUserCheck.UserId == 92504899 or AdminUserCheck.UserId == 31967243 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Devs Alert\n"..AdminUserCheck.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif AdminUserCheck.UserId == 29761878 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Owner Alert\nRvvz, Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            end
        end)

        for i, v in pairs(game.Players:GetPlayers()) do
            if v.UserId == 68246168 or v.UserId == 955294 or v.UserId == 1095419 or v.UserId == 50585425 or v.UserId == 48405917 or v.UserId == 9212846 or v.UserId == 47352513 or v.UserId == 48058122 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Mod Alert\n"..v.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif v.UserId == 42066711 or v.UserId == 513615792 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Contractors Alert\n"..v.Name..", Is in the server"; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif v.UserId == 151691292 or v.UserId == 92504899 or v.UserId == 31967243 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Devs Alert\n"..v.Name..", Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            elseif v.UserId == 29761878 then
                StarterGui:SetCore("SendNotification", {Title = "Aurora Hub"; Text = "Owner Alert\nRvvz, Is in the server."; Icon = "rbxassetid://8426126371"; Duration = 1 })
            end
        end
        -- #endregion

        -- #region Infinite Stamina
        local StaminaTake = getrenv()._G.S_Take
        local StaminaFunc = getupvalue(StaminaTake, 2) 

        for i, v in pairs(getupvalues(StaminaFunc)) do
            if type(v) == "function" and getinfo(v).name == "Upt_S" then
                local OldFunction; 

                OldFunction = hookfunction(v, function(...)
                    if Settings.InfiniteStamina == true then
                        local CharacterVar = game.Players.LocalPlayer.Character

                        if not CharacterVar or not CharacterVar.Parent then
                            local CharacterVar = game.Players.LocalPlayer.CharacterAdded:wait()

                            if CharacterVar:WaitForChild("Humanoid").WalkSpeed > 18 then
                                getupvalue(StaminaFunc, 6).S = 99
                            end
                        elseif CharacterVar then
                            if CharacterVar:WaitForChild("Humanoid").WalkSpeed > 18 then
                                getupvalue(StaminaFunc, 6).S = 99
                            end
                        end
                    end

                    return OldFunction(...)
                end)
            end
        end
        -- #endregion

        -- #region No Jump Cooldown
        local __newindex
        __newindex = hookmetamethod(game, "__newindex", function(t, k, v)
            if (t:IsDescendantOf(Character) and k == "Jump" and v == false) then
                if Settings.NoJumpCooldown == true then
                    return
                end
            end
            
            return __newindex(t, k, v)
        end)
        -- #endregion

        -- #region FullBright And FOV
        game:GetService("RunService").RenderStepped:Connect(function()
            if Settings.FullBright == true then
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").ClockTime = 14
                game:GetService("Lighting").FogEnd = 100000
                game:GetService("Lighting").GlobalShadows = false
                game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end

            if Settings.CamFovToggled == true then
                game.Workspace.Camera.FieldOfView = Settings.CamFov
            end
        end)
        -- #endregion

        -- #region Unlock Nearby Doors
        game:GetService("RunService").RenderStepped:Connect(function()
            if Settings.UnlockDoorsNearby == true then
                if Settings.IsDead == false then
                    for i, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
                        if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("DoorBase").Position).Magnitude <= 5 then
                            if v:FindFirstChild("Values"):FindFirstChild("Locked").Value == true then
                                v:FindFirstChild("Events"):FindFirstChild("Toggle"):FireServer("Unlock", v.Lock)
                            end
                        end
                    end
                end
            end
        end)
        -- #endregion

        -- #region Open Nearby Doors
        game:GetService("RunService").RenderStepped:Connect(function()
            if Settings.OpenDoorsNearby == true then
                if Settings.IsDead == false then
                    for i, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
                        if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("DoorBase").Position).Magnitude <= 5 then
                            if v:FindFirstChild("Values"):FindFirstChild("Open").Value == false then
                                v:FindFirstChild("Events"):FindFirstChild("Toggle"):FireServer("Open", v.Knob2)
                            end
                        end
                     end
                end
            end
        end)
        -- #endregion

        -- #region Auto Pickup
        
        coroutine.wrap(function()
            game:GetService("RunService").RenderStepped:Connect(function()
                wait(2)

                if Settings.AutoPickScrap == true then
                    for i, v in pairs(game:GetService("Workspace").Filter.SpawnedPiles:GetChildren()) do
                        if Settings.IsDead == false then
                            if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChild("MeshPart").Position).Magnitude < 5 then
                                game:GetService("ReplicatedStorage").Events.PIC_PU:FireServer(v.MeshPart)
                            end
                        end
                    end
                end
    
                if Settings.AutoPickTools == true then
                    for i, v in pairs(game:GetService("Workspace").Filter.SpawnedTools:GetChildren()) do
                        if Settings.IsDead == false then
                            if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v:FindFirstChildWhichIsA("MeshPart").Position).Magnitude < 5 then
                                game:GetService("ReplicatedStorage").Events.PIC_TLO:FireServer(v:FindFirstChildWhichIsA("MeshPart"))
                            end
                        end
                    end
                end
    
                if Settings.AutoPickCash == true then
                    for i, v in pairs(game:GetService("Workspace").Filter.SpawnedBread:GetChildren()) do
                        if Settings.IsDead == false then
                            if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Position).Magnitude < 5 then
                                game:GetService("ReplicatedStorage").Events.CZDPZUS:FireServer(v)
                            end
                        end
                    end
                end
            end)
        end)()
        -- #endregion

        -- #region FlashBang
        game.Workspace.Camera.ChildAdded:Connect(function(Item)
            if Settings.NoFlashbang == true then
                if Item.Name == "BlindEffect" then
                    Item.Enabled = false
                end
            end
        end)

        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if Item.Name == "FlashedGUI" then
                if Settings.NoFlashbang == true then
                    Item.Enabled = false
                end
            end
        end)
        -- #endregion

        -- #region Smoke
        game.Workspace.Debris.ChildAdded:Connect(function(Item)
            if Item.Name == "SmokeExplosion" then
                if Settings.NoSmoke == true then
                    wait(0.1)
                    Item.Particle1:Destroy()
                    Item.Particle2:Destroy()
                end
            end
        end)

        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if Item.Name == "SmokeScreenGUI" then
                if Settings.NoSmoke == true then
                    Item.Enabled = false
                end
            end
        end)
        -- #endregion

        -- #region Tool Equipped Checker
        game.Players.LocalPlayer.Character.ChildAdded:Connect(function(Item)
            if Item.Name == "Pepper-spray" then
                Settings.PepperSprayEquipped = true
            end
        end)

        game.Players.LocalPlayer.Character.ChildRemoved:Connect(function(Item)
            if Item.Name == "Pepper-spray" then
                Settings.PepperSprayEquipped = false
            end
        end)
        -- #endregion
        
        -- #region Infinite Pepper Spray
        game:GetService("RunService").RenderStepped:Connect(function()
            if Settings.PepperSprayEquipped == true then
                if Settings.InfinitePepperSpray == true then
                    game.Players.LocalPlayer.Character["Pepper-spray"].Ammo.Value = 99
                    game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Update", 99)
                end
            end
        end)
        -- #endregion

        -- #region Pepper Spray Aura
        coroutine.wrap(function()
            game:GetService("RunService").RenderStepped:Connect(function()
                wait(0.5)
                if Settings.PepperSprayEquipped == true then
                    if Settings.PepperSprayAura == true then
                        for i, v in pairs(game.Players:GetChildren()) do
                            if Settings.IsDead == false then
                                if (game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 15 then
                                    game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Spray", true)
                                    game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Hit", v.Character)
                                else
                                    game.Players.LocalPlayer.Character["Pepper-spray"].RemoteEvent:FireServer("Spray", false)
                                end
                            end
                        end
                    end
                end
            end)
        end)()
        -- #endregion
    
        -- #region No Fail Lockpick
        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if Settings.NoFailLockpick == true then
                if Item.Name == "LockpickGUI" then
                    Item.MF["LP_Frame"].Frames.B1.Bar.UIScale.Scale = 10
                    Item.MF["LP_Frame"].Frames.B2.Bar.UIScale.Scale = 10
                    Item.MF["LP_Frame"].Frames.B3.Bar.UIScale.Scale = 10
                end
            elseif Settings.NoFailLockpick == false then
                if Item.Name == "LockpickGUI" then
                    Item.MF["LP_Frame"].Frames.B1.Bar.UIScale.Scale = 1
                    Item.MF["LP_Frame"].Frames.B2.Bar.UIScale.Scale = 1
                    Item.MF["LP_Frame"].Frames.B3.Bar.UIScale.Scale = 1
                end
            end
        end)
        -- #endregion
    
        -- #region Dead Checker
        game.Players.LocalPlayer.CharacterAdded:Connect(function()
            repeat wait() until game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character.Parent ~= nil

            Character = Player.Character
            Settings.IsDead = false
        end)

        game.Players.LocalPlayer.Character:FindFirstChild("Humanoid").Died:Connect(function()
            Settings.IsDead = true
            Settings.PepperSprayEquipped = false
        end)

        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Parent then
            Settings.IsDead = false
        end
        -- #endregion
    
        -- #region Chat When Downed
        Player.CharacterAdded:Connect(function()
            game.ReplicatedStorage.CharStats[Player.Name].Downed.Changed:Connect(function(V)
                if V == true then
                    if Settings.DownedChat == true then
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Settings.DownedMSG, "All")
                    end
                end
            end)
        end)
        -- #endregion

        -- #region Gun Mods
        Player.Character.ChildAdded:Connect(function(Item)
            if Item:IsA("Tool") then
                    for i,v in pairs(getgc(true)) do 
                        if type(v) == 'table' and rawget(v, 'EquipTime') then 
                            if Settings.GunMods.NoRecoil == true then
                                v.Recoil = 0
                                v.CameraRecoilingEnabled = false
                                v.AngleX_Min = 0 
                                v.AngleX_Max = 0 
                                v.AngleY_Min = 0
                                v.AngleY_Max = 0
                                v.AngleZ_Min = 0
                                v.AngleZ_Max = 0
                            end
    
                            if Settings.GunMods.InstantEquip == true then
                                v.EquipTime = 0
                            end
    
                            if Settings.GunMods.Spread == true then
                                v.Spread = Settings.GunMods.SpreadAmount
                            end
            
                            if Settings.GunMods.AutoMode == true then
                                v.FireModeSettings = {FireMode = "Semi", BurstAmount = 6, BurstRate = 25, CanSwitch = true, SwitchTo = "Auto"}
                            end
                        end
                    end
            end
        end)
        -- #endregion

        -- #region Silent Aim

        coroutine.resume(coroutine.create(function()
            game:GetService("RunService").RenderStepped:Connect(function()
                if SilentSettings.FOVSettings.Visible then 
                    SilentAIMFov.Visible        = SilentSettings.FOVSettings.Visible
                    SilentAIMFov.Color          = _G.CriminalityInfo.SilentAimColor
                    SilentAIMFov.Position       = GetMousePosition() + Vector2.new(0, 36)
                end
            end)
        end))

        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(...)
            local Method = getnamecallmethod()
            local Arguments = {...}
            local self = Arguments[1]
        
            if SilentSettings.Main.Enabled and self == workspace then
                print("self == workspace")
                if ValidateArguments(Arguments, RequiredArgs) then
                    local A_Origin = Arguments[2]
                    local HitPart = GetClosestPlayer()
                    print("validated args")

                    if HitPart then
                        Arguments[3] = GetDirection(A_Origin, HitPart.Position)
                        print("set args")
                        return oldNamecall(unpack(Arguments))
                    end
                end
            end

            return oldNamecall(...)
        end)

        -- #endregion

        -- #region WalkSpeed & JumpPower
        game:GetService("RunService").RenderStepped:Connect(function()
            if Settings.IsDead == false then
                if Settings.WalkSpeed.Enabled == true then
                    Character.Humanoid.WalkSpeed = Settings.WalkSpeed.Amount
                end

                if Settings.JumpPower.Enabled == true then
                    Character.Humanoid.JumpPower = Settings.JumpPower.Amount
                end
            end
        end)
        -- #endregion

    -- #endregion

    -- #region // Tabs

        -- #region // General Tab

            -- #region // Main Sector
            MainS:AddSeperator("The Good stuff")

            MainS:AddToggle("Infinite Stamina", false, function(V)
                Settings.InfiniteStamina = V
            end)

            MainS:AddToggle("No Jump Cooldown", false, function(V)
                Settings.NoJumpCooldown = V
            end)

            MainS:AddToggle("Chat Logs", false, function(V)
                Settings.ShowChatLogs = V

                if V == true then
                    local ChatFrame = game.Players.LocalPlayer.PlayerGui.Chat.Frame
                    ChatFrame.ChatChannelParentFrame.Visible = true
                    ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), ChatFrame.ChatChannelParentFrame.Size.Y)
                elseif V == false then
                    local ChatFrame = game.Players.LocalPlayer.PlayerGui.Chat.Frame
                    ChatFrame.ChatChannelParentFrame.Visible = false
                    ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(0, 0, 0, 0)
                end
            end)

            MainS:AddToggle("Full Brightness", false, function(V)
                Settings.FullBright = V
            end)

            MainS:AddToggle("No Fail Lockpick", false, function(V)
                Settings.NoFailLockpick = V
            end)

            MainS:AddToggle("Unlock Nearby Doors", false, function(V)
                Settings.UnlockDoorsNearby = V
            end)

            MainS:AddToggle("Open Nearby Doors", false, function(V)
                Settings.OpenDoorsNearby = V
            end)
        
            --[[ people can't read.

            MainS:AddSeperator("Auto Pick")

            MainS:AddToggle("Auto Pickup Scrap", false, function(V)
                Settings.AutoPickScrap = V
            end)

            MainS:AddToggle("Auto Pickup Tools", false, function(V)
                Settings.AutoPickTools = V
            end)

            MainS:AddToggle("Auto Pickup Cash", false, function(V)
                Settings.AutoPickCash = V
            end)
        
            --]]
            -- #endregion

            -- #region // Player Sector
            local FOVToggle = PlayerS:AddToggle("Toggle FOV", false, function(V)
                Settings.CamFovToggled = V
            end, "FOVToggle")

            FOVToggle:AddKeybind(Enum.KeyCode.RightAlt, "FOVToggle")

            PlayerS:AddSlider("Field Of View", 70, 70, 120, 10, function(V)
                Settings.CamFov = V
            end)

            PlayerS:AddToggle("No Flash", false, function(V)
                Settings.NoFlashbang = V
            end)

            PlayerS:AddToggle("No Smoke", false, function(V)
                Settings.NoSmoke = V
            end)

            PlayerS:AddSeperator("Character Stuff")

            PlayerS:AddToggle("WalkSpeed Toggeled", false, function(V)
                Settings.WalkSpeed.Enabled = V
            end)

            PlayerS:AddToggle("JumpPower Toggeled", false, function(V)
                Settings.JumpPower.Enabled = V
            end)

            PlayerS:AddSlider("WalkSpeed", 16, 16, 30, 10, function(V)
                Settings.WalkSpeed.Amount = V
            end)

            PlayerS:AddSlider("JumpPower", 50, 50, 75, 10, function(V)
                Settings.JumpPower.Amount = V
            end)
            -- #endregion

            -- #region // Gun Mods Sector
            GunModsS:AddToggle("No Recoil", false, function(V)
                Settings.GunMods.NoRecoil = V
            end)

            local SpreadToggle = GunModsS:AddToggle("Custom Spread", false, function(V)
                Settings.GunMods.NoRecoil = V
            end, "SpreadToggle")

            SpreadToggle:AddSlider(1, 1, 50, 10, function(V)
                Settings.GunMods.SpreadAmount = V
            end)

            GunModsS:AddToggle("Instant Equip", false, function(V)
                Settings.GunMods.InstantEquip = V
            end)

            GunModsS:AddToggle("Auto Mode", false, function(V)
                Settings.GunMods.AutoMode = V
            end)
            -- #endregion

            -- #region // Pepper Sector
            PepperS:AddToggle("Infinite Pepper Spray", false, function(V)
                Settings.InfinitePepperSpray = V
            end)

            PepperS:AddToggle("Pepper Spray Aura", false, function(V)
                Settings.PepperSprayAura = V
            end)
            -- #endregion

            -- #region // Silent Aim
            SilentAimS:AddSeperator("- Silent Aim Settings -")

            local SilentToggle = SilentAimS:AddToggle("Enabled", false, function(V)
                SilentSettings.Main.Enabled = V
            end, "SilentToggle")

            SilentToggle:AddKeybind(Enum.KeyCode.LeftAlt, "SilentToggle")

            SilentAimS:AddToggle("Visible Check", false, function(V)
                SilentSettings.Main.VisibleCheck = V
            end)

            SilentAimS:AddDropdown("Hit Part", {"Head", "Torso", "Random"}, "Random", false, function(V)
                SilentSettings.Main.TargetPart = V
            end)

            SilentAimS:AddSeperator("- Fov Settings -")

            SilentAimS:AddToggle("Visible", false, function(V)
                SilentSettings.FOVSettings.Visible = V
                SilentAIMFov.Visible = V
            end)

            SilentAimS:AddSlider("Radius", 5, 80, 360, 10, function(V)
                SilentSettings.FOVSettings.Radius = V
                SilentAIMFov.Radius = V
            end)
            -- #endregion

        -- #endregion

        -- #region // Visuals Tab

            -- #region // Player Visuals
            PlayerEspS:AddToggle("Player ESP", false, function(V)
                ESPFramework.Color = _G.CriminalityInfo.ESPColor
                ESPFramework.Tracers = ESPSettings.PlayerESP.TracersOn
                ESPFramework.Names = ESPSettings.PlayerESP.NamesOn
                ESPFramework.Boxes = ESPSettings.PlayerESP.BoxesOn
                ESPFramework.FaceCamera = ESPSettings.PlayerESP.FaceCamOn
                ESPFramework:Toggle(V)
            end)
            
            PlayerEspS:AddToggle("Toggle Boxes", false, function(V)
                ESPFramework.Boxes = V
        
                ESPSettings.PlayerESP.BoxesOn = V
            end)

            PlayerEspS:AddToggle("Toggle Tracers", false, function(V)
                ESPFramework.Tracers = V
        
                ESPSettings.PlayerESP.TracersOn = V
            end)

            PlayerEspS:AddToggle("Toggle Name", false, function(V)
                ESPFramework.Names = V
        
                ESPSettings.PlayerESP.NamesOn = V
            end)

            PlayerEspS:AddToggle("Toggle Face Cam", false, function(V)
                ESPFramework.FaceCamera = V
        
                ESPSettings.PlayerESP.FaceCamOn = V
            end)
            -- #endregion

            -- #region // Scrap Visuals
            ScrapEspS:AddToggle("Scrap ESP", false, function(V)
                ESPSettings.ScrapESP.Enabled = V

                if V == true then
                    for i, v in pairs(game:GetService("Workspace").Filter.SpawnedPiles:GetChildren()) do
                        coroutine.wrap(ScrapESP)(v)
                    end
                end
            end)

            ScrapEspS:AddSeperator("Rarity")

            ScrapEspS:AddToggle("Rare Only", false, function(V)
                ESPSettings.ScrapESP.RareOnly = V
            end)

            ScrapEspS:AddToggle("Good Only", false, function(V)
                ESPSettings.ScrapESP.GoodOnly = V
            end)

            ScrapEspS:AddToggle("Bad Only", false, function(V)
                ESPSettings.ScrapESP.BadOnly = V
            end)

            ScrapEspS:AddSeperator("Distance")

            ScrapEspS:AddSlider("Scrap Distance", 250, 500, 2000, 10, function(V)
                ESPSettings.ScrapESP.Distance = V
            end)
            -- #endregion

            -- #region // Safe Visuals
            SafeEspS:AddToggle("Safe ESP", false, function(V)
                ESPSettings.SafeESP.Enabled = V

                if V == true then
                    for i, v in pairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
                        if tonumber(v:FindFirstChild("Type").Value) == 2 then
                            coroutine.wrap(SafeESP)(v, 2)
                        elseif tonumber(v:FindFirstChild("Type").Value) == 3 then
                            coroutine.wrap(SafeESP)(v, 3)
                        end
                    end
                end
            end)

            SafeEspS:AddSeperator("Rarity")

            SafeEspS:AddToggle("Big Only", false, function(V)
                ESPSettings.SafeESP.BigOnly = V
            end)

            SafeEspS:AddToggle("Small Only", false, function(V)
                ESPSettings.SafeESP.SmallOnly = V
            end)

            SafeEspS:AddSeperator("Distance")

            SafeEspS:AddSlider("Safe Distance", 250, 500, 2000, 10, function(V)
                ESPSettings.SafeESP.Distance = V
            end)
            -- #endregion

            -- #region // Register Visuals
            RegisterEspS:AddToggle("Register ESP", false, function(V)
                ESPSettings.RegisterESP.Enabled = V

                if V == true then
                    for i, v in pairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
                        if tonumber(v:FindFirstChild("Type").Value) == 1 then
                            coroutine.wrap(RegisterESP)(v)
                        end
                    end
                end
            end)

            RegisterEspS:AddSeperator("Distance")

            RegisterEspS:AddSlider("Register Distance", 250, 500, 2000, 10, function(V)
                ESPSettings.RegisterESP.Distance = V
            end)
            -- #endregion
            
        -- #endregion

        -- #region // Credits Tab

            -- #region // Credits Sector
            CreditsS:AddSeperator("Creators")
            CreditsS:AddLabel("JackeyBot - Founder") 
            CreditsS:AddLabel("HuntaDev - Co Founder") 
            -- #endregion

            -- #region // Misc Sector
            MiscS:AddButton("Discord", function() JoinDiscord() end)
            MiscS:AddToggle("Toggle Watermark", true, function(V)
                Watermark.Visible = V
            end)
            -- #endregion

        -- #endregion

        -- #region // Teleports Tab
        local function TeleportArea(Cframe)
            shared.teleport         = true

            local TPCFrame          = Cframe
            local User              = game.Players.LocalPlayer.Character.HumanoidRootPart
            local WaitTime          = 10

            while shared.teleport do wait()
                
                spawn(function()
                    wait(WaitTime)
                    shared.teleport = false
                end)

                User.CFrame = TPCFrame

                local args = {
                    [1] = "__--r",
                    [2] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
                    [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,0,0)
                }

                game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer(unpack(args))

            end
        end

        TeleportAreas1:AddButton("Vibin Hideout", function()
            TeleportArea(CFrame.new(-4466.548828125, 39.32609939575195, -392.067138671875))
        end)

        TeleportAreas1:AddButton("Cafe", function()
            TeleportArea(CFrame.new(-4646.08251953125, 6.046332836151123, -256.7106018066406))
        end)

        TeleportAreas1:AddButton("Vibin", function()
            TeleportArea(CFrame.new(-4401.146484375, 6.264440059661865, -401.30084228515625))
        end)

        TeleportAreas1:AddButton("Motel", function()
            TeleportArea(CFrame.new(-4694.91650390625, 16.973020553588867, -962.79046630859))
        end)

        TeleportAreas1:AddButton("Tower", function()
            TeleportArea(CFrame.new(-4508.31005859375, 102.73432159423828, -847.6023559570312))
        end)

        TeleportAreas1:AddButton("Factory", function()
            TeleportArea(CFrame.new(-4394.68505859375, 21.600116729736328, -558.8350830078125))
        end)

        TeleportAreas1:AddButton("Armory 1", function()
            TeleportArea(CFrame.new(-4770.51416015625, 3.995715379714966, -409.6304016113281))
        end)

        TeleportAreas1:AddButton("Armory 2", function()
            TeleportArea(CFrame.new(-4200.70166015625, 3.997739553451538, -185.94895935058594))
        end)

        TeleportAreas1:AddButton("Gas Station", function()
            TeleportArea(CFrame.new(-4431.10302734375, 4.0262131690979, 202.88829040527344))
        end)

        TeleportAreas1:AddButton("Pizza Store", function()
            TeleportArea(CFrame.new(-4404.12451171875, 5.199555397033691, -181.91232299804688))
        end)

        TeleportAreas1:AddButton("Thrift Store", function()
            TeleportArea(CFrame.new(-4621.07861328125, 4.099781513214111, -151.47450256347656))
        end)

        TeleportAreas1:AddButton("Subway", function()
            TeleportArea(CFrame.new(-4776.4755859375, -34.77134323120117, -784.1185913085938))
        end)

        TeleportAreas1:AddButton("Vibe Check", function()
            TeleportArea(CFrame.new(-4776.9521484375, -201.26490783691406, -961.081298828125))
        end)



        

        TeleportAreas2:AddButton("Vibin Hideout", function()
            TeleportArea(CFrame.new(-4466.81689453125, 23.555461883544922, -437.17169189453125))
        end)

        TeleportAreas2:AddButton("Cafe", function()
            TeleportArea(CFrame.new(-4600.1337890625, 3.899446487426758, -278.59722900390625))
        end)

        TeleportAreas2:AddButton("Vibin", function()
            TeleportArea(CFrame.new(-4400.68603515625, 3.295433282852173, -343.2763366699219))
        end)

        TeleportAreas2:AddButton("Motel", function()
            TeleportArea(CFrame.new(-4641.009765625, 3.690157413482666, -905.4984741210938))
        end)

        TeleportAreas2:AddButton("Tower", function()
            TeleportArea(CFrame.new(-4493.49853515625, 3.2909929752349854, -718.6547241210938))
        end)

        TeleportAreas2:AddButton("Factory", function()
            TeleportArea(CFrame.new(-4432.39208984375, 21.59963035583496, -514.9470825195312))
        end)

        TeleportAreas2:AddButton("Armory 1", function()
            TeleportArea(CFrame.new(-4769.7275390625, 3.8944435119628906, -360.00042724609375))
        end)

        TeleportAreas2:AddButton("Armory 2", function()
            TeleportArea(CFrame.new(-4143.83154296875, 3.899510383605957, -183.46885681152344))
        end)

        TeleportAreas2:AddButton("Gas Station", function()
            TeleportArea(CFrame.new(-4429.2177734375, 4.096165657043457, 163.4987335205078))
        end)

        TeleportAreas2:AddButton("Pizza Store", function()
            TeleportArea(CFrame.new(-4361.2314453125, 3.3003010749816895, -139.590087890625))
        end)

        TeleportAreas2:AddButton("Thrift Store", function()
            TeleportArea(CFrame.new(-4623.46044921875, 26.093965530395508, -128.2504882812))
        end)

        TeleportAreas2:AddButton("Subway", function()
            TeleportArea(CFrame.new(-4600.34619140625, 3.899278163909912, -694.621826171875))
        end)



        

        TeleportAreas3:AddButton("Dealer 1", function()
            TeleportArea(CFrame.new(-4268.42626953125, 3.8942785263061523, 95.84049987792969))
        end)

        TeleportAreas3:AddButton("Dealer 2", function()
            TeleportArea(CFrame.new(-3890.505859375, 3.898646593093872, -165.6616973876953))
        end)

        TeleportAreas3:AddButton("Dealer 3", function()
            TeleportArea(CFrame.new(-4204.54150390625, 4.084814548492432, -548.5355834960938))
        end)

        TeleportAreas3:AddButton("Dealer 4", function()
            TeleportArea(CFrame.new(-4309.11767578125, 3.8976902961730957, -402.10003662109375))
        end)

        TeleportAreas3:AddButton("Dealer 5", function()
            TeleportArea(CFrame.new(-4457.71142578125, 3.8988072872161865, -537.0403442382812))
        end)
        


        

        TeleportAreas4:AddButton("ATM 1", function()
            TeleportArea(CFrame.new( -4458.44140625, 3.8995916843414307, -447.21044921875))
        end)

        TeleportAreas4:AddButton("ATM 2", function()
            TeleportArea(CFrame.new( -4679.98779296875, 3.898556709289551, -240.61509704589844))
        end)

        TeleportAreas4:AddButton("ATM 3", function()
            TeleportArea(CFrame.new( -4381.24462890625, 3.99601149559021, -63.50413131713867))
        end)

        TeleportAreas4:AddButton("ATM 4", function()
            TeleportArea(CFrame.new( -4297.296875, 3.8963193893432617, -694.3870239257812))
        end)

        TeleportAreas4:AddButton("ATM 5", function()
            TeleportArea(CFrame.new( -4253.6357421875, 3.9000091552734375, -13.223593711853027))
        end)

        TeleportAreas4:AddButton("ATM 6", function()
            TeleportArea(CFrame.new( -4147.97607421875, 3.894084930419922, -169.73553466796875))
        end)

        TeleportAreas4:AddButton("ATM 7", function()
            TeleportArea(CFrame.new( -4156.0517578125, 3.895453691482544, -210.1305694580078))
        end)

        TeleportAreas4:AddButton("ATM 8", function()
            TeleportArea(CFrame.new( -4068.612548828125, 3.8994336128234863, -289.29461669921875))
        end)

        TeleportAreas4:AddButton("ATM 9", function()
            TeleportArea(CFrame.new( -4395.89794921875, 4.095702171325684, 195.97291564941406))
        end)

        TeleportAreas4:AddButton("ATM 10", function()
            TeleportArea(CFrame.new(-4633.900390625, 3.2963714599609375, -814.0245971679688))
        end)

        TeleportAreas4:AddButton("ATM 11", function()
            TeleportArea(CFrame.new(-4622.1435546875, 3.6649200916290283, -984.0272827148438))
        end)
        -- #endregion

    -- #endregion

end)

-- // Error Handling

if not Success and Error then
    pcall(function()
        local ExecutorUsing            = is_sirhurt_closure and "Sirhurt" or pebc_execute and "ProtoSmasher" or syn and "Synapse X" or secure_load and "Sentinel" or KRNL_LOADED and "Krnl" or SONA_LOADED and "Sona" or "WTF?"

        local HttpService              = game:GetService("HttpService")
        local Data                     = { ["content"]=null,["embeds"]={{["title"]="Aurora - Error Reporter",["description"]="An error has been found while execution.",["color"]=tonumber(0x287cd8),["fields"]={{["name"]="Username",["value"]=game.Players.LocalPlayer.Name,["inline"]=true},{["name"]="Game",["value"]="https://www.roblox.com/games/"..game.PlaceId,["inline"]=true},{["name"]="Executor",["value"]=ExecutorUsing,["inline"]=true},{["name"]="Error",["value"]="```"..Error.."```"}},["footer"]={["text"]="Aurora Hub | <date> | <time>",["icon_url"]="https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&Format=Png&username="..game.Players.LocalPlayer.Name}}}}

        local Headers                  = {["Content-Type"]="application/json"}
        local Encoded                  = HttpService:JSONEncode(Data)

        Request                         = http_request or request or HttpPost or syn.request
        local Final = {Url              = "https://websec.services/ws/send/rsxJ4CNdgcNM8cELtt8TWVqsuIxzHeR5OsNYkgpa", Body = Encoded, Method = "POST", Headers = Headers}

        Request(Final)
    
        local MSGBox = messagebox("Unfortunately, Aurora has detected an error. \n\nThis error has been sent to our servers.\nFor security reasons your game client will be closed.", "System", 0)

        if MSGBox == 1 then
            game:Shutdown()
        end
    end)
end
