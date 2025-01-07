local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.{{ cookiecutter.parameter_key }};
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('{{ cookiecutter.slug }}', params.namespace);

local appPath =
  local project = std.get(app, 'spec', { project: 'syn' }).project;
  if project == 'syn' then 'apps' else 'apps-%s' % project;

{
  ['%s/{{ cookiecutter.slug }}' % appPath]: app,
}
