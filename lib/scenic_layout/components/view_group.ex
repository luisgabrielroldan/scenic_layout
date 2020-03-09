defmodule ScenicLayout.Components.ViewGroup do
  @view_group_fields [
    children: [],
    orientation: :vertical
  ]

  alias ScenicLayout.Components.View

  defmacro __using__(opts \\ []) do
    extra_fields =
      Keyword.get(opts, :fields, [])
      |> Keyword.merge(@view_group_fields)

    quote do
      use ScenicLayout.Components.View,
        fields: unquote(extra_fields)

      def render(%{children: children} = view, graph, registry, opts \\ []) do
        %{content: content} = view

        graph =
          Scenic.Primitives.group(
            graph,
            fn graph1 ->
              view.children
              |> Enum.map(&Map.fetch!(registry, &1))
              |> Enum.reduce(graph1, fn %view_module{} = view1, graph2 ->
                view1
                |> view_module.render(graph2, registry, opts)
                |> View.debug_render(view1, opts)
              end)
            end,
            translate: {content.x, content.y},
            scissor: {content.width, content.height},
            id: view.client_id
          )
          |> View.debug_render(view, opts)
      end
    end
  end
end
