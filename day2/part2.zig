const std = @import("std");

const INPUT_BUFFER_LEN = 4096 * 2;

const State = enum {
    parse_min,
    parse_max,
    parse_letter,
    wait_for_space,
    parse_pw,
};

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var curr_num: u32 = 0;

    var buffer = try alloc.alloc(u8, INPUT_BUFFER_LEN);
    var input_len = try stdin.read(buffer);

    var state: State = State.parse_min;

    // min/max now no longer mean min/max, but I cbf changing the name
    var min: u32 = 0;
    var min_good: bool = false;
    var max: u32 = 0;
    var max_good: bool = false;
    var letter: u8 = 0;
    var pw_start: usize = 0;

    var num_valid: u32 = 0;
    var iterations: usize = 0;

    while (input_len != 0) {
        var input_slice = buffer[0..input_len];
        // State machine parsing character-by-character
        // I still don't know how to do the equivalent of scanf
        for (input_slice) |chr, i_mod_buffer| {
            const i = iterations * INPUT_BUFFER_LEN + i_mod_buffer;

            if (state == State.parse_min and chr >= '0' and chr <= '9') {
                min = min * 10 + chr - '0';
            } else if (state == State.parse_min and chr == '-') {
                state = State.parse_max;
            } else if (state == State.parse_max and chr >= '0' and chr <= '9') {
                max = max * 10 + chr - '0';
            } else if (state == State.parse_max and chr == ' ') {
                state = State.parse_letter;
            } else if (state == State.parse_letter) {
                letter = chr;
                state = State.wait_for_space;
            } else if (state == State.wait_for_space and chr == ':') {
                continue;
            } else if (state == State.wait_for_space and chr == ' ') {
                pw_start = i;
                state = State.parse_pw;
            } else if (state == State.parse_pw and chr == letter and i - pw_start == min) {
                min_good = true;
            } else if (state == State.parse_pw and chr == letter and i - pw_start == max) {
                max_good = true;
            } else if (state == State.parse_pw and chr == '\n') {
                if (min_good != max_good) {
                    num_valid += 1;
                }
                min = 0;
                min_good = false;
                max = 0;
                max_good = false;
                letter = 0;
                pw_start = 0;
                state = State.parse_min;
            } else if (state == State.parse_pw) {
                continue;
            } else {
                try stdout.print("Unexpected input at {}, {}\n", .{ i, state });
                return;
            }
        }
        input_len = try stdin.read(buffer);
        iterations += 1;
    }

    try stdout.print("{}\n", .{num_valid});
}
