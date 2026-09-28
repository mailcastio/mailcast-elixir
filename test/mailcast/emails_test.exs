defmodule Mailcast.EmailsTest do
  use ExUnit.Case

  alias Mailcast.Emails

  @api_key "prod_test_key"

  setup do
    sham = Sham.start()
    opts = [api_key: @api_key, base_url: "http://localhost:#{sham.port}"]

    %{opts: opts, sham: sham}
  end

  test "preview/2 posts an email preview", %{opts: opts, sham: sham} do
    Sham.expect_once(sham, "POST", "/v1/emails/preview", fn conn ->
      conn = parse_json(conn)

      assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer #{@api_key}"]

      assert %{
               "template_id" => "welcome",
               "subject" => "Welcome {{name}}",
               "data" => %{"name" => "John"}
             } = conn.body_params

      json_resp(conn, 200, %{
        "subject" => "Welcome John",
        "html" => "Hello John",
        "text" => nil
      })
    end)

    assert {:ok, %{"subject" => "Welcome John", "html" => "Hello John", "text" => nil}} =
             Emails.preview(
               %{
                 template_id: "welcome",
                 subject: "Welcome {{name}}",
                 data: %{"name" => "John"}
               },
               opts
             )
  end

  test "preview/2 returns api errors", %{opts: opts, sham: sham} do
    Sham.expect_once(sham, "POST", "/v1/emails/preview", fn conn ->
      json_resp(conn, 422, %{"error" => "validation failed", "details" => %{"template_id" => "template not found"}})
    end)

    assert {:error, {422, %{"error" => "validation failed", "details" => %{"template_id" => "template not found"}}}} =
             Emails.preview(%{template_id: "missing"}, opts)
  end

  test "preview_fields/2 posts field paths", %{opts: opts, sham: sham} do
    Sham.expect_once(sham, "POST", "/v1/emails/fields/preview", fn conn ->
      conn = parse_json(conn)

      assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer #{@api_key}"]

      assert %{
               "data" => %{"name" => "John", "message" => "Hi **{{name}}**"},
               "substitute" => ["message"],
               "markdown" => ["message"]
             } = conn.body_params

      json_resp(conn, 200, %{"fields" => %{"message" => "<p>Hi <strong>John</strong></p>"}})
    end)

    assert {:ok, %{"fields" => %{"message" => "<p>Hi <strong>John</strong></p>"}}} =
             Emails.preview_fields(
               %{
                 data: %{"name" => "John", "message" => "Hi **{{name}}**"},
                 substitute: ["message"],
                 markdown: ["message"]
               },
               opts
             )
  end

  test "preview_fields/2 returns api errors", %{opts: opts, sham: sham} do
    Sham.expect_once(sham, "POST", "/v1/emails/fields/preview", fn conn ->
      json_resp(conn, 422, %{
        "error" => "validation failed",
        "details" => %{"substitute" => "message must be a string"}
      })
    end)

    assert {:error,
            {422, %{"error" => "validation failed", "details" => %{"substitute" => "message must be a string"}}}} =
             Emails.preview_fields(%{data: %{"message" => 123}, substitute: ["message"]}, opts)
  end

  defp parse_json(conn) do
    Plug.Parsers.call(
      conn,
      Plug.Parsers.init(parsers: [:json], json_decoder: Jason)
    )
  end

  defp json_resp(conn, status, body) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.resp(status, Jason.encode!(body))
  end
end
