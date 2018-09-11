#![warn(rust_2018_idioms)]

use clap::{App, AppSettings, Arg, ArgMatches, crate_version};
use std::path::{Path, PathBuf};
use std::process::Command;

const KNOWN_FILE_EXTENSIONS: [&str; 12] = [
    "mkv",
    "avi",
    "mp4",
    "3gp",
    "mov",
    "mpg",
    "mpeg",
    "qt",
    "wmv",
    "m2ts",
    "flv",
    "m4v",
];

const SUPPORTED_VIDEO_CODECS: [&str; 1] = ["AVC"];
const SUPPORTED_AUDIO_CODECS: [&str; 1] = ["AAC"];

const DEFAULT_VIDEO_CODEC: &str = "libx264";
const DEFAULT_AUDIO_CODEC: &str = "aac";

fn main() {
    let matches = parse_args();

    let container_format = if matches.is_present("mkv") {
        "mkv"
    } else {
        "mp4"
    };

    let files = matches
        .values_of("file")
        .expect("could not get file from arguments")
        .collect::<Vec<&str>>()
        .iter()
        .map(|&f| Path::new(f))
        .collect::<Vec<&Path>>();

    let test = matches.is_present("test");

    for file in files {
        process_file(file, container_format, test);
    }
}

fn process_file(file: &Path, container_format: &str, test: bool) {
    let ext = file.extension()
        .expect("failed to get extension from file")
        .to_str()
        .expect("failed to convert file to string");

    if !KNOWN_FILE_EXTENSIONS.contains(&ext) {
        println!("{} is not a supported video format", ext);
        return;
    }

    // TODO: Need to get video codec using mediainfo (or ideally a rust native
    // library) here.
    let output = Command::new("mediainfo")
        .arg("--Inform=Video;%Format%")
        .arg(file)
        .output()
        .expect("failed to get video format with mediainfo");

    let mut output_video_codec = DEFAULT_VIDEO_CODEC;
    let original_video_codec = std::str::from_utf8(&output.stdout)
        .expect("failed to extract video codec from output")
        .trim_right();

    if SUPPORTED_VIDEO_CODECS.contains(&original_video_codec.trim_right()) {
        output_video_codec = "copy";
    }

    // TODO: Need to get audio codec using mediainfo (or ideally a rust native
    // library) here.
    let output = Command::new("mediainfo")
        .arg("--Inform=Audio;%Format%")
        .arg(file)
        .output()
        .expect("failed to get audio format with mediainfo");

    let mut output_audio_codec = DEFAULT_AUDIO_CODEC;
    let original_audio_codec = std::str::from_utf8(&output.stdout)
        .expect("failed to extract audio codec from output")
        .trim_right();

    if SUPPORTED_AUDIO_CODECS.contains(&original_audio_codec.trim_right()) {
        output_audio_codec = "copy";
    }

    if output_video_codec == "copy" && output_audio_codec == "copy" && ext == container_format {
        println!(
            "{} - No conversion required",
            file.to_str().expect("failed to convert filename to string")
        );
        return;
    }

    let mut output_file = PathBuf::from(file.parent().expect("failed to get file.parent()"));
    output_file.push(format!(
        "{}_new.{}",
        file.file_stem()
            .expect("failed to get file_stem")
            .to_str()
            .expect("failed to convert file_stem to string"),
        container_format
    ));

    if !test {
        let cpu_count = num_cpus::get();

        // TODO: Find a rust native (or ffmpeg wrapper) to get do the
        // actual transcoding
        Command::new("ffmpeg")
            .arg("-threads")
            .arg(format!("{}", cpu_count))
            .arg("-i")
            .arg(&file)
            .arg("-map")
            .arg("0:0")
            .arg("-c:v")
            .arg(&output_video_codec)
            .arg("-preset")
            .arg("slow")
            .arg("-level")
            .arg("4.0")
            .arg("-crf")
            .arg("20")
            .arg("-bf")
            .arg("16")
            .arg("-b_strategy")
            .arg("2")
            .arg("-subq")
            .arg("10")
            .arg("-map")
            .arg("0:1")
            .arg("-c:a:0")
            .arg(&output_audio_codec)
            .arg("-b:a:0")
            .arg("128k")
            .arg("-strict")
            .arg("-2")
            .arg("-y")
            .arg(&output_file)
            .status()
            .expect("failed to transcode video with ffmpeg");
    }

    println!(
        "Transcoded file {}: Video: {} -> {} Audio: {} -> {}",
        file.to_str().expect("failed to convert path to string"),
        original_video_codec,
        output_video_codec,
        original_audio_codec,
        output_audio_codec
    );
}

fn parse_args<'a>() -> ArgMatches<'a> {
    App::new("chromecastise")
        .version(&crate_version!()[..])
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
                .help("The file(s) to convert"),
        )
        .get_matches()
}
