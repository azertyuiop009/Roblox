repeat wait() until game:IsLoaded()
print('GridAPI Loaded 🥳')

_G.grid = {};

local grid = _G.grid;
local player = game.Players.LocalPlayer;

-- Create folder where all part will be
local gridFolder = workspace:FindFirstChild('rayCastGrid') or Instance.new('Folder');
gridFolder.Name = 'rayCastGrid';
gridFolder.Parent = workspace;

function grid:new( o )

    o = o or {  }
    setmetatable(o, self)
    self.__index = self
    return o

end

local function floor( o )
    return math.floor( math.sqrt(o) )
end

function grid:addPart( i, x, y, z )

    local part = gridFolder:FindFirstChild('rayCastCylinder'..i) or Instance.new('Part');
    game.CollectionService:addTag(part,'RayWhitelist')
    part.Shape = 'Cylinder';
    part.Anchored = true;
    part.Name = 'rayCastCylinder'..i
    part.CanCollide = false;

    local Blocked = part:FindFirstChild('Blocked') or Instance.new('BoolValue')
    Blocked.Name = 'Blocked'
    Blocked.Value = false;
    Blocked.Parent = part;

    part.Material = Enum.Material['SmoothPlastic'];

    part.Size = Vector3.new( 50, self.radius, self.radius )
    part.Rotation = Vector3.new( 0 , 0 , 90 )
    part.Position = Vector3.new( x , y , z )
    part.Parent = gridFolder
    part.Transparency = 1;
    part.CastShadow = false;

    return part

end

function grid:updateGrid()

    local offSet = ( floor( self.number ) / 2 * self.radius ) + self.radius/2;
    local currentIndex = 1;

    local startPos = { 
        x = player.Character.HumanoidRootPart.CFrame.x - offSet,
        z = player.Character.HumanoidRootPart.CFrame.z - offSet,
    };
    local currentPos = table.clone(startPos);

    for i = 1, self.number, 1 do

        self.Detectors[currentIndex] = self:addPart( currentIndex, currentPos.x, player.Character.HumanoidRootPart.CFrame.y , currentPos.z );
        if ( i % floor(self.number) == 0 and i ~= 0 ) then
    
            currentPos.x = startPos.x
            currentPos.z += self.radius;
    
        else

            currentPos.x += self.radius;

        end
        currentIndex += 1;
    
    end

    startPos = { 
        x = player.Character.HumanoidRootPart.CFrame.x - offSet + self.radius/2,
        z = player.Character.HumanoidRootPart.CFrame.z - offSet + self.radius/2,
    };
    currentPos = table.clone(startPos);
    local realI = 0;
    for i = self.number+1, self.number+((math.sqrt(self.number)-1) * (math.sqrt(self.number)-1)), 1 do
        realI = realI +1

        self.Detectors[currentIndex] = self:addPart( currentIndex, currentPos.x, player.Character.HumanoidRootPart.CFrame.y , currentPos.z );

        if ( realI % math.floor(math.sqrt(self.number)-1) == 0 and realI ~= 0 ) then
    
            currentPos.x = startPos.x
            currentPos.z = currentPos.z + self.radius;
    
        else

            currentPos.x += self.radius;

        end
        currentIndex += 1;

    end


end

function grid:init( number, radius )

    self.number = number;
    self.radius = radius;

    self.Detectors = {};
    self:updateGrid()


end
