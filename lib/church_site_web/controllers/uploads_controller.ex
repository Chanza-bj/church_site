defmodule ChurchSiteWeb.UploadsController do
  use ChurchSiteWeb, :controller

  def show(conn, %{"path" => path}) do
    file_path = Path.join("priv/static/uploads", Path.join(path))

    if File.exists?(file_path) do
      send_file(conn, 200, file_path)
    else
      send_resp(conn, 404, "File not found")
    end
  end
end
