const std = @import("std");
const rl = @import("raylib");
const ecs = @import("zflecs");
const shared = @import("shared.zig");

fn draw_title_system(it: *ecs.iter_t) void {
    _ = it;
    rl.drawText("Zig Invaders - SPACE to shoot, ESC to quit", 20, 20, 20, rl.Color.green);
}

fn draw_score_system(it: *ecs.iter_t) void {
    const score = ecs.get(it.world, ecs.id(shared.Score), shared.Score).?;
    const text = rl.textFormat(
        "Score: %d",
        .{score.value},
    );
    rl.drawText(
        text,
        20,
        rl.getScreenHeight() - 20,
        20,
        rl.Color.white,
    );
}

fn draw_rect_system(positions: []const shared.Position, sizes: []const shared.Size, colors: []const shared.Color) void {
    for (positions, sizes, colors) |pos, siz, col| {
        rl.drawRectangle(
            @intFromFloat(pos.x),
            @intFromFloat(pos.y),
            @intFromFloat(siz.width),
            @intFromFloat(siz.height),
            col.color,
        );
    }
}

fn draw_game_over_system(it: *ecs.iter_t) void {
    const score = ecs.get(it.world, ecs.id(shared.Score), shared.Score).?;

    rl.drawText("GAME OVER", 270, 250, 40, rl.Color.red);
    rl.drawText(rl.textFormat("Final Score: %d", .{score.value}), 285, 310, 30, rl.Color.white);
    rl.drawText("Press ENTER to play again or ESC to quit", 180, 360, 20, rl.Color.green);
}

pub fn init(world: *ecs.world_t) void {
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw title",
        ecs.OnUpdate,
        draw_title_system,
        &.{shared.no_game_over_term()},
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw rects",
        ecs.OnUpdate,
        draw_rect_system,
        &.{shared.no_game_over_term()},
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw score",
        ecs.OnUpdate,
        draw_score_system,
        &.{shared.no_game_over_term()},
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw game over",
        ecs.OnUpdate,
        draw_game_over_system,
        &.{shared.game_over_term()},
    );
}
