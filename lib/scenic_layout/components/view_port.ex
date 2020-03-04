defmodule ScenicLayout.Components.ViewPort do
  @moduledoc false

  use ScenicLayout.Components.ViewGroup

  defmacro view_port(attrs \\ [], do: block) do
    viewport =
      %__MODULE__{
        content: Rect.zero(),
        margin: EdgeSizes.zero(),
        padding: EdgeSizes.zero()
      }
      |> parse_attrs(attrs)
      |> Macro.escape()

    quote do
      def viewport(viewport_status) do
        %{size: {vp_w, vp_h}} = viewport_status

        %{
          margin: margin,
          padding: padding
        } = viewport = unquote(viewport)

        {:ok, var!(pid, :builder) = builder} = Builder.start()

        viewport =
          Map.put(
            viewport,
            :content,
            %{
              viewport.content
              | width: vp_w,
                height: vp_h - (margin.top + margin.bottom + padding.top + padding.bottom)
            }
          )

        viewport =
          Builder.register_view(
            builder,
            viewport
          )

        Builder.with_scope(builder, viewport.id, fn ->
          unquote(block)
        end)

        registry = Builder.get_registry(builder)

        :ok = Builder.stop(builder)

        registry
      end
    end
  end
end
