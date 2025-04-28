defmodule Vite do
  @moduledoc """
  Documentation for `Vite`.
  """
  alias Vite.View
  alias Vite.React

  defdelegate vite_client(app_name), to: View
  defdelegate vite_snippet(app_name, entry_name), to: View
  defdelegate inlined_phx_manifest(app_name), to: View
  defdelegate react_refresh_snippet(app_name), to: React

  def is_prod() do
    Vite.Config.current_env() == :prod
  end
end
