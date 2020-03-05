defmodule ScenicLayout.Components.View do
  @moduledoc false

  alias ScenicLayout.{EdgeSizes, Rect}

  @view_fields [
    id: nil,
    client_id: nil,
    parent: nil,
    content: nil,
    margin: nil,
    padding: nil
  ]

  defmacro __using__(opts \\ []) do
    extra_fields =
      Keyword.get(opts, :fields, [])
      |> Keyword.merge(@view_fields)

    quote do
      alias ScenicLayout.{
        Block,
        Builder,
        EdgeSizes,
        Rect
      }

      import ScenicLayout.Attributes, only: [parse_attrs: 2]

      defstruct unquote(extra_fields)

      def render(_view, graph, _registry),
        do: graph

      defdelegate calculate_layout(view, registry), to: Block
      defdelegate calculate_block_width(view, registry), to: Block
      defdelegate calculate_block_position(view, registry), to: Block

      defoverridable render: 3,
                     calculate_layout: 2,
                     calculate_block_width: 2,
                     calculate_block_position: 2
    end
  end

  def margin_box(view) do
    %{
      padding: %{top: pt, right: pr, bottom: pb, left: pl},
      margin: %{top: mt, right: mr, bottom: mb, left: ml},
      content: %{width: cw, height: ch}
    } = view

    %{
      Rect.zero()
      | width: ml + pl + cw + mr + pr,
        height: mt + pt + ch + mb + pb
    }
  end
end
