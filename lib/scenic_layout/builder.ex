defmodule ScenicLayout.Builder do
  @moduledoc false

  defstruct scopes: nil, next_id: nil, registry: nil

  def start() do
    Agent.start_link(fn ->
      %__MODULE__{
        scopes: [],
        next_id: 0,
        registry: %{}
      }
    end)
  end

  def stop(pid), do: Agent.stop(pid)

  def register_view(pid, view) do
    Agent.get_and_update(pid, fn %{next_id: view_id} = state ->
      parent = List.first(state.scopes)
      view = %{view | id: view_id, parent: parent}

      registry =
        state.registry
        |> Map.put(view_id, view)
        |> add_children(parent, view_id)

      state = %{
        state
        | next_id: view_id + 1,
          registry: registry
      }

      {view, state}
    end)
  end

  def get_registry(pid),
    do: Agent.get(pid, & &1) |> Map.get(:registry)

  def get_parent(pid) do
    Agent.get(pid, fn
      %{scopes: [current | _], registry: registry} ->
        Map.get(registry, current)

      _ ->
        nil
    end)
  end

  def with_scope(pid, scope, fun) do
    scope_push(pid, scope)
    fun.()
    scope_pop(pid)
  end

  defp scope_push(pid, scope) do
    Agent.update(pid, fn %{scopes: scopes} = state ->
      Map.put(state, :scopes, [scope | scopes])
    end)
  end

  defp scope_pop(pid) do
    Agent.get_and_update(pid, fn %{scopes: [scope | scopes]} = state ->
      {scope, Map.put(state, :scopes, scopes)}
    end)
  end

  defp add_children(registry, nil, _child_id),
    do: registry

  defp add_children(registry, parent_id, child_id) do
    parent = Map.fetch!(registry, parent_id)

    updated_parent =
      case parent do
        %{children: children} = parent1 ->
          %{parent1 | children: children ++ [child_id]}

        %type{} ->
          raise "#{type} is not a container view"
      end

    Map.put(registry, parent_id, updated_parent)
  end
end
