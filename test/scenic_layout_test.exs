defmodule ScenicLayoutTest do
  use ExUnit.Case

  alias ScenicLayout.Components.ViewPort

  defmodule Foo do
    use ScenicLayout

    view_port margin: 10 do
      linear_layout orientation: :horizontal do
        linear_layout height: :fill_parent, orientation: :vertical do
          # box(color: :red, height: 32, margin_right: 10)
          box(color: :red, height: :fill_parent, width: :fill_parent)
          box(color: :cyan, height: :fill_parent, width: :fill_parent)
        end

        # linear_layout height: :fill_parent, orientation: :horizontal do
        # box(color: :red, height: 32, margin_right: 10)
        # box(color: :lime, height: :fill_parent, width: :fill_parent)
        # end
      end
    end
  end

  test "" do
    registry = Foo.viewport(%{size: {640, 480}})

    registry =
      ScenicLayout.Block.calculate_layout(registry)
      |> IO.inspect()

    #
    # registry
    # |> Map.fetch!(0)
    # |> ViewPort.render(Scenic.Graph.build(), registry)
  end
end
