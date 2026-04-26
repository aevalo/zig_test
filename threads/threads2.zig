// Condition Variables and Mutexes
//
// This Zig code snippet is an excellent example of the use of condition
// variables (Condition Variable) and mutexes (Mutex). In concurrent
// programming, condition variables are used for synchronization between
// threads, particularly when certain conditions change. Below is a detailed
// explanation of the code.

const std = @import("std");
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const spawn = Thread.spawn;
const SpawnConfig = Thread.SpawnConfig;

var mutex = Mutex{};
var cond = Thread.Condition{};
var ready = false;

fn worker() void {
    mutex.lock();
    defer mutex.unlock();
    std.debug.print("Worker: {} lock, checking ready status...\n", .{Thread.getCurrentId()});

    while (!ready) {
        std.debug.print("Worker: Ready is false, waiting on condition...\n", .{});
        cond.wait(&mutex);
    }

    std.debug.print("Worker: Ready is true, proceeding...\n", .{});
    std.debug.print("Worker: Released lock, exiting...\n", .{});
}

pub fn main() !void {
    std.debug.print("Main: Spawning worker thread...\n", .{});

    const thread = spawn(.{}, worker, .{}) catch unreachable;

    std.debug.print("Main: Sleeping for 1 second...\n", .{});
    std.time.sleep(1 * std.time.ns_per_s);

    {
        mutex.lock();
        defer mutex.unlock();
        std.debug.print("Main: mutex lock, setting ready to true...\n", .{});

        ready = true;
        cond.signal();

        std.debug.print("Main: Released lock, signalled condition...\n", .{});
    }

    thread.join();

    std.debug.print("Main: Worker thread joined, exiting main...\n", .{});
}