defmodule ScenicLayout.Components.LinearLayout do
  @moduledoc false

  use ScenicLayout.Components.ViewGroup,
    fields: [
      orientation: nil
    ]

  defmacro linear_layout(attrs \\ [], do: block) do
    view =
      %__MODULE__{
        content: Rect.fill_parent(),
        margin: EdgeSizes.zero(),
        padding: EdgeSizes.zero(),
        orientation: attrs[:orientation] || :vertical
      }
      |> parse_attrs(attrs)
      |> Macro.escape()

    quote do
      builder = var!(pid, :builder)

      view = Builder.register_view(builder, unquote(view))

      Builder.with_scope(builder, view.id, fn ->
        unquote(block)
      end)
    end
  end
end
