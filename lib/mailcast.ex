defmodule Mailcast do
  @moduledoc """
  Mailcast Elixir SDK.

  Send email with `Mailcast.Swoosh.Adapter`, verify webhooks with
  `Mailcast.Webhooks`, manage templates with `Mailcast.Templates`, and preview
  messages with `Mailcast.Emails`.

  ## Configuration

      config :mailcast,
        api_key: "prod_...",
        base_url: "https://api.mailcast.io",
        webhook_secret: "..."

  ## Templates

  Create and manage email templates via the Mailcast API (requires the optional
  [`Req`](https://hex.pm/packages/req) dependency):

      {:ok, %{"template_id" => template_id, "user_id" => user_id}} =
        Mailcast.Templates.create(%{
          name: "welcome",
          user_id: "welcome",
          mjml: "<mjml><mj-body><mj-section><mj-column><mj-text>Hello {{name}}</mj-text></mj-column></mj-section></mj-body></mjml>",
          from: "hello@example.com",
          subject: "Welcome {{name}}"
        })

      {:ok, %{"templates" => templates}} = Mailcast.Templates.list()
      {:ok, template} = Mailcast.Templates.get(template_id)
      {:ok, template} = Mailcast.Templates.get(user_id)
      {:ok, template} = Mailcast.Templates.update(user_id, %{subject: "Hi {{name}}"})
      {:ok, template} = Mailcast.Templates.promote(user_id)
      {:ok, nil} = Mailcast.Templates.delete(user_id)

  Use the returned `template_id` or `user_id` with
  `Mailcast.Swoosh.Helper.set_template_id/2` when sending. List Handlebars
  fields in `data` with `Mailcast.Swoosh.Helper.set_substitute/2` so they
  expand before the template runs. List markdown fields with
  `Mailcast.Swoosh.Helper.set_markdown/2` to parse those values as markdown.

  ## Preview

  Render a template or individual fields without sending:

      {:ok, %{"subject" => subject, "html" => html, "text" => text}} =
        Mailcast.Emails.preview(%{
          template_id: "welcome",
          data: %{"name" => "John"}
        })

      {:ok, %{"fields" => %{"message" => html}}} =
        Mailcast.Emails.preview_fields(%{
          data: %{"name" => "John", "message" => "Hi **{{name}}**"},
          substitute: ["message"],
          markdown: ["message"]
        })
  """
end
