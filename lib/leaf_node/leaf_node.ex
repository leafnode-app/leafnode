defmodule LeafNode do
  @moduledoc """
    The LeafNode module provides functions for working with nodes in a process.
    The module contains constants for various keys that are used to access and manipulate node data.
    The module includes functions for generating and updating the test data associated with a node, and for generating a result log for a node's output.
    There are also functions for identifying whether a given node is an entry node, and for processing the result of an exit node.
    Finally, the module provides a function for initializing the input for the process's entry node.

    Overall, the LeafNode module provides a set of useful functions for managing and manipulating nodes in a process, and can be used to build complex workflows in Elixir.
  """
  alias LeafNode.Repo.Log

  # Constants
  @id "id"
  @name "name"
  @input "input"
  @exit_node "exit_node"
  @input_node "input_node"
  @result_output "result_output"

  @doc """
    Generates the return result that will be used as the struct for the data in processes
  """
  # TODO: This needs to change to a struct and be updated acordingly
  def generate_result_log(node, %{ "data" => data }) do
    node_result = %{
      "id" => node[@id],
      "name" => node[@name],
      "input" => node[@input],
      "result_output" => %{
        "data" => data
      }
    }

    result = if is_entry_node?(node) do
      Map.put(node_result, "exit_node", node[@exit_node])
    else
      node_result
    end

    result
  end

  @doc """
    Is the current node the entry node?
  """
  # TODO: This needs to be more unique to know if its an entry node
  def is_entry_node?(node) do
    Map.has_key?(node, @exit_node)
  end

  @doc """
    Take the result of the exit node that was setup and selected by the entry node to be returned
  """
  def process_exit_node(nodes) do
    entry_node = nodes[@input_node]
    result = entry_node[@exit_node]
    result_data = if nodes[result] !== nil, do: nodes[result], else: %{}
    Map.get(result_data, @result_output, %{
      "data" => %{
        "message" => "No exit node configured or found."
      }
    })
  end

  @doc """
    Takes the input sent to be executed on the process and passes it to an etry node that.
    The entry node is the entry point of the processes and decides on the result of the entire process.
    The entry-node can also be referenced and used across all nodes for its initial value
  """
  def init_entry_node_input(entry_node, input) do
    Map.put(entry_node, @input, input)
  end

  @doc """
    Geet the integration action that is being executed for a given integration type
  """
  def get_integration_type(action) do
    String.split(action, "_") |> Enum.at(0)
  end

  @doc """
    Take th node input and get the relevant dynamic value to use as part of the payload
    TODO - check if input data or not - this needs to be done better in future
    Check syntax in order to know if we do a normal string write to integration or dynamic from input
  """
  def parse_node_input(value, payload) when is_list(value) do
    # value - the entire string that is expected to be sent
    Enum.map(value, fn item ->
      get_potential_input_value(item, payload)
    end)
  end
  def parse_node_input(value, payload) when is_binary(value) do
    get_potential_input_value(value, payload)
  end
  def parse_node_input(_, _), do: raise("No Implementation to parse input to integration")

  # Get the potential input value for given payload
  defp get_potential_input_value(item, payload) do
    path = Enum.at(String.split(item, "::"), 1)
    if !is_nil(path) do
      Kernel.get_in(payload, String.split(path, "."))
    else
      item
    end
  end

  @doc """
    Create a log based on node and it allowing logs to be persisted for it
  """
  def log_result(node, input, result, status) do
    if node.should_log do
      Log.create_log(node.id, input, result, status)
    end
  end
end
