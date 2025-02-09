defmodule ChurchSiteWeb.Admin.UploadController do
  use ChurchSiteWeb, :controller

  alias ChurchSite.Content.Upload
  alias ChurchSite.Content.ImageProcessor
  alias ChurchSite.Repo

  def create(conn, %{"file" => file}) do
    case handle_upload(file) do
      {:ok, path} ->
        json(conn, %{path: path})
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  defp handle_upload(file) do
    extension = Path.extname(file.filename)
    file_uuid = Ecto.UUID.generate()
    file_name = "#{file_uuid}#{extension}"
    file_path = Path.join("uploads", file_name)

    case File.cp(file.path, Path.join("priv/static", file_path)) do
      :ok -> {:ok, file_path}
      {:error, reason} -> {:error, "Failed to save file: #{reason}"}
    end
  end

  def delete(conn, %{"id" => id}) do
    upload = Repo.get!(Upload, id)

    # Delete the file
    File.rm!("priv/static#{upload.path}")

    # Delete the record
    {:ok, _upload} = Repo.delete(upload)

    case get_format(conn) do
      "json" -> json(conn, %{success: true})
      _ ->
        conn
        |> put_flash(:info, "File deleted successfully.")
        |> redirect(to: ~p"/777/media")
    end
  end
end
