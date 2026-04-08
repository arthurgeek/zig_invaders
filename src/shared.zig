const rl = @import("raylib");
const ecs = @import("zflecs");

pub const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn from(pos: Position, size: Size) Rectangle {
        return .{ .x = pos.x, .y = pos.y, .width = size.width, .height = size.height };
    }

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + other.height > other.y;
    }
};

pub const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
};

pub const Position = struct { x: f32, y: f32 };
pub const Size = struct { width: f32, height: f32 };
pub const Speed = struct { speed: f32 };
pub const Color = struct { color: rl.Color };

pub fn init(world: *ecs.world_t) void {
    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Size);
    ecs.COMPONENT(world, Speed);
    ecs.COMPONENT(world, Color);
}
