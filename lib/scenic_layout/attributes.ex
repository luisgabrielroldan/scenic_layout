defmodule ScenicLayout.Attributes do
  @moduledoc false

  alias ScenicLayout.{
    EdgeSizes,
    Rect
  }

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
