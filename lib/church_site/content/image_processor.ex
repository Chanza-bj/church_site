defmodule ChurchSite.Content.ImageProcessor do
  @max_width 1920
  @max_height 1080
  @thumb_size 300
  @quality 85

  def process_image(source_path) do
    with {:ok, _info} <- ExImageInfo.info(source_path),
         {:ok, processed_path} <- optimize_image(source_path),
         {:ok, thumb_path} <- create_thumbnail(source_path) do
      {:ok, %{
        main_path: processed_path,
        thumb_path: thumb_path
      }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp optimize_image(source_path) do
    try do
      dest_path = generate_temp_path(source_path, "main")

      source_path
      |> Mogrify.open()
      |> Mogrify.resize_to_limit("#{@max_width}x#{@max_height}")
      |> Mogrify.quality(@quality)
      |> Mogrify.save(path: dest_path)

      {:ok, dest_path}
    rescue
      e -> {:error, "Failed to process image: #{inspect(e)}"}
    end
  end

  defp create_thumbnail(source_path) do
    try do
      thumb_path = generate_temp_path(source_path, "thumb")

      source_path
      |> Mogrify.open()
      |> Mogrify.resize_to_fill("#{@thumb_size}x#{@thumb_size}")
      |> Mogrify.quality(@quality)
      |> Mogrify.save(path: thumb_path)

      {:ok, thumb_path}
    rescue
      e -> {:error, "Failed to create thumbnail: #{inspect(e)}"}
    end
  end

  defp generate_temp_path(original_path, suffix) do
    extension = Path.extname(original_path)
    base = Path.basename(original_path, extension)
    temp_dir = System.tmp_dir!()
    Path.join(temp_dir, "#{base}_#{suffix}_#{:os.system_time(:millisecond)}#{extension}")
  end

  def cleanup_temp_files(paths) when is_list(paths) do
    Enum.each(paths, &cleanup_temp_file/1)
  end

  defp cleanup_temp_file(path) when is_binary(path) do
    if String.contains?(path, System.tmp_dir!()) do
      File.rm(path)
    end
  end
  defp cleanup_temp_file(_), do: :ok
end
