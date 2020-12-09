const std = @import("std");

const INPUT_BUFFER_LEN = 4096 * 2;
const NUM_TO_SUM_TO = 2020;

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    // We could use a packed integer array here, but that's overkill
    // (and I can't get it to work)
    var seen_array = [_]u8{0} ** (NUM_TO_SUM_TO + 1);

    var curr_num: u32 = 0;

    var buffer = try alloc.alloc(u8, INPUT_BUFFER_LEN);
    const input_len = try stdin.read(buffer);
    var input_slice = buffer[0..input_len];

    for (input_slice) |chr| {
        if (chr >= '0' and chr <= '9') {
            // Parse number
            // Not sure how to do the equivalent of scanf
            curr_num *= 10;
            curr_num += chr - '0';
        } else if (chr == '\n') {
            // Done parsing number

            // Note that we've seen this number
            seen_array[curr_num] = 1;
            // Check whether we've seen the other number
            if (seen_array[NUM_TO_SUM_TO - curr_num] == 1) {
                try stdout.print("{}\n", .{curr_num * (NUM_TO_SUM_TO - curr_num)});
                return;
            }
            // Reset current number;
            curr_num = 0;
        } else {
            try stdout.print("Unexpected input\n", .{});
            return;
        }
    }
    try stdout.print("Reached end of output\n", .{});
}
