const rl = @import("raylib");
const ecs = @import("zflecs");
const shared = @import("shared.zig");

pub const Player = struct {};

fn init_player_system(it: *ecs.iter_t) void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const player_width = 50.0;
    const player_height = 30.0;

    const player = ecs.new_entity(it.world, "Player");
    _ = ecs.set(it.world, player, shared.Size, .{ .width = player_width, .height = player_height });
    _ = ecs.set(it.world, player, shared.Position, .{
        .x = screen_width / 2 - player_width / 2,
        .y = screen_height - 60.0,
    });
    _ = ecs.set(it.world, player, shared.Speed, .{ .speed = 5.0 });
    _ = ecs.set(it.world, player, shared.Color, .{ .color = rl.Color.blue });
    ecs.add(it.world, player, Player);
}

fn move_player_system(positions: []shared.Position, speeds: []const shared.Speed, sizes: []const shared.Size) void {
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

pub fn init(world: *ecs.world_t) void {
    ecs.TAG(world, Player);

    _ = ecs.ADD_SYSTEM(world, "init player", ecs.OnStart, init_player_system);
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "move player", ecs.OnUpdate, move_player_system, &.{
        .{ .id = ecs.id(Player) },
    });
}
