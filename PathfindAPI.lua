-- Wait for the game load
repeat wait() until game:IsLoaded()

-- Define some basic properties
local Players = game.Players;
local Player = Players.LocalPlayer;
local Pathfind = {};
local Pathfind_service = game:GetService("PathfindingService")

-- Create constructor
function Pathfind:new ( o )
    o = o or {  }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Create initiator with options
function Pathfind:init(info, callback)

    self.info = info or { ["AgentHeight"] = 5, ["AgentRadius"] = 3, ["AgentCanJump"] = true };

    self.callback = callback;
    self.data = { 
        Task = 0,
        Waypoint_Index = 0,
        Waypoints = {},
        Current_Waypoint = nil
    }

    self.Path = Pathfind_service:CreatePath(info);

end

-- Stop pathfinding
function Pathfind:stopPath()

    self.data.Task = 0;

end

-- Start pathfinding
function Pathfind:startPath( position )

    local character = Player.Character;
    local humanoid = character.Humanoid;
    local root = character.HumanoidRootPart;

    local success, errorMessage = pcall(function()
        self.Path:ComputeAsync(root.Position, position)
    end)

    local currentTask = tick();
    self.data.Task = currentTask;

    if self.Path.Status == Enum.PathStatus.Success then

        self.data.Waypoints = path:GetWaypoints();
        self.data.Waypoint_Index = 2;
        self.data.Current_Waypoint = self.data.Waypoints[self.data.Waypoint_Index]

        if ( not self.data.Current_Waypoint ) then return end;
        if self.data.Current_Waypoint.Action == Enum.PathWaypointAction.Jump then
          humanoid.Jump = true
        end

        humanoid:MoveTo(self.data.Current_Waypoint.Position)

    else
        -- Cancel Pathfind
        self.data.Task = 0
        return false
    end

    local function new_waypoint(reached)
        if( currentTask ~= self.data.Task ) then return end;
        if(self.data.Waypoints ~= nil) then
            local numwp = #self.data.Waypoints
            if char ~= nil and hum ~= nil and reached and self.data.Waypoint_Index < numwp then
                self.data.Waypoint_Index += 1
                self.data.Current_Waypoint = self.data.Waypoints[self.data.Waypoint_Index]

                self.callback(char);
                if self.data.Current_Waypoint.Action == Enum.PathWaypointAction.Jump then
                    hum.Jump = true
                end
                hum:MoveTo(self.data.Current_Waypoint.Position)

            else

                self.callback(char, 'MoveToFinished');

            end
        end
    end

    local function blocked_waypoint( blockedWaypointIndex )

        if( currentTask ~= self.data.Task ) then return end;

        self.callback(char, 'Blocked');

        if blockedWaypointIndex > self.data.Waypoint_Index then
            self.startPath( position )
        end

    end

    path.Blocked:Connect(blocked_waypoint)
    hum.MoveToFinished:Connect(new_waypoint)

end
