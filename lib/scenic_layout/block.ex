defmodule ScenicLayout.Block do
  @moduledoc false

  alias ScenicLayout.Components.View

  def calculate_layout(registry) do
    registry
    |> calculate_block_width()
    |> calculate_block_height()
    |> calculate_missing_fill_heights()
    |> calculate_children_layout()
  end

  defp calculate_children_layout(registry, view_id \\ 0) do
    %{
      padding: padding,
      margin: margin,
      content: content
    } = view = fetch_view!(registry, view_id)

    view = %{
      view
      | content: %{
          content
          | x: content.x + margin.left + padding.left,
            y: content.y + margin.top + padding.top
        }
    }

    registry = update_view(registry, view)

    {_, registry} =
      case view do
        %{children: children} ->
          Enum.reduce(children, {0, registry}, fn child_id, {offset, registry1} ->
            child = fetch_view!(registry1, child_id)

            {offset, registry1} =
              case view.orientation do
                :vertical ->
                  content_y = child.content.y + offset

                  offset = offset + View.margin_box_height(child)

                  child = %{child | content: %{child.content | y: content_y}}

                  {offset, update_view(registry1, child)}

                :horizontal ->
                  content_x = child.content.x + offset

                  offset = offset + View.margin_box_width(child)

                  child = %{child | content: %{child.content | x: content_x}}

                  {offset, update_view(registry1, child)}
              end

            registry1 = calculate_children_layout(registry1, child_id)

            {offset, registry1}
          end)

        _ ->
          {0, registry}
      end

    registry
  end

  defp calculate_missing_fill_heights(registry, view_id \\ 0) do
    %{
      content: content
    } = view = fetch_view!(registry, view_id)

    registry =
      case view do
        %{children: children} ->
          dim =
            case view.orientation do
              :vertical -> :height
              :horizontal -> :width
            end

          {fillers, fixed} =
            children
            |> Enum.map(&fetch_view!(registry, &1))
            |> Enum.split_with(fn %{content: content} -> Map.get(content, dim) == :fill_parent end)
            |> IO.inspect()

          reserved_space =
            Enum.reduce(fixed, 0, fn fc, acc ->
              acc + Map.get(fc.content, dim)
            end)

          free_space = Map.get(content, dim) - reserved_space

          Enum.reduce(fillers, registry, fn filler, registry1 ->
            content = Map.put(filler.content, dim, free_space / length(fillers))

            filler = %{filler | content: content}

            update_view(registry1, filler)
          end)

        _ ->
          registry
      end

    case view do
      %{children: children} ->
        Enum.reduce(children, registry, fn child_id, registry1 ->
          %{
            padding: cp,
            margin: cm,
            content: cc
          } = child = fetch_view!(registry1, child_id)

          child =
            case cc do
              %{height: :fill_parent} ->
                height = content.height - (cm.top + cp.top + cp.bottom + cm.bottom)

                %{child | content: %{cc | height: height}}

              _ ->
                child
            end

          registry1
          |> update_view(child)
          |> calculate_missing_fill_heights(child.id)
        end)

      _ ->
        registry
    end
  end

  defp calculate_block_height(registry, view_id \\ 0) do
    %{
      content: content
    } = view = fetch_view!(registry, view_id)

    parent = get_view(registry, view.parent, view)

    registry =
      case view do
        %{children: children} ->
          Enum.reduce(children, registry, &calculate_block_height(&2, &1))

        _ ->
          registry
      end

    children_height =
      case view do
        %{children: children} ->
          Enum.reduce(children, 0, fn child_id, acc ->
            child = fetch_view!(registry, child_id)

            case {acc, child.content.height} do
              {_, :fill_parent} ->
                acc

              _ ->
                acc + View.margin_box_height(child)
            end
          end)

        %{content: %{height: :fill_parent}} ->
          0

        _ ->
          content.height
      end

    height =
      case content.height do
        :wrap_content ->
          children_height

        _ ->
          content.height
      end

    content =
      case {height, parent.content.height} do
        {:fill_parent, :wrap_content} ->
          %{content | height: 0}

        {:fill_parent, parent_height} ->
          %{content | height: parent_height}

        {height, _} ->
          %{content | height: min(parent.content.height, height)}
      end

    update_view(registry, %{view | content: content})
  end

  defp calculate_block_width(registry, view_id \\ 0) do
    %{
      padding: padding,
      margin: margin,
      content: content
    } = view = fetch_view!(registry, view_id)

    # The default is the view itself because the only posible reason for no
    # parent is to be the ViewPort
    parent = get_view(registry, view.parent, view)

    max_content_width =
      parent.content.width - (margin.left + margin.right + padding.left + padding.right)

    content =
      case parent.orientation do
        :vertical ->
          width =
            cond do
              content.width == :fill_parent -> max_content_width
              true -> content.width
            end

          %{content | width: min(width, max_content_width)}

        :horizontal ->
          {reserved_space, fillers_count} =
            parent.children
            |> Enum.map(&fetch_view!(registry, &1))
            |> Enum.reduce({0, 0}, fn
              %{content: %{width: :fill_parent}}, {a_sp, fc} ->
                {a_sp, fc + 1}

              v, {a_sp, fc} ->
                sp = View.margin_box_width(v)

                {a_sp + sp, fc}
            end)

          available_space = max_content_width - reserved_space

          case content do
            %{width: :fill_parent} ->
              %{content | width: available_space / fillers_count}

            _ ->
              %{content | width: min(content.width, max_content_width)}
          end
      end

    registry = update_view(registry, %{view | content: content})

    case view do
      %{children: children} ->
        Enum.reduce(children, registry, fn child_id, registry1 ->
          calculate_block_width(registry1, child_id)
        end)

      _ ->
        registry
    end
  end

  defp update_view(registry, %{id: view_id} = view) when is_integer(view_id),
    do: Map.put(registry, view_id, view)

  defp get_view(registry, view_id, default),
    do: Map.get(registry, view_id, default)

  defp fetch_view!(registry, view_id),
    do: Map.get(registry, view_id)
end
