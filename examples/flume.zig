const std = @import("std");

const Ast = union(enum) {
    num: i64,
    ident: []const u8,
    add: struct { lhs: *const Ast, rhs: *const Ast },

    fn fold(self: *const Ast) ?i64 {
        return switch (self.*) {
            .num => |n| n,
            .ident => null,
            .add => |a| blk: {
                const l = a.lhs.fold() orelse break :blk null;
                const r = a.rhs.fold() orelse break :blk null;
                break :blk l + r;
            },
        };
    }
};

pub fn main() void {
    const lhs = Ast{ .num = 40 };
    const rhs = Ast{ .num = 2 };
    const expr = Ast{ .add = .{ .lhs = &lhs, .rhs = &rhs } };
    std.debug.print("{s} folded = {}\n", .{ @tagName(expr), expr.fold().? });
}
