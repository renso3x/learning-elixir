defmodule Identitycon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    #string interpolation
    File.write("#{input}.png", image)
  end

  def draw_image(%Identitycon.Image{color: color, pixel_image: pixel_image}) do
    # erlang code
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_image, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identitycon.Image{grid: grid} = image) do
    pixel_image = Enum.map grid, fn ({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identitycon.Image{image | pixel_image: pixel_image}
  end

  def filter_odd_squares(%Identitycon.Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({code, _index}) -> rem(code, 2) == 0 end)
    %Identitycon.Image{image | grid: grid}
  end

  def pick_color(image) do
    # pattern matching from the struct
    %Identitycon.Image{hex: hex_list} = image

    # pattern match from the list
    [red, green, blue | _tail] = hex_list

    %Identitycon.Image{image | color: {red, green, blue}}
  end

  def build_grid(%Identitycon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1) #passing a reference function
      |> List.flatten
      |> Enum.with_index

    %Identitycon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    # get only the 1st and 2nd element
    [first, second | _tail] = row
    # join from the existing listing
    row ++ [second, first]
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identitycon.Image{hex: hex}
  end
end
