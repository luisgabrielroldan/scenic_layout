defmodule ScenicLayout.Components.ViewGroup do
  @view_group_fields [
    children: [],
    orientation: :vertical
  ]

  defmacro __using__(opts \\ []) do
    extra_fields =
      Keyword.get(opts, :fields, [])
      |> Keyword.merge(@view_group_fields)

    quote do
      use ScenicLayout.Components.View,
        fields: unquote(extra_fields)

      def render(%{children: children} = view, graph, registry) do
        %{content: content} = view

        Scenic.Primitives.group(
          graph,
          fn graph1 ->
            view.children
            |> Enum.map(&Map.fetch!(registry, &1))
            |> Enum.reduce(graph1, fn %view_module{} = view1, graph2 ->
              view_module.render(view1, graph2, registry)
            end)
          end,
          translate: {content.x, content.y},
          scissor: {content.width, content.height},
          id: view.client_id
        )

        # |> Scenic.Primitives.rectangle(
        #   {content.width, content.height},
        #   stroke: {1, :white},
        #   translate: {content.x, content.y}
        # )
      end
    end
  end
end
