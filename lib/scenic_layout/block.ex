defmodule ScenicLayout.Block do
  @moduledoc false

  alias ScenicLayout.Components.View

  def calculate_layout(registry, view_id \\ 0) do
    %view_module{} = fetch_view!(registry, view_id)

    registry
    |> view_module.calculate_block_width(view_id)
    |> calculate_fill_parent(view_id)
    |> view_module.calculate_block_position(view_id)
  end

  def calculate_block_position(registry, view_id \\ 0) do
    %{
      padding: padding,
      margin: margin,
      content: %{height: content_height} = content
    } = view = fetch_view!(registry, view_id)

    content_height = content_height || 0

    content_x = margin.left + padding.left
    content_y = margin.top + padding.top

    view = %{view | content: %{content | x: content_x, y: content_y}}

    registry = update_view(registry, view)

    {content_height, registry} =
      case view do
        %{children: children} ->
          {children_height, registry1} = calculate_children_layout(children, registry)

          content_height =
            cond do
              is_number(content_height) and content_height < children_height ->
                children_height

              true ->
                content_height
            end

          {content_height, registry1}

        _ ->
          {content_height, registry}
      end

    view = %{view | content: %{view.content | height: content_height}}

    update_view(registry, view)
  end

  defp calculate_children_layout(children, registry) do
    registry =
      Enum.reduce(children, registry, fn child_id, registry1 ->
        %view_module{} = fetch_view!(registry1, child_id)

        view_module.calculate_block_position(registry1, child_id)
      end)

    {children_height, registry} =
      Enum.reduce(children, {0, registry}, fn child_id, {acc, registry1} ->
        child = fetch_view!(registry1, child_id)

        case child.content.height do
          :fill_parent ->
            {acc, registry1}

          _ ->
            height = View.margin_box(child).height

            registry1 =
              update_view(registry1, %{
                child
                | content: %{child.content | y: child.content.y + acc}
              })

            {acc + height, registry1}
        end
      end)

    {children_height, registry}
  end

  def calculate_block_width(registry, view_id \\ 0) do
    %{
      padding: padding,
      margin: margin,
      content: %{width: content_width} = content
    } = view = fetch_view!(registry, view_id)

    # The defaul is content because the only posible reason for no
    # parent is to be the ViewPort
    %{content: parent_content} = get_view(registry, view.parent, view)

    max_content_width =
      parent_content.width - (margin.left + margin.right + padding.left + padding.right)

    content_width =
      case content_width do
        :fill_parent ->
          max_content_width

        _ ->
          if content_width > max_content_width do
            max_content_width
          else
            content_width
          end
      end

    view = %{view | content: %{content | width: content_width}}

    registry = update_view(registry, view)

    case view do
      %{children: children} ->
        Enum.reduce(children, registry, fn child_id, registry1 ->
          %view_module{} = fetch_view!(registry1, child_id)

          view_module.calculate_block_width(registry1, child_id)
        end)

      _ ->
        registry
    end
  end

  defp calculate_fill_parent(registry, view_id) when is_integer(view_id) do
    view = fetch_view!(registry, view_id)
    do_calculate_fill_parent(registry, view)
  end

  defp do_calculate_fill_parent(registry, %{children: _} = view) do
    %{
      padding: padding,
      content: content
    } = view

    {with_fill, others} =
      view.children
      |> Enum.map(&fetch_view!(registry, &1))
      |> Enum.split_with(fn %{content: %{height: height}} ->
        height == :fill_parent
      end)

    registry =
      case with_fill do
        [] ->
          registry

        _ ->
          known_occupied_space =
            Enum.reduce(others, 0, fn child, acc ->
              View.margin_box(child).height + acc
            end)

          fill_height =
            div(
              content.height - (known_occupied_space + padding.top + padding.bottom),
              length(with_fill)
            )

          # Distribute in the available space between the children that 'fills the view'
          Enum.reduce(with_fill, registry, fn child, registry1 ->
            height =
              fill_height -
                (child.margin.top + child.margin.bottom + child.padding.top + child.padding.bottom)

            child = %{child | content: %{child.content | height: height}}

            update_view(registry1, child)
          end)
      end

    Enum.reduce(view.children, registry, fn child_id, registry1 ->
      calculate_fill_parent(registry1, child_id)
    end)
  end

  defp do_calculate_fill_parent(registry, _view),
    do: registry

  defp update_view(registry, %{id: view_id} = view) when is_integer(view_id),
    do: Map.put(registry, view_id, view)

  defp get_view(registry, view_id, default),
    do: Map.get(registry, view_id, default)

  defp fetch_view!(registry, view_id),
    do: Map.get(registry, view_id)
end
