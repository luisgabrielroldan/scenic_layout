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

      defoverridable render: 3
    end
  end

  def margin_box_width(view) do
    %{
      padding: %{right: pr, left: pl},
      margin: %{right: mr, left: ml},
      content: %{width: cw}
    } = view

    ml + pl + cw + mr + pr
  end

  def margin_box_height(view) do
    %{
      padding: %{top: pt, bottom: pb},
      margin: %{top: mt, bottom: mb},
      content: %{height: ch}
    } = view

    mt + pt + ch + mb + pb
  end
end
