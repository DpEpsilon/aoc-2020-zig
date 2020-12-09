const std = @import("std");

const INPUT_BUFFER_LEN = 4096 * 4;
const WIDTH = 31;
const LINE_LEN_BYTES = WIDTH + 1; // Very nice -- can fit two in a cache line

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    // The input is small enough that we can read it all into memory
    var buffer = try alloc.alloc(u8, INPUT_BUFFER_LEN);
    var input_len = try stdin.readAll(buffer);
    var input_slice = buffer[0..input_len];

    var dx = [_]usize{ 1, 3, 5, 7, 1 };
    var dy = [_]usize{ 1, 1, 1, 1, 2 };

    var num_lines = input_len / LINE_LEN_BYTES;
    var y: usize = 0;
    var xs = [_]usize{0} ** 5;
    var num_trees = [_]usize{0} ** 5;
    while (y < num_lines) {
        for (xs) |*x, i| {
            if (y % dy[i] == 0) {
                if (input_slice[y * LINE_LEN_BYTES + x.*] == '#') {
                    num_trees[i] += 1;
                }
                x.* = (x.* + dx[i]) % WIDTH;
            }
        }
        y += 1;
    }
    var answer: usize = 1;
    for (num_trees) |trees, i| {
        answer *= trees;
        try stdout.print("{}: {}\n", .{ i, trees });
    }
    try stdout.print("{}\n", .{answer});
}
