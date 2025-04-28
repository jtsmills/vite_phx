defmodule Vite.Manifest do
  alias Vite.ManifestReader
  require Logger

  @type entry_value :: binary() | list(binary()) | nil

  @spec read(atom()) :: map()
  def read(app_name) do
    ManifestReader.read_vite(app_name)
  end

  @spec entries(atom()) :: [list()]
  def entries(app_name) do
    read(app_name)
    |> Enum.filter(&isEntry/1)
    |> Enum.map(fn {_, value} -> value end)
    |> Enum.map(fn entry -> convert_item([], entry, app_name) end)
  end

  @spec entry(atom(), binary()) :: list()
  def entry(app_name, entry_name) do
    Enum.find(entries(app_name), &(Keyword.get(&1, :entry_name) == entry_name))
  end

  @spec isEntry({any, map()}) :: boolean()
  defp isEntry({_key, value}) do
    Map.get(value, "isEntry") == true
  end

  # %{
  #   "css" => ["assets/main.c14674d5.css"],
  #   "file" => "assets/main.9160cfe1.js",
  #   "imports" => ["_vendor.3b127d10.js"],
  #   "isEntry" => true,
  #   "src" => "src/main.tsx"
  # }
  defp convert_item(acc, raw_data, app_name) do
    css = Map.get(raw_data, "css", [])
    entry_name = Map.get(raw_data, "src")
    imports = Map.get(raw_data, "imports", [])
    acc = acc ++ [{:entry_name, entry_name}]
    acc = acc ++ Enum.map(css, fn file -> {:css, file} end)
    acc = acc ++ [{:module, Map.get(raw_data, "file")}]
    acc = Enum.reduce(imports, acc, fn file, innerAcc -> handle_import(innerAcc, file, app_name) end)
    acc |> Enum.uniq()
  end

  defp convert_item(acc, raw_data, app_name, :import) do
    css = Map.get(raw_data, "css", [])
    imports = Map.get(raw_data, "imports", [])
    import_module = {:import_module, Map.get(raw_data, "file")}

    acc = acc ++ Enum.map(css, fn file -> {:import_css, file} end)

    case Enum.member?(acc, import_module) do
      true ->
        acc

      false ->
        acc = acc ++ [import_module]

        acc = Enum.reduce(imports, acc, fn file, innerAcc -> handle_import(innerAcc, file, app_name) end)
        acc |> Enum.uniq()
    end
  end

  @spec get_file(atom(), binary()) :: entry_value()
  def get_file(app_name, file) do
    read(app_name) |> get_in([file, "file"]) |> raise_missing(file)
  end

  def handle_import(acc, file, app_name) do
    raw_data = read(app_name) |> Map.get(file)
    convert_item(acc, raw_data, app_name, :import)
  end

  @spec raise_missing(entry_value(), binary()) :: entry_value()
  defp raise_missing(check, file) do
    if is_nil(check) do
      raise("Could not find an entry for #{file} in the manifest!")
    else
      check
    end
  end
end
