-- Wait for the game load
repeat wait() until game:IsLoaded()
print('PathfindAPI Loaded 🥳')

-- Define some basic properties
local Players = game.Players;
local Player = Players.LocalPlayer;
_G.Pathfind = {};
_G.PInfo = { ["AgentHeight"] = 5, ["AgentRadius"] = 3, ["AgentCanJump"] = true }
local Pathfind_service = game:GetService("PathfindingService")

-- Create constructor
function _G.Pathfind:new ( o )
    o = o or {  }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Create initiator with options
function _G.Pathfind:init( callback )

    self.callback = callback;
    self.data = { 
        Task = 0,
        Waypoint_Index = 0,
        Waypoints = {},
        Current_Waypoint = nil,
        stopped = false
    }

    self.stopped = false;

    self.Path = Pathfind_service:CreatePath(_G.PInfo);

    local character = Player.Character;
    local humanoid = character.Humanoid;

    local function new_waypoint(reached)
        if( self.data.Task == 0 or self.stopped == true ) then return end;
        if(self.data.Waypoints ~= nil) then
            local numwp = #self.data.Waypoints
            if character ~= nil and humanoid ~= nil and reached and self.data.Waypoint_Index < numwp then
                self.data.Waypoint_Index += 1
                self.data.Current_Waypoint = self.data.Waypoints[self.data.Waypoint_Index]

                self.callback(character, 'NewWaypoint');
                if self.data.Current_Waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                humanoid:MoveTo(self.data.Current_Waypoint.Position)

            elseif self.data.Waypoint_Index == numwp then

                self.callback(character, 'MoveToFinished');

            end
        end
    end

    local function blocked_waypoint( blockedWaypointIndex )

        if( self.data.Task == 0 or self.stopped == true ) then return end;

        self.callback(character, 'Blocked');

        if blockedWaypointIndex > self.data.Waypoint_Index then
            self.startPath( position )
        end

    end

    self.Path.Blocked:Connect(blocked_waypoint);
    humanoid.MoveToFinished:Connect(new_waypoint);

end

-- Stop pathfinding
function _G.Pathfind:stopPath()
    
    if ( self.stopped == true ) then return end

    self.data.Task = 0;
    self.callback(Player.Character, 'Stopped')

end

function _G.Pathfind:stop()

    self.stopped = true;

end

-- Start pathfinding
function _G.Pathfind:startPath( position )

    if ( self.stopped == true ) then return end
    self:stopPath();
    self.callback(Player.Character, 'Started')

    local character = Player.Character;
    local humanoid = character.Humanoid;
    local root = character.HumanoidRootPart;

    local success, errorMessage = pcall(function()
        self.Path:ComputeAsync(root.Position, position)
    end)

    local currentTask = tick();
    self.data.Task = currentTask;

    if self.Path.Status == Enum.PathStatus.Success then

        self.data.Waypoints = self.Path:GetWaypoints();
        self.data.Waypoint_Index = 2;
        self.data.Current_Waypoint = self.data.Waypoints[self.data.Waypoint_Index]

        if ( not self.data.Current_Waypoint ) then return end;
        if self.data.Current_Waypoint.Action == Enum.PathWaypointAction.Jump then
          humanoid.Jump = true
        end

        humanoid:MoveTo(self.data.Current_Waypoint.Position)

    else
        -- Cancel Pathfind
        self.callback(character, 'Unsucess');
        self.data.Task = 0
        return false
    end


end
