defmodule ScenicLayout.Components.Box do
  @moduledoc false

  use ScenicLayout.Components.View,
    fields: [
      color: nil
    ]

  defmacro box(attrs \\ []) do
    view =
      %__MODULE__{
        content: Rect.fill_parent(),
        margin: EdgeSizes.zero(),
        padding: EdgeSizes.zero()
      }
      |> parse_attrs(attrs)
      |> Map.put(:color, attrs[:color] || :red)
      |> Macro.escape()

    quote do
      Builder.register_view(var!(pid, :builder), unquote(view))
    end
  end

  def render(view, graph, _registry, _opts) do
    Scenic.Primitives.rectangle(
      graph,
      {view.content.width, view.content.height},
      fill: view.color,
      translate: {view.content.x, view.content.y},
      id: view.id
    )
  end
end
