defmodule LeafNodeWeb.NoAccessControllerTest do
  use LeafNodeWeb.ConnCase

  test "GET route not found", %{conn: conn} do
    conn = get(conn, "/non_existent_path")
    response = %{
      "success" => false,
      "message" => "Unable to make a GET request to the given route",
      "data" => %{}
    }
    assert json_response(conn, 404) == response
  end

  test "POST route not found", %{conn: conn} do
    conn = post(conn, "/non_existent_path")
    response = %{
      "success" => false,
      "message" => "Unable to make a POST request to the given route",
      "data" => %{}
    }
    assert json_response(conn, 404) == response
  end
end
