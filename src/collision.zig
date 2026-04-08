const ecs = @import("zflecs");
const shared = @import("shared.zig");
const invaders = @import("invaders.zig");
const bullets = @import("bullets.zig");

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
                    ecs.delete(it.world, bullet);
                    ecs.delete(it.world, invader);
                    break;
                }
            }
        }
    }
}

pub fn init(world: *ecs.world_t) void {
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "bullet invader collision", ecs.OnUpdate, bullet_invader_collision_system, &.{
        .{ .id = ecs.id(bullets.Bullet) },
    });
}
