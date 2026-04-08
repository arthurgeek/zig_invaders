const rl = @import("raylib");
const ecs = @import("zflecs");
const shared = @import("shared.zig");
const player = @import("player.zig");

pub const Bullet = struct {};

fn shoot_bullet_system(it: *ecs.iter_t) void {
    const bullet_width = 4.0;
    const bullet_height = 10.0;

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
                ecs.add(it.world, bullet, Bullet);
            }
        }
    }
}

fn move_bullets_system(
    it: *ecs.iter_t,
    positions: []shared.Position,
    sizes: []const shared.Size,
    speeds: []const shared.Speed,
) void {
    for (it.entities(), positions, sizes, speeds) |bullet, *pos, size, spd| {
        pos.y -= spd.speed;

        if (pos.y < 0) {
            ecs.delete(it.world, bullet);
        }

        rl.drawRectangle(
            @intFromFloat(pos.x),
            @intFromFloat(pos.y),
            @intFromFloat(size.width),
            @intFromFloat(size.height),
            rl.Color.red,
        );
    }
}

pub fn init(world: *ecs.world_t) void {
    ecs.TAG(world, Bullet);

    _ = ecs.ADD_SYSTEM(world, "shoot bullets", ecs.OnUpdate, shoot_bullet_system);
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "move bullets", ecs.OnUpdate, move_bullets_system, &.{
        .{ .id = ecs.id(Bullet) },
    });
}
