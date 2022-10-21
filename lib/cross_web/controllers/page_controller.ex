defmodule CrossWeb.PageController do
  use CrossWeb, :controller

  alias Cross.ImgServer

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Vulnerable to XSS.SendResp
  def send_resp_html(conn, %{"i" => i}) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, "#{i}")
  end

  def html_resp(conn, %{"i" => i}) do
    html(conn, "<html><head>#{i}</head></html>")
  end

  def render_a(conn, %{"i" => i}) do
    render(conn, "render_a.html", i: i)
  end

  def render_b(conn, %{"i" => i}) do
    render(conn, "render_b.html", i: i)
  end

  def new_upload(conn, _params) do
    render(conn, "new_upload.html")
  end

  def upload(conn, %{"upload" => upload}) do
    %Plug.Upload{content_type: content_type, filename: filename, path: path} = upload
    ImgServer.put(filename, %{content_type: content_type, bin: File.read!(path)})
    redirect(conn, to: Routes.page_path(conn, :view_photo, filename))
  end

  def view_photo(conn, %{"filename" => filename}) do
    case ImgServer.get(filename) do
      %{content_type: content_type, bin: bin} ->
        conn
        |> put_resp_content_type(content_type)
        |> send_resp(200, bin)
      _ ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(404, "Not Found")
    end
  end

end
