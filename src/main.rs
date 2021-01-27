#![warn(rust_2018_idioms)]

use std::path::{Path, PathBuf};
use std::process::Command;

mod cli;

const SUPPORTED_VIDEO_CODECS: [&str; 1] = ["AVC"];
const SUPPORTED_AUDIO_CODECS: [&str; 1] = ["AAC"];

const DEFAULT_VIDEO_CODEC: &str = "libx264";
const DEFAULT_AUDIO_CODEC: &str = "aac";

fn main() {
    let matches = cli::build_cli().get_matches();

    let container_format = if matches.is_present("mp4") {
        "mp4"
    } else {
        "mkv"
    };

    let files = matches
        .values_of("file")
        .expect("could not get file from arguments")
        .collect::<Vec<&str>>()
        .iter()
        .map(|&f| Path::new(f))
        .filter(|&f| f.exists())
        .collect::<Vec<&Path>>();

    let test = matches.is_present("test");

    for file in files {
        println!("Processing file: {:?}", file);
        process_file(file, container_format, test);
    }
}

fn process_file(file: &Path, container_format: &str, test: bool) {
    let ext = file
        .extension()
        .expect("failed to get extension from file")
        .to_str()
        .expect("failed to convert file to string");

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
        .trim_end();

    if SUPPORTED_VIDEO_CODECS.contains(&original_video_codec.trim_end()) {
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
        .trim_end();

    if SUPPORTED_AUDIO_CODECS.contains(&original_audio_codec.trim_end()) {
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
