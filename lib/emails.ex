defmodule Mailcast.Emails do
  @moduledoc """
  Preview emails and template fields without sending.

  Nothing is stored or queued. Open and click tracking are not applied.

  ## Configuration

  See `Mailcast.Client` for `:api_key` and `:base_url`.
  """

  alias Mailcast.Client

  @doc """
  Render an email without sending it.

  The body matches [Send Email](https://mailcast.io/docs/api/emails/create):
  pass `text` and/or `html`, or a `template_id` with `data`.

  When `template_id` is set, the compiled template is rendered with `data`,
  including `substitute` and `markdown`. Any `text` or `html` on the request is
  ignored. `subject` is rendered with the template language as plain text,
  using the template default when the request omits it. `from` and `to` are
  optional and are not returned.

  A raw `html` or `text` body is returned as given. `substitute` and `markdown`
  run only when a template is rendered. To preview a message field on its own,
  use `preview_fields/2`.

  ## Parameters

    * `:subject` - Subject line. When `template_id` is set, placeholders are filled from `data`
    * `:text` - Plain-text body. Ignored when `template_id` is set
    * `:html` - HTML body. Ignored when `template_id` is set
    * `:template_id` - A template TypeID or `user_id`
    * `:data` - Values substituted into the template
    * `:substitute` - Data keys to render as templates before the outer template runs
    * `:markdown` - Data keys to render as CommonMark after `substitute`

  ## Options

    * `:api_key` - Mailcast API key
    * `:base_url` - Mailcast API base URL

  ## Examples

      {:ok, %{"subject" => subject, "html" => html, "text" => text}} =
        Mailcast.Emails.preview(%{
          template_id: "welcome",
          subject: "Welcome {{name}}",
          data: %{"name" => "John"}
        })

  """
  def preview(params, opts \\ []) do
    Client.post("/v1/emails/preview", params, opts)
  end

  @doc """
  Render `substitute` and `markdown` fields without a template.

  Listed `substitute` paths are rendered with the template language against
  `data`, with no HTML escaping. Listed `markdown` paths are then rendered as
  CommonMark. A path in both lists is expanded first, then converted to HTML.
  Response keys are the path strings from the request. Missing paths are omitted.

  ## Parameters

    * `:data` - Values available to `substitute` and `markdown`
    * `:substitute` - Data keys to render as templates
    * `:markdown` - Data keys to render as CommonMark after `substitute`

  ## Options

    * `:api_key` - Mailcast API key
    * `:base_url` - Mailcast API base URL

  ## Examples

      {:ok, %{"fields" => %{"message" => html}}} =
        Mailcast.Emails.preview_fields(%{
          data: %{"name" => "John", "message" => "Hi **{{name}}**"},
          substitute: ["message"],
          markdown: ["message"]
        })

  """
  def preview_fields(params, opts \\ []) do
    Client.post("/v1/emails/fields/preview", params, opts)
  end
end
