defmodule LeafNodeWeb.Web.Live.TestLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  import Phoenix.Component

  #import components
  alias LeafNodeWeb.Web.Live.Components.List

  def render(assigns) do
    IO.inspect(assigns)
    ~L"""
      This is some random values: <%= @test_val %>
      <button phx-click="new_num"> TEST </button>
      <hr />
      <.LeafNodeWeb.Web.Live.Components.List id="unique-id" name="Some name" />
      <hr />
      <button phx-click="route_redirect_home" class="bg-black text-white"> To home page</button>
      <hr />
    """
  end

  def mount(_params, _session, socket) do
    # we are just going to test the socket here
    random_num = random_num(10)
    socket_add_num = assign(socket, :rndm, random_num)
    socket_add_test_val = assign(socket_add_num, :test_val, "VALUE")
    {:ok, socket_add_test_val}
  end


  # handle events for live view here
  def handle_event("new_num", _value, socket) do
    #TODO: value is passed from the component
    {:noreply, assign(socket, :rndm, random_num(10))}
  end

  def handle_event("route_redirect_home", _v, socket) do
    socket = push_redirect(socket, to: "/")

    {:noreply, error_flash(socket)}
  end

  def info_flash(socket) do
    socket = put_flash(socket, :info, "SOME INFOMRMATION")
    socket
  end

  def error_flash(socket) do
    socket = put_flash(socket, :error, "ERROR! THis is some random error")
    socket
  end

  # helper functions
  def random_num(n) do
    :rand.uniform(n)
  end
end
