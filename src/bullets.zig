const rl = @import("raylib");
const ecs = @import("zflecs");
const shared = @import("shared.zig");
const player = @import("player.zig");

pub const Bullet = struct {};
pub const InvaderBullet = struct {};

pub const bullet_width = 4.0;
pub const bullet_height = 10.0;

fn shoot_bullet_system(it: *ecs.iter_t) void {
    var player_it = ecs.each(it.world, player.Player);
    while (ecs.each_next(&player_it)) {
        for (player_it.entities()) |player_entity| {
            const player_pos = ecs.get(it.world, player_entity, shared.Position).?;
            const player_size = ecs.get(it.world, player_entity, shared.Size).?;

            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                const bullet = ecs.new_id(it.world);

                _ = ecs.set(it.world, bullet, shared.Position, .{
                    .x = player_pos.x + player_size.width / 2 - bullet_width / 2,
                    .y = player_pos.y,
                });
                _ = ecs.set(it.world, bullet, shared.Size, .{ .width = bullet_width, .height = bullet_height });
                _ = ecs.set(it.world, bullet, shared.Speed, .{ .speed = 10.0 });
                _ = ecs.set(it.world, bullet, shared.Direction, .{ .value = -1.0 });
                _ = ecs.set(it.world, bullet, shared.Color, .{ .color = rl.Color.red });
                ecs.add(it.world, bullet, Bullet);
            }
        }
    }
}

fn move_bullets_system(
    it: *ecs.iter_t,
    positions: []shared.Position,
    speeds: []const shared.Speed,
    directions: []const shared.Direction,
) void {
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    for (it.entities(), positions, speeds, directions) |bullet, *pos, spd, dir| {
        pos.y += spd.speed * dir.value;

        if (pos.y < 0 or pos.y > screen_height) {
            ecs.delete(it.world, bullet);
        }
    }
}

pub fn init(world: *ecs.world_t) void {
    ecs.TAG(world, Bullet);
    ecs.TAG(world, InvaderBullet);

    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "shoot bullets", ecs.OnUpdate, shoot_bullet_system, &.{
        shared.no_game_over_term(),
    });
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "move bullets", ecs.OnUpdate, move_bullets_system, &.{
        .{ .id = ecs.id(Bullet) },
        shared.no_game_over_term(),
    });
}
