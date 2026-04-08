const ecs = @import("zflecs");
const shared = @import("shared.zig");
const invaders = @import("invaders.zig");
const bullets = @import("bullets.zig");
const player = @import("player.zig");

fn bullet_invader_collision_system(
    it: *ecs.iter_t,
    bullet_positions: []const shared.Position,
    bullet_sizes: []const shared.Size,
) void {
    for (it.entities(), bullet_positions, bullet_sizes) |bullet, b_pos, b_size| {
        const b_rect = shared.Rectangle.from(b_pos, b_size);

        var inv_it = ecs.each(it.world, invaders.Invader);
        while (ecs.each_next(&inv_it)) {
            for (inv_it.entities()) |invader| {
                const i_pos = ecs.get(it.world, invader, shared.Position).?;
                const i_size = ecs.get(it.world, invader, shared.Size).?;

                if (b_rect.intersects(shared.Rectangle.from(i_pos.*, i_size.*))) {
                    const score = ecs.get_mut(it.world, ecs.id(shared.Score), shared.Score).?;
                    score.value += 10;
                    ecs.delete(it.world, bullet);
                    ecs.delete(it.world, invader);
                    break;
                }
            }
        }
    }
}

fn invader_bullet_player_collision_system(
    it: *ecs.iter_t,
    bullet_positions: []const shared.Position,
    bullet_sizes: []const shared.Size,
) void {
    for (bullet_positions, bullet_sizes) |b_pos, b_size| {
        const b_rect = shared.Rectangle.from(b_pos, b_size);

        var player_it = ecs.each(it.world, player.Player);
        while (ecs.each_next(&player_it)) {
            for (player_it.entities()) |player_entity| {
                const p_pos = ecs.get(it.world, player_entity, shared.Position).?;
                const p_size = ecs.get(it.world, player_entity, shared.Size).?;

                if (b_rect.intersects(shared.Rectangle.from(p_pos.*, p_size.*))) {
                    ecs.add(it.world, ecs.id(shared.GameOver), shared.GameOver);
                }
            }
        }
    }
}

pub fn init(world: *ecs.world_t) void {
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "bullet invader collision", ecs.OnUpdate, bullet_invader_collision_system, &.{
        .{ .id = ecs.id(bullets.Bullet) },
        .{ .id = ecs.id(bullets.InvaderBullet), .oper = .Not },
        shared.no_game_over_term(),
    });
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "invader bullet player collision", ecs.OnUpdate, invader_bullet_player_collision_system, &.{
        .{ .id = ecs.id(bullets.InvaderBullet) },
        shared.no_game_over_term(),
    });
}
