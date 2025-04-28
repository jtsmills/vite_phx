# Vite
[Vite.js]: https://vitejs.dev/

Vite helps you to integrate [Vite.js] with Phoenix.

## Instructions

Add following lines to your layout template:

```elixir
<%# load the vite.js client script in dev/test environments %>
<%= Vite.vite_client(:my_app) %>


<%# When using React.js, also include this preamble hot refresh code %>
<%= Vite.react_refresh_snippet(:my_app) %>


<%#
entry point for your application
- delegates to [Vite.js] in dev / loads all modules / styles in production from the manifest.json
%>
<%= Vite.vite_snippet(:my_app, "src/main.tsx") %>
```

## Configuration

```elixir
# in config/config.exs

# Configure Vite
config :vite_phx,
  # to tell prod and dev env apart
  environment: Mix.env(),
  # configure multiple Vite apps
  apps: [
    [
      name: :my_app,
      release_app: :demo,
      # this manifest is different from the Phoenix "cache_manifest.json"!
      vite_manifest: "priv/static/manifest.json", # optional
      phx_manifest: "priv/static/cache_manifest.json", # optional
      dev_server_address: "http://localhost:3000" # optional
    ],
    [
      name: :another_app,
      release_app: :demo,
      vite_manifest: "priv/static/another_app/manifest.json",
      phx_manifest: "priv/static/another_app/cache_manifest.json",
      dev_server_address: "http://localhost:3001"
    ]
  ]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vite` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vite_phx, "~> 0.2"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/vite](https://hexdocs.pm/vite).
