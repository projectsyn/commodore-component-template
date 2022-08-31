import os
import shutil

from pathlib import Path

import yaml

create_lib = "{{ cookiecutter.add_lib }}" == "y"
add_golden = "{{ cookiecutter.add_golden }}" == "y"

if not create_lib:
    shutil.rmtree("lib")

test_cases = "{{ cookiecutter.test_cases }}"

tests_dir = Path("tests")
tests_dir.mkdir(exist_ok=True)

for case in test_cases.split(" "):
    f = tests_dir / f"{case}.yml"
    with open(f, "w", encoding="utf-8") as testf:
        testf.write("# Overwrite parameters here\n\n# parameters: {...}\n")

    g = (
        tests_dir
        / "golden"
        / case
        / "{{ cookiecutter.slug }}"
        / "apps"
        / "{{ cookiecutter.slug }}.yaml"
    )
    g.parent.mkdir(exist_ok=True, parents=True)
    g.touch()

if not add_golden:
    shutil.rmtree("tests/golden")

if Path(".sync.yml").is_file():
    os.unlink(Path(".sync.yml"))
