defmodule ScenicLayout.Rect do
  defstruct x: nil, y: nil, width: nil, height: nil

  def zero() do
    %__MODULE__{
      x: 0,
      y: 0,
      width: 0,
      height: 0
    }
  end

  def fill_parent() do
    %__MODULE__{
      x: 0,
      y: 0,
      width: :fill_parent,
      height: :fill_parent
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%ScenicLayout.Rect{} = rect, opts) do
      dim =
        [:x, :y, :width, :height]
        |> Enum.map(&{&1, Map.get(rect, &1)})
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Enum.map(fn {k, v} ->
          [to_string(k), ": ", to_string(v)]
        end)
        |> Enum.join(", ")

      concat(["#Rect<", dim, ">"])
    end
  end
end
