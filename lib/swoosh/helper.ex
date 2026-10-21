defmodule Mailcast.Swoosh.Helper do
  @moduledoc """
  Helper functions for Swoosh emails using the Mailcast adapter.
  """

  @doc """
  Set the transactional flag for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_transactional()
  ```
  """
  def set_transactional(email) do
    email
    |> Swoosh.Email.put_provider_option(:transactional, true)
  end

  @doc """
  Enable click tracking for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.enable_click_tracking()
  ```
  """
  def enable_click_tracking(email) do
    email
    |> Swoosh.Email.put_provider_option(:click_tracking, true)
  end

  @doc """
  Enable open tracking for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.enable_open_tracking()
  ```
  """
  def enable_open_tracking(email) do
    email
    |> Swoosh.Email.put_provider_option(:open_tracking, true)
  end

  @doc """
  Disable click tracking for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.disable_click_tracking()
  ```
  """
  def disable_click_tracking(email) do
    email
    |> Swoosh.Email.put_provider_option(:click_tracking, false)
  end

  @doc """
  Disable open tracking for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.disable_open_tracking()
  ```
  """
  def disable_open_tracking(email) do
    email
    |> Swoosh.Email.put_provider_option(:open_tracking, false)
  end

  @doc """
  Set the template ID for the email.

  `template_id` may be a template TypeID or the template `user_id`.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_template_id("template_01jzqtmznaexgb9d3rpectx870")

  email
  |> Mailcast.Swoosh.Helper.set_template_id("welcome")
  ```
  """
  def set_template_id(email, template_id) do
    email
    |> Swoosh.Email.put_provider_option(:template_id, template_id)
  end

  @doc """
  Set the idempotency key for the email.

  `idempotency_key` is used to prevent duplicate emails from being sent.
  Mailcast will return the original email when the same key is sent again.
  The idempotency key must be unique per domain.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_idempotency_key("record-paystack-1")
  ```
  """
  def set_idempotency_key(email, key) when is_binary(key) do
    email
    |> Swoosh.Email.put_provider_option(:idempotency_key, key)
  end

  @doc """
  Set the data for the email.
  Data is used for variable substitution in the template language.

  This will replace the existing data.

  When a value itself contains Handlebars (for example a `message` field with
  `{{name}}` or `{{#if}}`), list that key with `set_substitute/2` so it is
  expanded before the outer template runs. List markdown fields with
  `set_markdown/2` to parse those values as markdown.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_data(%{"first_name" => "John", "last_name" => "Doe"})
  ```
  """
  def set_data(email, data) do
    email
    |> Swoosh.Email.put_provider_option(:data, data)
  end

  @doc """
  Set data keys to expand as templates before the outer template runs.

  Use this when a value such as `message` contains `{{name}}`, `{{#if}}`, or
  `{{#each}}`. Unlisted values are inserted as-is. Listed fields are Handlebars
  only, not MJML.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_template_id("welcome")
  |> Mailcast.Swoosh.Helper.set_data(%{
    "name" => "Andrew",
    "message" => "Hi {{name}}{{#if promo}}\\n{{promo}}{{/if}}"
  })
  |> Mailcast.Swoosh.Helper.set_substitute(["message"])
  ```
  """
  def set_substitute(email, fields) when is_list(fields) do
    email
    |> Swoosh.Email.put_provider_option(:substitute, fields)
  end

  @doc """
  Set data keys to parse as markdown.

  Use this when a value such as `message` contains markdown that should be
  converted to HTML before the template is inserted. Unlisted values are
  inserted as-is.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_template_id("welcome")
  |> Mailcast.Swoosh.Helper.set_data(%{
    "name" => "Andrew",
    "message" => "Hi **{{name}}**{{#if promo}}\\n{{promo}}{{/if}}"
  })
  |> Mailcast.Swoosh.Helper.set_substitute(["message"])
  |> Mailcast.Swoosh.Helper.set_markdown(["message"])
  ```
  """
  def set_markdown(email, fields) when is_list(fields) do
    email
    |> Swoosh.Email.put_provider_option(:markdown, fields)
  end

  @doc """
  Add to the data for the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.put_data("first_name", "John")
  ```
  """
  def put_data(email, key, value) do
    email
    |> Swoosh.Email.put_provider_option(:data, Map.put(email.provider_options[:data] || %{}, key, value))
  end

  @doc """
  Add a tag to the email.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.add_tag("tag1", "value1")
  ```
  """
  def add_tag(email, name, value) do
    email
    |> Swoosh.Email.put_provider_option(:tags, [%{name: name, value: value} | email.provider_options[:tags] || []])
  end

  @doc """
  Set the tags for the email.

  This will replace the existing tags.

  ## Examples

  ```elixir
  email
  |> Mailcast.Swoosh.Helper.set_tags([%{name: "tag1", value: "value1"}])
  ```
  """
  def set_tags(email, tags) do
    tags = validate_tags(tags)

    email
    |> Swoosh.Email.put_provider_option(:tags, tags)
  end

  def validate_tags(tags) do
    Enum.map(tags, fn
      %{"name" => name, "value" => value} ->
        %{"name" => name, "value" => value}

      %{name: name, value: value} ->
        %{"name" => name, "value" => value}

      other ->
        raise ArgumentError,
              "Invalid tag format in tags: #{inspect(other)}. Each tag must be a map with string keys \"name\" and \"value\"."
    end)
  end
end
