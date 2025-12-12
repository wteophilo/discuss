defmodule DiscussWeb.TopicLive.Index do
  use DiscussWeb, :live_view

  alias Discuss.Topics

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Topics
        <:actions>
          <.button variant="primary" navigate={~p"/topics/new"}>
            <.icon name="hero-plus" /> New Topic
          </.button>
        </:actions>
      </.header>

      <.table
        id="topics"
        rows={@streams.topics}
        row_click={fn {_id, topic} -> JS.navigate(~p"/topics/#{topic}") end}
      >
        <:col :let={{_id, topic}} label="Title">{topic.title}</:col>
        <:action :let={{_id, topic}}>
          <div class="sr-only">
            <.link navigate={~p"/topics/#{topic}"}>Show</.link>
          </div>
          <.link navigate={~p"/topics/#{topic}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, topic}}>
          <.link
            phx-click={JS.push("delete", value: %{id: topic.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Topics")
     |> stream(:topics, list_topics())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    topic = Topics.get_topic!(id)
    {:ok, _} = Topics.delete_topic(topic)

    {:noreply, stream_delete(socket, :topics, topic)}
  end

  defp list_topics() do
    Topics.list_topics()
  end
end
