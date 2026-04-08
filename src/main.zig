const rl = @import("raylib");
const ecs = @import("zflecs");

const zig_invaders = @import("zig_invaders");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + other.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: f32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
};

const Position = struct { x: f32, y: f32 };
const Size = struct { width: f32, height: f32 };
const Speed = struct { speed: f32 };
const Color = struct { color: rl.Color };
const Player = struct {};
const Bullet = struct {};
const Invader = struct {};
const InvaderTimer = struct {
    elapsed: f32,
    interval: f32,
    direction: f32,
    speed: f32,
};

fn draw_title_system(it: *ecs.iter_t) void {
    _ = it;
    rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
}

fn init_system(it: *ecs.iter_t) void {
    const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
    const player_width = 50.0;
    const player_height = 30.0;

    const player = ecs.new_entity(it.world, "Player");
    _ = ecs.set(it.world, player, Size, .{ .width = player_width, .height = player_height });
    _ = ecs.set(it.world, player, Position, .{
        .x = screen_width / 2 - player_width / 2,
        .y = screen_height - 60.0,
    });
    _ = ecs.set(it.world, player, Speed, .{ .speed = 5.0 });
    _ = ecs.set(it.world, player, Color, .{ .color = rl.Color.blue });
    ecs.add(it.world, player, Player);

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
            _ = ecs.set(it.world, invader, Position, .{
                .x = invader_start_x + @as(f32, @floatFromInt(col)) * invader_spacing_x,
                .y = invader_start_y + @as(f32, @floatFromInt(row)) * invader_spacing_y,
            });
            _ = ecs.set(it.world, invader, Size, .{ .width = invader_width, .height = invader_height });
            _ = ecs.set(it.world, invader, Color, .{ .color = rl.Color.green });
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

fn move_player_system(positions: []Position, speeds: []const Speed, sizes: []const Size) void {
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

fn draw_rect_system(positions: []const Position, sizes: []const Size, colors: []const Color) void {
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

fn shoot_bullet_system(it: *ecs.iter_t) void {
    const bulletWidth = 4.0;
    const bulletHeight = 10.0;

    var player_it = ecs.each(it.world, Player);
    while (ecs.each_next(&player_it)) {
        for (player_it.entities()) |player_entity| {
            const player_pos = ecs.get(it.world, player_entity, Position).?;
            const player_size = ecs.get(it.world, player_entity, Size).?;

            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                const bullet = ecs.new_id(it.world);

                _ = ecs.set(
                    it.world,
                    bullet,
                    Position,
                    .{
                        .x = player_pos.x + player_size.width / 2 - bulletWidth / 2,
                        .y = player_pos.y,
                    },
                );
                _ = ecs.set(
                    it.world,
                    bullet,
                    Size,
                    .{ .width = bulletWidth, .height = bulletHeight },
                );
                _ = ecs.set(
                    it.world,
                    bullet,
                    Speed,
                    .{ .speed = 10.0 },
                );

                ecs.add(it.world, bullet, Bullet);
            }
        }
    }
}

fn draw_bullets_system(
    it: *ecs.iter_t,
    positions: []Position,
    sizes: []const Size,
    speeds: []const Speed,
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


fn move_invaders_system(
    it: *ecs.iter_t,
    positions: []Position,
    sizes: []const Size,
) void {
    const invaders_drop_distance = 20.0;

    const timer = ecs.get_mut(
        it.world,
        ecs.id(InvaderTimer),
        InvaderTimer,
    ).?;

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
    _ = ecs.set_id(
        world,
        rest_id,
        rest_id,
        @sizeOf(ecs.EcsRest),
        &ecs.EcsRest{},
    );

    ecs.COMPONENT(world, Position);
    ecs.COMPONENT(world, Size);
    ecs.COMPONENT(world, Speed);
    ecs.COMPONENT(world, Color);
    ecs.COMPONENT(world, InvaderTimer);

    ecs.TAG(world, Player);
    ecs.TAG(world, Bullet);
    ecs.TAG(world, Invader);

    _ = ecs.ADD_SYSTEM(
        world,
        "init",
        ecs.OnStart,
        init_system,
    );
    _ = ecs.ADD_SYSTEM(
        world,
        "draw title",
        ecs.OnUpdate,
        draw_title_system,
    );
    _ = ecs.ADD_SYSTEM(
        world,
        "shoot bullets",
        ecs.OnUpdate,
        shoot_bullet_system,
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "draw bullets",
        ecs.OnUpdate,
        draw_bullets_system,
        &.{
            .{ .id = ecs.id(Bullet) },
        },
    );
    _ = ecs.ADD_SYSTEM(
        world,
        "draw rects",
        ecs.OnUpdate,
        draw_rect_system,
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "move player",
        ecs.OnUpdate,
        move_player_system,
        &.{
            .{ .id = ecs.id(Player) },
        },
    );
    _ = ecs.ADD_SYSTEM_WITH_FILTERS(
        world,
        "move invaders",
        ecs.OnUpdate,
        move_invaders_system,
        &.{
            .{ .id = ecs.id(Invader) },
        },
    );

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        _ = ecs.progress(world, 0);
    }
}
