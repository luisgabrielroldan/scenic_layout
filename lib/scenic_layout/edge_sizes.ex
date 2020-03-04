defmodule ScenicLayout.EdgeSizes do
  defstruct left: nil, right: nil, top: nil, bottom: nil

  def zero() do
    %__MODULE__{
      left: 0,
      top: 0,
      right: 0,
      bottom: 0
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%ScenicLayout.EdgeSizes{} = es, _opts) do
      dim =
        [:left, :top, :right, :bottom]
        |> Enum.map(&{&1, Map.get(es, &1)})
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Enum.map(fn {k, v} ->
          [to_string(k), ": ", to_string(v)]
        end)
        |> Enum.join(", ")

      concat(["#EdgeSizes<", dim, ">"])
    end
  end
end
