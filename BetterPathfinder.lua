-- Wait for the game load
repeat wait() until game:IsLoaded()
print('PathfindAPI Loaded 🥳')

local Pathfinder = {};
local Player = game.Players.LocalPlayer;
local Pathfind_service = game:GetService("PathfindingService")

function Pathfinder:new() 

    local o = {};
    setmetatable(o,self);
    self.__index = self
    return o

end

function Pathfinder:init( callback )

	self.myTick = tick();
	_G.tickP = self.myTick;
	
    self.callback = callback;
    self.currentWaypoint = nil;
	self.waypoints = {};
	self.waypointIndex = 1;
	self.followingPath = false;
	self.Path = Pathfind_service:CreatePath({ ["AgentHeight"] = 5, ["AgentRadius"] = 3, ["AgentCanJump"] = true });
    self:load()

end

function Pathfinder:load()

    self.load = game:GetService("RunService").RenderStepped:Connect(function()
    
		if ( self.myTick ~= _G.tickP ) then return self.load:Disconnect() end;
        if ( not self.currentWaypoint ) then return end;

		
        local character = Player.Character or Player.CharacterAdded:Wait();
		local Position = self.currentWaypoint.Position + Vector3.new(0,2,0)
		local subPos = math.abs(Position.Y - character.HumanoidRootPart.Position.Y)
		if ( subPos > .5  ) then Position = Vector3.new(Position.X,character.HumanoidRootPart.Position.Y, Position.Z ) end
        if ( ( Position ) - character.HumanoidRootPart.Position).Magnitude < .5 then
			self.currentWaypoint = nil;
			if ( self.followingPath ) then 
				self.waypointIndex = self.waypointIndex +1; 
				self.currentWaypoint = self.waypoints[ self.waypointIndex ]
				if ( not self.currentWaypoint ) then return self.callback('FollowPathFinished'); end 
			end
			return self.callback('MoveToFinished', self.currentWaypoint);
		else


		end;

		if self.currentWaypoint.Action == Enum.PathWaypointAction.Jump then
			character.Humanoid.Jump = true
		end

        local direction = ( Position - character.HumanoidRootPart.Position ).Unit
    
		character.Humanoid:Move(direction)
    
    end)

end

function Pathfinder:MoveTo( position )

    local waypoint = position;
    self.currentWaypoint = {Position = waypoint, Action = nil};

end

function Pathfinder:stopPath()

	self.followingPath = false;
	self.waypoints = {};
	self.waypointIndex = 1;
	self.currentWaypoint = nil;

end

function Pathfinder:createPath( nextPoint )

	local character = Player.Character or Player.CharacterAdded:Wait();

    local success, errorMessage = pcall(function()
        self.Path:ComputeAsync(character.HumanoidRootPart.Position, nextPoint)
    end)

	if self.Path.Status == Enum.PathStatus.Success then
		self.waypoints = self.Path:GetWaypoints();
		return self.waypoints;
	else
		return false
	end

end

function Pathfinder:followPath( waypoints )

	local wps = waypoints or self.waypoints;
	self.waypoints = wps;
	self.waypointIndex = 1

	self.followingPath = true;
	self.currentWaypoint = wps[1];

end

function Pathfinder:Debug()
	
	local folder = workspace:FindFirstChild('PfDebug') or Instance.new("Folder");
	folder.Name = 'PfDebug';
	folder.Parent = workspace
	for i, v in pairs(folder:GetChildren()) do
		v:Destroy()
	end
	for i, v in pairs ( self.waypoints ) do
		local part = Instance.new('Part');
		part.Name = i;
		part.Transparency = .5;
		part.Anchored = true;
		part.CanCollide = false;
		part.Color = Color3.new(0,255,20)
		part.Position = v.Position+ Vector3.new(0,2,0)
		part.Material = Enum.Material.SmoothPlastic
		part.Size = Vector3.new(1,1,1);
		part.Shape = Enum.PartType.Ball;
		part.Parent = folder
	end

end
_G.Pathfinder = Pathfinder;
