defmodule Vite.Config do
  alias Vite.Cache
  require Logger

  def all() do
    %{
      apps: apps(),
      current_env: current_env(),
      json_library: json_library()
    }
  end

  def all(app_name) do
    app_config = get_app_config(app_name)

    %{
      release_app: app_config[:release_app],
      current_env: current_env(),
      vite_manifest: app_config[:vite_manifest],
      phx_manifest: app_config[:phx_manifest],
      json_library: json_library(),
      dev_server_address: app_config[:dev_server_address],
      full_vite_manifest: full_vite_manifest(app_name),
      full_phx_manifest: full_phx_manifest(app_name)
    }
  end

  def apps() do
    Application.get_env(:vite_phx, :apps, [])
  end

  def get_app_config(app_name) do
    apps()
    |> Enum.find(fn app -> app[:name] == app_name end)
    |> case do
      nil ->
        Logger.error("App #{app_name} not found in Vite.Config. Check your configuration.")
        %{}
      config -> config
    end
  end

  def release_app(app_name) do
    get_app_config(app_name)[:release_app] ||
      Logger.error(
        "Configuration for Vite release_app missing for #{app_name}! Provide via configuration."
      )
  end

  def current_env() do
    Application.get_env(:vite_phx, :environment, :dev)
  end

  def phx_manifest(app_name) do
    get_app_config(app_name)[:phx_manifest] || "priv/static/cache_manifest.json"
  end

  def vite_manifest(app_name) do
    get_app_config(app_name)[:vite_manifest] || "priv/static/manifest.json"
  end

  def dev_server_address(app_name) do
    get_app_config(app_name)[:dev_server_address] || "http://localhost:3000"
  end

  def json_library() do
    Application.get_env(:vite_phx, :json_library, Phoenix.json_library())
  end

  def full_vite_manifest(app_name) do
    in_release_path(app_name, vite_manifest(app_name))
  end

  def full_phx_manifest(app_name) do
    in_release_path(app_name, phx_manifest(app_name))
  end

  def in_release_path(app_name, file) do
    Application.app_dir(release_app(app_name), file)
  end
end
