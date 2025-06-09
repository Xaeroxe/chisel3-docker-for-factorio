use std::env;
use std::path::PathBuf;
use std::process::{self, Command};

use clap::Parser;

/// Provides a basic wrapper adapting verilog2factorio into something we can call from any path
/// without being in the source directory for verilog2factorio.

#[derive(clap::Parser)]
struct Args {
    #[clap(long, short)]
    verbose: bool,
    /// Generate debug information. (A graph of the output circuit.)
    #[clap(long, short)]
    debug: bool,
    /// File to output the compiled blueprint to.
    #[clap(long, short)]
    output: Option<PathBuf>,
    /// Verilog modules to output blueprint for. (defaults to all).
    #[clap(long, short)]
    modules: Vec<String>,
    /// List of Verilog files to compile. (only has to be explicitly specified after -m).
    #[clap(long, short)]
    file: Vec<PathBuf>,
    /// Layout generator to use. annealing(default),matrix,chunkAnnealing
    #[clap(long, short)]
    generator: Option<String>,
}

fn main() {
    let args = Args::parse();

    let mut c = Command::new("./v2f");
    c.current_dir("/verilog2factorio");
    if args.verbose {
        c.arg("--verbose");
    }
    if args.debug {
        c.arg("--debug");
    }
    if let Some(output) = args.output {
        c.arg("--output");
        let output = if output.is_relative() {
            if let Ok(current_dir) = env::current_dir() {
                current_dir.join(output)
            } else {
                output
            }
        } else {
            output.canonicalize().unwrap_or(output)
        };
        c.arg(output);
    }
    if let Some(generator) = args.generator {
        c.args(["--generator", &generator]);
    }
    if !args.modules.is_empty() {
        c.arg("--modules");
        for module in &args.modules {
            c.arg(module);
        }
    }
    if !args.file.is_empty() {
        if !args.modules.is_empty() {
            c.arg("--files");
        }
        for file in args.file {
            let file = if file.is_relative() {
                if let Ok(current_dir) = env::current_dir() {
                    current_dir.join(file)
                } else {
                    file
                }
            } else {
                file.canonicalize().unwrap_or(file)
            };

            c.arg(file);
        }
    }
    if let Some(code) = c.status().expect("failed to spawn").code() {
        process::exit(code);
    }
}
