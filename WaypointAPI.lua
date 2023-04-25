-- Waiting for the game load
repeat wait() until game:IsLoaded()
print('WaypointAPI Loaded 🥳')

-- Define some basic properties
local Players = game.Players;
local Player = Players.LocalPlayer;

-- Creating constructor
_G.Pathfind = {};

function _G.Pathfind:new()

    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o

end

function _G.Pathfind:init( waypoints, callback )

    self.waypoints = waypoints;
    self.callback = callback;
    self.index = 0;

    Player.CharacterAdded:Connect(function(character)
        character.humanoid.MoveToFinished:Connect(function()
            self.callback('Waypoint reached');
        end)
    end)

end

function _G.Pathfind:nextWayPoint( index )

    local index_ = index or self.index;
    if ( not index ) then self.index = math.min(math.max(index_ + 1, 0), #self.waypoints-1) end;

    local waypoint = self.waypoints[index_];

    local waypoint_position = waypoint.Position;

    if ( not waypoint_position ) then return self.callback("Waypoint position incorrect") end

    local character = Player:WaitForChild('Character');
    local humanoid = character.Humanoid;

    humanoid:MoveTo( waypoint_position );

end
