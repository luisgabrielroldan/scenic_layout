defmodule ScenicLayout do
  @moduledoc """
  Scenic Layout
  """

  alias ScenicLayout.Components.{
    Box,
    LinearLayout,
    ViewPort
  }

  defmacro __using__(_opts \\ []) do
    quote do
      use Scenic.Scene

      import ViewPort, only: :macros
      import LinearLayout, only: :macros
      import Box, only: :macros

      def init(_, opts) do
        {:ok, %Scenic.ViewPort.Status{} = viewport_status} = Scenic.ViewPort.info(opts[:viewport])

        registry =
          viewport(viewport_status)
          |> IO.inspect
          |> ScenicLayout.Block.calculate_layout()

        graph =
          registry
          |> Map.fetch!(0)
          |> ViewPort.render(Scenic.Graph.build(), registry)

        {:ok, graph, push: graph}
      end
    end
  end
end
