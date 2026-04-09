const ecs = @import("zflecs");
const rl = @import("raylib");

const shared = @import("shared.zig");

pub const Shield = struct {};
pub const Health = struct { value: u32 };

fn init_shields_system(it: *ecs.iter_t) void {
    const shield_count = 4;
    const shield_width = 80.0;
    const shield_height = 60.0;
    const shield_start_x = 150.0;
    const shield_y = 450.0;
    const shield_spacing = 150.0;

    for (0..shield_count) |i| {
        const shield = ecs.new_id(it.world);
        _ = ecs.set(it.world, shield, shared.Position, .{
            .x = shield_start_x + @as(f32, @floatFromInt(i)) * shield_spacing,
            .y = shield_y,
        });
        _ = ecs.set(it.world, shield, shared.Size, .{
            .width = shield_width,
            .height = shield_height,
        });
        _ = ecs.set(it.world, shield, Health, .{ .value = 10 });

        ecs.add(it.world, shield, Shield);
    }
}

fn draw_shields_system(
    positions: []const shared.Position,
    sizes: []const shared.Size,
    healths: []const Health,
) void {
    for (positions, sizes, healths) |pos, siz, h| {
        const alpha = @as(u8, @intCast(@min(255, h.value * 25)));

        rl.drawRectangle(
            @intFromFloat(pos.x),
            @intFromFloat(pos.y),
            @intFromFloat(siz.width),
            @intFromFloat(siz.height),
            rl.Color{ .r = 0, .g = 255, .b = 255, .a = alpha },
        );
    }
}

pub fn init(world: *ecs.world_t) void {
    ecs.TAG(world, Shield);
    ecs.COMPONENT(world, Health);

    _ = ecs.ADD_SYSTEM(world, "spawn shields", ecs.OnStart, init_shields_system);

    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "draw shields", ecs.OnUpdate, draw_shields_system, &.{
        .{ .id = ecs.id(Shield) },
        shared.no_game_over_term(),
    });
}
