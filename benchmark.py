#!/usr/bin/env python3

import subprocess
from distutils.dir_util import copy_tree
from pathlib import Path
from shutil import copy2, rmtree
import os
import time

locales = ['en',
           'fr-FR',
           'de-DE',
           'sv',
           'no',
           'pl',
           'br-PT',
           'it',
           'ja',
           'ro',
           'th',
           'tr',
           'uk',
           'vi'
           ]
benchmark_config_file = 'Benchmark/example.config'

print("Setting up benchmark directory")

Path('Benchmark/').mkdir(parents=True, exist_ok=True)
Path('Benchmark/Strings').mkdir(parents=True, exist_ok=True)

# Replace `Example` with `Benchmark` in config file
with open('Example/example.config', 'rt') as fin:
    with open(benchmark_config_file, 'wt') as fout:
        for line in fin:
            fout.write(line.replace('Example', 'Benchmark'))

template_files_folder = 'Example/Template Files/'
copy_tree(template_files_folder, 'Benchmark/Template Files/')

for locale in locales:
    print(f'Copying files for {locale}')
    for device in ["iPhone X", 'iPad Pro']:
        screenshot_source_folder = f'Example/Screenshots/{device}/en'
        screenshot_target_folder = f'Benchmark/Screenshots/{device}/{locale}'
        copy_tree(screenshot_source_folder, screenshot_target_folder)

    string_source_file = 'Example/Strings/en.strings'
    string_destination_file = f'Benchmark/Strings/{locale}.strings'
    copy2(string_source_file, string_destination_file)

compile_process = subprocess.run(
    'swift build -c release', shell=True, check=True)

if compile_process.returncode != 0:
    exit(compile_process.returncode)

executable_path = os.path.realpath('.build/release')
benchmark_start = time.time()
run_process = subprocess.run(
    f'{executable_path}/swiftframe Benchmark/example.config', shell=True, check=True)
benchmark_end = time.time()

if run_process.returncode != 0:
    exit(compile_process.returncode)
else:
    rmtree('Benchmark/')

print(f'Benchmark finished in {benchmark_end - benchmark_start}s')
