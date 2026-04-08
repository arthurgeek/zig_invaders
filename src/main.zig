const rl = @import("raylib");
const ecs = @import("zflecs");

const shared = @import("shared.zig");
const player = @import("player.zig");
const invaders = @import("invaders.zig");
const bullets = @import("bullets.zig");
const render = @import("render.zig");
const collision = @import("collision.zig");

fn restart_system(it: *ecs.iter_t) void {
    if (!rl.isKeyPressed(rl.KeyboardKey.enter)) return;

    const score = ecs.get_mut(it.world, ecs.id(shared.Score), shared.Score).?;
    score.value = 0;

    var bullet_it = ecs.each(it.world, bullets.Bullet);
    while (ecs.each_next(&bullet_it)) {
        for (bullet_it.entities()) |bullet| ecs.delete(it.world, bullet);
    }

    var invader_it = ecs.each(it.world, invaders.Invader);
    while (ecs.each_next(&invader_it)) {
        for (invader_it.entities()) |invader| ecs.delete(it.world, invader);
    }

    var player_it = ecs.each(it.world, player.Player);
    while (ecs.each_next(&player_it)) {
        for (player_it.entities()) |p| ecs.delete(it.world, p);
    }

    player.spawn(it.world);
    invaders.spawn(it.world);

    ecs.remove(it.world, ecs.id(shared.GameOver), shared.GameOver);
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
    _ = ecs.set_id(world, rest_id, rest_id, @sizeOf(ecs.EcsRest), &ecs.EcsRest{});

    shared.init(world);
    player.init(world);
    invaders.init(world);
    bullets.init(world);
    render.init(world);
    collision.init(world);
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(world, "restart", ecs.OnUpdate, restart_system, &.{
        shared.game_over_term(),
    });

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        _ = ecs.progress(world, 0);
    }
}
