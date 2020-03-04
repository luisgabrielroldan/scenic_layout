defmodule ScenicLayoutTest do
  use ExUnit.Case

  alias ScenicLayout.Components.ViewPort

  defmodule Foo do
    use ScenicLayout

    view_port do
      linear_layout margin_left: 10, margin_right: 20 do
        box(color: :red, width: 64, height: 64)
        box()
      end
    end
  end

  test "" do
    registry = Foo.viewport()
    # IO.inspect(registry)
    # viewport = Map.get(registry, 0)
    #
    registry = ScenicLayout.Block.calculate_layout(registry)

    registry
    |> Map.fetch!(0)
    |> ViewPort.render(Scenic.Graph.build(), registry)
    |> IO.inspect()
  end
end
