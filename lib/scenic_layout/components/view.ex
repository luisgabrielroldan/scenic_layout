defmodule ScenicLayout.Components.View do
  @moduledoc false

  alias ScenicLayout.{EdgeSizes, Rect}
  alias ScenicLayout.Components.View

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

      import View, only: [parse_attrs: 2]

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

  def parse_attrs(view, attrs) when is_list(attrs) do
    attrs = Enum.into(attrs, %{})

    %{
      view
      | margin: parse_margin(view.margin, attrs),
        padding: parse_padding(view.padding, attrs),
        content: parse_content_size(view.content, attrs),
        client_id: Map.get(attrs, :id)
    }
  end

  defp parse_content_size(content, attrs) do
    %{
      (content || %Rect{})
      | width: Map.get(attrs, :width, content.width),
        height: Map.get(attrs, :height, content.height)
    }
  end

  defp parse_margin(margin, attrs) do
    all = Map.get(attrs, :margin)

    %{
      (margin || %EdgeSizes{})
      | left: Map.get(attrs, :margin_left, all || margin.left),
        right: Map.get(attrs, :margin_right, all || margin.right),
        top: Map.get(attrs, :margin_top, all || margin.top),
        bottom: Map.get(attrs, :margin_bottom, all || margin.bottom)
    }
  end

  defp parse_padding(padding, attrs) do
    all = Map.get(attrs, :padding)

    %{
      (padding || %EdgeSizes{})
      | left: Map.get(attrs, :padding_left, all || padding.left),
        right: Map.get(attrs, :padding_right, all || padding.right),
        top: Map.get(attrs, :padding_top, all || padding.top),
        bottom: Map.get(attrs, :padding_bottom, all || padding.bottom)
    }
  end
end
