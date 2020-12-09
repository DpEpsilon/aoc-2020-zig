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

    var num_lines = input_len / LINE_LEN_BYTES;
    var y: usize = 0;
    var x: usize = 0;
    var num_trees: usize = 0;
    while (y < num_lines) {
        if (input_slice[y * LINE_LEN_BYTES + x] == '#') {
            num_trees += 1;
        }
        x = (x + 3) % WIDTH;
        y += 1;
    }
    try stdout.print("{}\n", .{num_trees});
}
