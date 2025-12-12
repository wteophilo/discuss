defmodule DiscussWeb.TopicLive.Form do
  use DiscussWeb, :live_view

  alias Discuss.Topics
  alias Discuss.Topics.Topic

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage topic records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="topic-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Topic</.button>
          <.button navigate={return_path(@return_to, @topic)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    topic = Topics.get_topic!(id)

    socket
    |> assign(:page_title, "Edit Topic")
    |> assign(:topic, topic)
    |> assign(:form, to_form(Topics.change_topic(topic)))
  end

  defp apply_action(socket, :new, _params) do
    topic = %Topic{}

    socket
    |> assign(:page_title, "New Topic")
    |> assign(:topic, topic)
    |> assign(:form, to_form(Topics.change_topic(topic)))
  end

  @impl true
  def handle_event("validate", %{"topic" => topic_params}, socket) do
    changeset = Topics.change_topic(socket.assigns.topic, topic_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"topic" => topic_params}, socket) do
    save_topic(socket, socket.assigns.live_action, topic_params)
  end

  defp save_topic(socket, :edit, topic_params) do
    case Topics.update_topic(socket.assigns.topic, topic_params) do
      {:ok, topic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Topic updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, topic))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_topic(socket, :new, topic_params) do
    case Topics.create_topic(topic_params) do
      {:ok, topic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Topic created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, topic))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _topic), do: ~p"/topics"
  defp return_path("show", topic), do: ~p"/topics/#{topic}"
end
