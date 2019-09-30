extern crate clap;

use clap::Shell;

include!("src/cli.rs");

fn main() {
    let outdir = match std::env::var_os("OUT_DIR") {
        None => return,
        Some(outdir) => outdir,
    };

    let mut app = build_cli();
    app.gen_completions("chromecastise", Shell::Bash, &outdir);
    app.gen_completions("chromecastise", Shell::Fish, &outdir);
    app.gen_completions("chromecastise", Shell::Zsh, &outdir);
}
