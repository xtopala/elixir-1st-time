defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_img
    |> save_img(input)
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _rest]} = img) do
    %Identicon.Image{img | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = img) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{img | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _rest] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = img) do
    grid =
      Enum.filter(grid, fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{img | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = img) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{img | pixel_map: pixel_map}
  end

  def draw_img(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    img = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(img, start, stop, fill)
    end)

    :egd.render(img)
  end

  def save_img(img, filename) do
    File.write("#{filename}.png", img)
  end
end
