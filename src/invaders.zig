const rl = @import("raylib");
const ecs = @import("zflecs");
const shared = @import("shared.zig");

pub const Invader = struct {};
pub const InvaderTimer = struct {
    elapsed: f32,
    interval: f32,
    direction: f32,
    speed: f32,
};

fn init_invaders_system(it: *ecs.iter_t) void {
    const invader_width = 40.0;
    const invader_height = 30.0;
    const invader_rows = 5;
    const invader_cols = 11;
    const invader_start_x = 100.0;
    const invader_start_y = 50.0;
    const invader_spacing_x = 60.0;
    const invader_spacing_y = 40.0;

    for (0..invader_rows) |row| {
        for (0..invader_cols) |col| {
            const invader = ecs.new_id(it.world);
            _ = ecs.set(it.world, invader, shared.Position, .{
                .x = invader_start_x + @as(f32, @floatFromInt(col)) * invader_spacing_x,
                .y = invader_start_y + @as(f32, @floatFromInt(row)) * invader_spacing_y,
            });
            _ = ecs.set(it.world, invader, shared.Size, .{ .width = invader_width, .height = invader_height });
            _ = ecs.set(it.world, invader, shared.Color, .{ .color = rl.Color.green });
            ecs.add(it.world, invader, Invader);
        }
    }

    _ = ecs.set(it.world, ecs.id(InvaderTimer), InvaderTimer, .{
        .elapsed = 0.0,
        .interval = 0.5,
        .direction = 1.0,
        .speed = 8.0,
    });
}

fn move_invaders_system(
    it: *ecs.iter_t,
    positions: []shared.Position,
    sizes: []const shared.Size,
) void {
    const invaders_drop_distance = 20.0;

    const timer = ecs.get_mut(it.world, ecs.id(InvaderTimer), InvaderTimer).?;

    timer.elapsed += it.delta_time;

    if (timer.elapsed >= timer.interval) {
        timer.elapsed = 0;

        const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const next_x = timer.speed * timer.direction;

        var hit_edge = false;
        for (positions, sizes) |pos, size| {
            if (pos.x + next_x < 0 or pos.x + size.width + next_x > screen_width) {
                hit_edge = true;
                break;
            }
        }

        if (hit_edge) {
            for (positions) |*pos| {
                pos.y += invaders_drop_distance;
            }
            timer.direction *= -1.0;
        } else {
            for (positions) |*pos| {
                pos.x += next_x;
            }
        }
    }
}

pub fn init(world: *ecs.world_t) void {
    ecs.COMPONENT(world, InvaderTimer);
    ecs.TAG(world, Invader);

    _ = ecs.ADD_SYSTEM(world, "init invaders", ecs.OnStart, init_invaders_system);
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "move invaders", ecs.OnUpdate, move_invaders_system, &.{
        .{ .id = ecs.id(Invader) },
    });
}
