# Commodore component template

This repository is part of Project Syn.
For documentation on Project Syn and this component, see https://syn.tools.

## Onboarding a component

See https://syn.tools/syn/how-tos/prepare_for_component_sync.html

## Triggering a sync

* Push or merge to `main`
* Via workflow dispatch (https://github.com/projectsyn/commodore-component-template/actions/workflows/sync.yaml)
You can provide a regex to only sync selected components via workflow dispatch.

## Notes regarding the template

The base template is stored in `{{ cookiecutter.slug }}`.
However, a part of the template is managed by a custom Python hook in `hooks/post_gen_project.py`

Notably, the Python hook will generate a suitable `renovate.json` for the rendered template.
We've switched to this approach since the logic that defines the contents of the `renovate.json` has become complex enough that templating JSON with Jinja2 isn't readable anymore.
