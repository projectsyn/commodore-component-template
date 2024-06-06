import json
import os
import shutil

from pathlib import Path

import yaml

create_lib = "{{ cookiecutter.add_lib }}" == "y"
add_golden = "{{ cookiecutter.add_golden }}" == "y"
automerge_patch = "{{ cookiecutter.automerge_patch }}" == "y"
automerge_patch_v0 = "{{ cookiecutter.automerge_patch_v0 }}" == "y"

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

with open("renovate.json", "r", encoding="utf-8") as f:
    renovatejson = json.load(f)

# We always add an empty package rules list
renovatejson["packageRules"] = []

if automerge_patch:
    # automerge patch PRs
    patch_rule = {
        "matchUpdateTypes": ["patch"],
        # negative match: do not match versions that match regex `^v?0\.`
        "matchCurrentVersion": "!/^v?0\\./",
        "automerge": True,
        # NOTE: We can't use Platform Automerge because the repositories are configured manually,
        # so we can't be sure the "require status checks" option is always enabled, and without
        # that, platformAutomerge does not wait for tests to pass.
        "platformAutomerge": False,
        # NOTE: We need to add all the labels we want here, renovate doesn't inherit globally
        # specified labels for package rules
        "labels": ["dependency", "automerge"],
    }
    if automerge_patch_v0:
        # remove match current version if we want v0.x patch automerge
        del patch_rule["matchCurrentVersion"]

    renovatejson["packageRules"].append(patch_rule)

# NOTE: Later rules in `packageRules` take precedence

with open("renovate.json", "w", encoding="utf-8") as f:
    json.dump(renovatejson, f, indent=2)
    f.write("\n")

if Path(".sync.yml").is_file():
    os.unlink(Path(".sync.yml"))
