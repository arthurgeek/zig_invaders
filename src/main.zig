const rl = @import("raylib");
const ecs = @import("zflecs");

const zig_invaders = @import("zig_invaders");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + other.height > other.y;
    }
};

const GameConfig = struct {
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

const Position = struct { x: f32, y: f32 };
const Size = struct { width: f32, height: f32 };
const Speed = struct { speed: f32 };
const Player = struct {};

fn draw_title_system(it: *ecs.iter_t) void {
    _ = it;
    rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
}

fn init_player_system(it: *ecs.iter_t) void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const player_width = 50.0;
    const player_height = 30.0;

    const player = ecs.new_entity(it.world, "Player");
    _ = ecs.set(
        it.world,
        player,
        Size,
        .{ .width = player_width, .height = player_height },
    );
    _ = ecs.set(it.world, player, Position, .{
        .x = screen_width / 2 - player_width / 2,
        .y = screen_height - 60.0,
    });
    _ = ecs.set(it.world, player, Speed, .{ .speed = 5.0 });
    ecs.add(it.world, player, Player);
}

fn move_player_system(positions: []Position, speeds: []const Speed, sizes: []const Size) void {
    for (positions, speeds, sizes) |*pos, spd, siz| {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            pos.x += spd.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            pos.x -= spd.speed;
        }

        if (pos.x < 0) {
            pos.x = 0;
        }

        if (pos.x + siz.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            pos.x = @as(f32, @floatFromInt(rl.getScreenWidth())) - siz.width;
        }
    }
}

fn draw_player_system(positions: []const Position, sizes: []const Size) void {
    for (positions, sizes) |pos, siz| {
        rl.drawRectangle(
            @intFromFloat(pos.x),
            @intFromFloat(pos.y),
            @intFromFloat(siz.width),
            @intFromFloat(siz.height),
            rl.Color.blue,
        );
    }
}

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;

    rl.initWindow(screenWidth, screenHeight, "Zig Invaders");
    defer rl.closeWindow();

    const world = ecs.init();
    defer _ = ecs.fini(world);

    ecs.FlecsRestImport(world);
    ecs.FlecsStatsImport(world);
    const rest_id = ecs.lookup(world, "rest.Rest");
    _ = ecs.set_id(
        world,
        rest_id,
        rest_id,
        @sizeOf(ecs.EcsRest),
        &ecs.EcsRest{},
    );

    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Size);
    ecs.COMPONENT(world, Speed);

    ecs.TAG(world, Player);

    _ = ecs.ADD_SYSTEM(
        world,
        "init player",
        ecs.OnStart,
        init_player_system,
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "move player",
        ecs.OnUpdate,
        move_player_system,
        &.{
            .{ .id = ecs.id(Player) },
        },
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw player",
        ecs.OnUpdate,
        draw_player_system,
        &.{
            .{ .id = ecs.id(Player) },
        },
    );

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        _ = ecs.progress(world, 0);
    }
}
