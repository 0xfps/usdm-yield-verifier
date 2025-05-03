use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::{self, BufReader};

#[derive(Deserialize)]
struct Input {
    user: [u8; 20],
    user_stakes: Vec<Stake>,
    global_stakes: Vec<GlobalStake>,
    current_epoch: u64,
    epoch_yield: u64,
}

#[derive(Deserialize)]
struct Stake {
    amount: u64,
    start_epoch: u64,
}

#[derive(Deserialize)]
struct GlobalStake {
    user: [u8; 20],
    amount: u64,
    start_epoch: u64,
}

#[derive(Serialize)]
struct Output {
    user: [u8; 20],
    epoch: u64,
    yield_entitlement: u64,
}

fn main() -> io::Result<()> {
    let file = File::open("input.json")?;
    let reader = BufReader::new(file);
    let input: Input = serde_json::from_reader(reader)?;

    let user_duration: u64 = input
        .user_stakes
        .iter()
        .map(|s| s.amount * (input.current_epoch - s.start_epoch))
        .sum();

    let total_duration: u64 = input
        .global_stakes
        .iter()
        .map(|s| s.amount * (input.current_epoch - s.start_epoch))
        .sum();

    let yield_entitlement = if total_duration == 0 {
        0
    } else {
        (user_duration * input.epoch_yield) / total_duration
    };

    let result = Output {
        user: input.user,
        epoch: input.current_epoch,
        yield_entitlement,
    };

    let out = File::create("output.json")?;
    serde_json::to_writer_pretty(out, &result)?;
    Ok(())
}

