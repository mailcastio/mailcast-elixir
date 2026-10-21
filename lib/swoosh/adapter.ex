if Code.ensure_loaded?(Swoosh) do
  defmodule Mailcast.Swoosh.Adapter do
    @moduledoc """
    Adapter module to configure Swoosh to send emails via Mailcast.

    To configure your Mailer, specify the adapter and a Mailcast API key:

    ```ex
    config :my_app, MyApp.Mailer,
      adapter: Mailcast.Swoosh.Adapter,
      api_key: "mailcast_prod_5nn4ohz3lg2yrz4tk5wdaqwvtxpylxrduresdbd2xkoqm"
    ```

    If you're configuring your app for production, configure your adapter in `prod.exs`, and
    your API key from the environment in `runtime.exs`:

    ```ex
    # prod.exs
    config :my_app, MyApp.Mailer, adapter: Mailcast.Swoosh.Adapter
    ```

    ```ex
    # runtime.exs
    config :my_app, MyApp.Mailer, api_key: "mailcast_prod_5nn4ohz3lg2yrz4tk5wdaqwvtxpylxrduresdbd2xkoqm"
    ```


    ## Provider Options

      * `:tags` ([%{"name" => string, "value" => string}, ...]) - tags to add to the email

      * `:data` (map) - data to be used in the template language

      * `:substitute` ([string]) - data keys to render as templates before the
        outer template runs. Use when a value such as `message` contains
        Handlebars. Unlisted values are inserted as-is.

      * `:markdown` ([string]) - data keys to parse as markdown. Use when a
        value such as `message` contains markdown that should be converted to
        HTML. Unlisted values are inserted as-is.

      * `:transactional` (boolean) - indicates if the email is transactional

      * `:template_id` (string) - template TypeID or `user_id` to use

      * `:idempotency_key` (string) - key to prevent duplicate emails from being sent
    """

    use Swoosh.Adapter, required_config: [:api_key]

    import Swoosh.Email.Render

    alias Mailcast.Swoosh.Helper

    @base_url "https://api.mailcast.io"
    @api_endpoint "/v1/emails"

    def deliver(%Swoosh.Email{} = email, config) do
      url = [base_url(config), @api_endpoint]

      headers = [
        {"authorization", "Bearer #{config[:api_key]}"},
        {"user-agent", "Mailcast.Swoosh.Adapter/#{Swoosh.version()}"},
        {"content-type", "application/json"}
      ]

      body =
        email
        |> build_email()
        |> add_provider_options(email)
        |> Swoosh.json_library().encode!()

      case Swoosh.ApiClient.post(url, headers, body, email) do
        {:ok, 200, _headers, body} ->
          {:ok, parse_response(body)}

        {:ok, code, _headers, body} when code >= 400 and code <= 599 ->
          {:error, {code, body}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    def deliver_many(emails, config) do
      url = [base_url(config), @api_endpoint]

      headers = [
        {"authorization", "Bearer #{config[:api_key]}"},
        {"user-agent", "Mailcast.Swoosh.Adapter/#{Swoosh.version()}"},
        {"content-type", "application/json"}
      ]

      body =
        %{
          batch:
            emails
            |> Enum.map(fn email ->
              email
              |> build_email()
              |> add_provider_options(email)
            end)
        }
        |> Swoosh.json_library().encode!()

      case Swoosh.ApiClient.post(url, headers, body, %Swoosh.Email{}) do
        {:ok, 200, _headers, body} ->
          {:ok, parse_response(body)}

        {:ok, code, _headers, body} when code >= 400 and code <= 599 ->
          {:error, {code, body}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    defp base_url(config) do
      config[:base_url] || @base_url
    end

    defp parse_response(""), do: %{}

    defp parse_response(body) when is_binary(body), do: body |> Swoosh.json_library().decode! |> parse_response()

    defp parse_response(%{"batch" => batch}) do
      batch
      |> Enum.map(fn
        %{"email_id" => email_id} ->
          %{email_id: email_id}

        %{"error" => error} ->
          {:error, error}
      end)
    end

    defp parse_response(%{"email_id" => email_id}) do
      %{email_id: email_id}
    end

    defp parse_response(%{"error" => _} = body) do
      body
    end

    defp build_email(email) do
      %{
        subject: email.subject,
        from: render_recipient(email.from),
        to: render_recipients(email.to),
        bcc: render_recipients(email.bcc),
        cc: render_recipients(email.cc),
        reply_to: render_recipients(email.reply_to),
        headers: email.headers,
        html: email.html_body,
        text: email.text_body,
        attachments: format_attachments(email.attachments)
      }
    end

    defp add_provider_options(map, email) do
      map
      |> add_tags(email)
      |> add_data(email)
      |> add_substitute(email)
      |> add_markdown(email)
      |> set_transactional(email)
      |> add_template_id(email)
      |> add_idempotency_key(email)
      |> set_open_tracking(email)
      |> set_click_tracking(email)
    end

    defp add_tags(map, %{provider_options: %{tags: tags}}) when not is_nil(tags) do
      tags = Helper.validate_tags(tags)

      Map.put(map, :tags, tags)
    end

    defp add_tags(map, _email), do: map

    defp add_data(map, %{provider_options: %{data: data}}) when not is_nil(data) do
      Map.put(map, :data, data)
    end

    defp add_data(map, _email), do: map

    defp add_substitute(map, %{provider_options: %{substitute: substitute}}) when is_list(substitute) do
      Map.put(map, :substitute, substitute)
    end

    defp add_substitute(map, _email), do: map

    defp add_markdown(map, %{provider_options: %{markdown: markdown}}) when is_list(markdown) do
      Map.put(map, :markdown, markdown)
    end

    defp add_markdown(map, _email), do: map

    defp set_transactional(map, %{provider_options: %{transactional: transactional}}) when not is_nil(transactional) do
      Map.put(map, :transactional, transactional)
    end

    defp set_transactional(map, _email), do: map

    defp add_template_id(map, %{provider_options: %{template_id: template_id}}) when not is_nil(template_id) do
      Map.put(map, :template_id, template_id)
    end

    defp add_template_id(map, _email), do: map

    defp add_idempotency_key(map, %{provider_options: %{idempotency_key: key}}) when is_binary(key) do
      Map.put(map, :idempotency_key, key)
    end

    defp add_idempotency_key(map, _email), do: map

    defp render_recipients(nil), do: nil

    defp render_recipients([recipient]), do: render_recipient(recipient)

    defp render_recipients(recipients) when is_list(recipients), do: Enum.map(recipients, &render_recipient/1)

    defp render_recipients(recipient), do: render_recipient(recipient)

    defp format_attachments(nil), do: nil
    defp format_attachments(attachments), do: Enum.map(attachments, &format_attachment/1)

    defp format_attachment(%Swoosh.Attachment{} = attachment) do
      %{
        content: Swoosh.Attachment.get_content(attachment, :base64),
        content_type: attachment.content_type,
        filename: attachment.filename,
        type: attachment.type
      }
      |> maybe_put_attachment_cid(attachment)
    end

    defp maybe_put_attachment_cid(map, %{cid: cid}) when is_binary(cid) and cid != "" do
      Map.put(map, :cid, cid)
    end

    defp maybe_put_attachment_cid(map, _attachment), do: map

    defp set_open_tracking(map, %{provider_options: %{open_tracking: true}}) do
      Map.put(map, :open_tracking, true)
    end

    defp set_open_tracking(map, _email), do: map

    defp set_click_tracking(map, %{provider_options: %{click_tracking: true}}) do
      Map.put(map, :click_tracking, true)
    end

    defp set_click_tracking(map, _email), do: map
  end
end
