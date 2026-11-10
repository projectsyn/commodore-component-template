// main template for {{ cookiecutter.slug}}
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.{{ cookiecutter.parameter_key }};
local instance = inv.parameters._instance;

// Define outputs below
{
  [if params.createNamespace then '00_namespace']: kube.Namespace(params.namespace) + {
    metadata+: {
      labels+:
        {
          component: '{{ cookiecutter.slug }}',
          instance: instance,
        }
        + params.namespaceLabels,
      annotations+:
        {
          'syn.tools/source': '{{ cookiecutter.github_url }}',
        }
        + params.namespaceAnnotations,
    },
  },
}
