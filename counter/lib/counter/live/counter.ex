defmodule CounterWeb.Counter do
  use CounterWeb, :live_view
  @topic "number" # topic, number can be any name

  def mount(_params, _session, socket) do
    CounterWeb.Endpoint.subscribe(@topic) # subscribe to the channel
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event(cmd, _, socket) do
    new_state =
      case cmd do
      "inc" -> update(socket, :val, &(&1 + 1))
      "dec" -> update(socket, :val, &(&1 - 1))
      # _ -> raise "Unknown command, only inc/dec allowed" # Not recommended, just let it crash
    end
    CounterWeb.Endpoint.broadcast_from(self(), @topic, "inc", new_state.assigns)
    {:noreply, new_state}
  end

  def handle_info(msg, socket) do
    {:noreply, assign(socket, val: msg.payload.val)}
  end

  def render(assigns) do
    ~H"""
    <div class="text-center">
      <h1 class="text-4xl font-bold text-center"> Counter: <%= @val %> </h1>
      <.button phx-click="dec" class="w-20 bg-red-500 hover:bg-red-600">-</.button>
      <.button phx-click="inc" class="w-20 bg-green-500 hover:bg-green-600">+</.button>
    </div>
    """
  end
end
