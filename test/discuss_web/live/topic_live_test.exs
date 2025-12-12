defmodule DiscussWeb.TopicLiveTest do
  use DiscussWeb.ConnCase

  import Phoenix.LiveViewTest
  import Discuss.TopicsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}
  defp create_topic(_) do
    topic = topic_fixture()

    %{topic: topic}
  end

  describe "Index" do
    setup [:create_topic]

    test "lists all topics", %{conn: conn, topic: topic} do
      {:ok, _index_live, html} = live(conn, ~p"/topics")

      assert html =~ "Listing Topics"
      assert html =~ topic.title
    end

    test "saves new topic", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Topic")
               |> render_click()
               |> follow_redirect(conn, ~p"/topics/new")

      assert render(form_live) =~ "New Topic"

      assert form_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#topic-form", topic: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/topics")

      html = render(index_live)
      assert html =~ "Topic created successfully"
      assert html =~ "some title"
    end

    test "updates topic in listing", %{conn: conn, topic: topic} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#topics-#{topic.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/topics/#{topic}/edit")

      assert render(form_live) =~ "Edit Topic"

      assert form_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#topic-form", topic: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/topics")

      html = render(index_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes topic in listing", %{conn: conn, topic: topic} do
      {:ok, index_live, _html} = live(conn, ~p"/topics")

      assert index_live |> element("#topics-#{topic.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#topics-#{topic.id}")
    end
  end

  describe "Show" do
    setup [:create_topic]

    test "displays topic", %{conn: conn, topic: topic} do
      {:ok, _show_live, html} = live(conn, ~p"/topics/#{topic}")

      assert html =~ "Show Topic"
      assert html =~ topic.title
    end

    test "updates topic and returns to show", %{conn: conn, topic: topic} do
      {:ok, show_live, _html} = live(conn, ~p"/topics/#{topic}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/topics/#{topic}/edit?return_to=show")

      assert render(form_live) =~ "Edit Topic"

      assert form_live
             |> form("#topic-form", topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#topic-form", topic: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/topics/#{topic}")

      html = render(show_live)
      assert html =~ "Topic updated successfully"
      assert html =~ "some updated title"
    end
  end
end
