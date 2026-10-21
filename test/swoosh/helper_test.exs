defmodule Mailcast.Swoosh.HelperTest do
  use ExUnit.Case

  alias Mailcast.Swoosh.Helper

  describe "set_transactional/2" do
    test "sets transactional flag" do
      email = Swoosh.Email.new()
      email = Helper.set_transactional(email)
      assert email.provider_options[:transactional] == true
    end
  end

  describe "enable_click_tracking/1 and disable_click_tracking/1" do
    test "enables click tracking" do
      email = Swoosh.Email.new()
      email = Helper.enable_click_tracking(email)
      assert email.provider_options[:click_tracking] == true
    end

    test "disables click tracking" do
      email = Swoosh.Email.new() |> Helper.enable_click_tracking()
      email = Helper.disable_click_tracking(email)
      assert email.provider_options[:click_tracking] == false
    end
  end

  describe "enable_open_tracking/1 and disable_open_tracking/1" do
    test "enables open tracking" do
      email = Swoosh.Email.new()
      email = Helper.enable_open_tracking(email)
      assert email.provider_options[:open_tracking] == true
    end

    test "disables open tracking" do
      email = Swoosh.Email.new() |> Helper.enable_open_tracking()
      email = Helper.disable_open_tracking(email)
      assert email.provider_options[:open_tracking] == false
    end
  end

  describe "set_template_id/2" do
    test "sets template id" do
      email = Swoosh.Email.new()
      email = Helper.set_template_id(email, "template_123")
      assert email.provider_options[:template_id] == "template_123"
    end
  end

  describe "set_idempotency_key/2" do
    test "sets the idempotency key" do
      email = Swoosh.Email.new()
      email = Helper.set_idempotency_key(email, "unique-idempotency-key")
      assert email.provider_options[:idempotency_key] == "unique-idempotency-key"
    end
  end

  describe "set_data/2 and put_data/3" do
    test "sets data" do
      email = Swoosh.Email.new()
      data = %{"first_name" => "John"}
      email = Helper.set_data(email, data)
      assert email.provider_options[:data] == data
    end

    test "puts data key/value" do
      email = Swoosh.Email.new()
      email = Helper.put_data(email, "first_name", "John")
      assert email.provider_options[:data] == %{"first_name" => "John"}
    end

    test "put_data merges with existing data" do
      email = Swoosh.Email.new() |> Helper.set_data(%{"first_name" => "John"})
      email = Helper.put_data(email, "last_name", "Doe")
      assert email.provider_options[:data] == %{"first_name" => "John", "last_name" => "Doe"}
    end
  end

  describe "set_substitute/2" do
    test "sets substitute fields" do
      email = Swoosh.Email.new()
      email = Helper.set_substitute(email, ["message"])
      assert email.provider_options[:substitute] == ["message"]
    end
  end

  describe "set_markdown/2" do
    test "sets markdown fields" do
      email = Swoosh.Email.new()
      email = Helper.set_markdown(email, ["message"])
      assert email.provider_options[:markdown] == ["message"]
    end
  end

  describe "add_tag/3 and set_tags/2" do
    test "adds a tag" do
      email = Swoosh.Email.new()
      email = Helper.add_tag(email, "tag1", "value1")
      assert email.provider_options[:tags] == [%{name: "tag1", value: "value1"}]
    end

    test "adds multiple tags" do
      email = Swoosh.Email.new()
      email = Helper.add_tag(email, "tag1", "value1")
      email = Helper.add_tag(email, "tag2", "value2")
      assert email.provider_options[:tags] == [%{name: "tag2", value: "value2"}, %{name: "tag1", value: "value1"}]
    end

    test "sets tags (map and string keys)" do
      email = Swoosh.Email.new()
      tags = [%{name: "tag1", value: "value1"}, %{"name" => "tag2", "value" => "value2"}]
      email = Helper.set_tags(email, tags)

      assert email.provider_options[:tags] == [
               %{"name" => "tag1", "value" => "value1"},
               %{"name" => "tag2", "value" => "value2"}
             ]
    end

    test "set_tags raises on invalid tag" do
      email = Swoosh.Email.new()

      assert_raise ArgumentError, fn ->
        Helper.set_tags(email, [%{foo: "bar"}])
      end
    end
  end
end
