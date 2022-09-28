#!/usr/bin/env python3

import atexit
import subprocess
import sys
import time
from distutils.dir_util import copy_tree
from os import path
from pathlib import Path
from shutil import copy2, rmtree

LOCALES = ["en", "fr-FR", "de-DE", "sv", "no", "pl", "br-PT", "it", "ja", "ro", "th", "tr", "uk", "vi"]
BENCHMARK_CONFIG_FILE = "Benchmark/example.config"

# Setup exit handler


@atexit.register
def exit_handler():
    rmtree("Benchmark/")


# Create directory if needed
print("Setting up benchmark directory")

Path("Benchmark/").mkdir(parents=True, exist_ok=True)
Path("Benchmark/Strings").mkdir(parents=True, exist_ok=True)

# Replace `Example` with `Benchmark` in config file
with open("Example/example.config", "rt", encoding="utf-8") as fin:
    with open(BENCHMARK_CONFIG_FILE, "wt", encoding="utf-8") as fout:
        for line in fin:
            fout.write(line.replace("Example", "Benchmark"))

# Copy template files
TEMPLATE_FILES_FOLDER = "Example/Template Files/"
copy_tree(TEMPLATE_FILES_FOLDER, "Benchmark/Template Files/")

# Copying over screenshots and titles
for locale in LOCALES:
    print(f"Copying files for {locale}")
    for device in ["iPhone X", "iPad Pro"]:
        screenshot_source_folder = f"Example/Screenshots/{device}/en"
        screenshot_target_folder = f"Benchmark/Screenshots/{device}/{locale}"
        copy_tree(screenshot_source_folder, screenshot_target_folder)

    STRING_SOURCE_FILE = "Example/Strings/en.strings"
    STRING_DESTINATION_FILE = f"Benchmark/Strings/{locale}.strings"
    copy2(STRING_SOURCE_FILE, STRING_DESTINATION_FILE)

# Clear .build directory
if path.exists(".build"):
    rmtree(".build")

# Compile SwiftFrame
compile_process = subprocess.run("swift build -c release", shell=True, check=True)

if compile_process.returncode != 0:
    exit(compile_process.returncode)

# Running benchmark
benchmark_start = time.time()
run_process = subprocess.run(
    ".build/release/swiftframe Benchmark/example.config --verbose --output-whole-image", shell=True, check=True
)
benchmark_end = time.time()

if run_process.returncode != 0:
    sys.exit(compile_process.returncode)

print(f"Benchmark finished in {benchmark_end - benchmark_start}s")
