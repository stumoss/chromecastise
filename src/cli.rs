use clap::{crate_version, App, AppSettings, Arg};

pub fn build_cli() -> App<'static, 'static> {
    App::new("chromecastise")
        .version(crate_version!())
        .author("Stuart Moss <samoss@gmail.com>")
        .setting(AppSettings::ArgRequiredElseHelp)
        .arg(
            Arg::with_name("mp4")
                .long("mp4")
                .short("a")
                .help("Use mp4 as the output container format")
                .conflicts_with("mkv")
                .takes_value(false),
        )
        .arg(
            Arg::with_name("mkv")
                .long("mkv")
                .short("b")
                .help("Use mkv as the output container format")
                .conflicts_with("mp4")
                .takes_value(false),
        )
        .arg(
            Arg::with_name("test")
                .required(false)
                .long("test")
                .short("t")
                .help("Test to see if conversion is required")
                .takes_value(false),
        )
        .arg(
            Arg::with_name("file")
                .required(true)
                .index(1)
                .multiple(true)
                .takes_value(true)
                .help("The files to convert"),
        )
}
