const rl = @import("raylib");
const ecs = @import("zflecs");

const shared = @import("shared.zig");
const player = @import("player.zig");
const invaders = @import("invaders.zig");
const bullets = @import("bullets.zig");
const render = @import("render.zig");
const collision = @import("collision.zig");

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

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        _ = ecs.progress(world, 0);
    }
}
