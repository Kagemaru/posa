defmodule PosaWeb.MetricsControllerTest do
  use PosaWeb.ConnCase

  import Posa.ExportsFixtures

  alias Posa.Exports.Metrics

  @create_attrs %{
    test: "some test"
  }
  @update_attrs %{
    test: "some updated test"
  }
  @invalid_attrs %{test: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all metrics", %{conn: conn} do
      conn = get(conn, Routes.metrics_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create metrics" do
    test "renders metrics when data is valid", %{conn: conn} do
      conn = post(conn, Routes.metrics_path(conn, :create), metrics: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.metrics_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "test" => "some test"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.metrics_path(conn, :create), metrics: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update metrics" do
    setup [:create_metrics]

    test "renders metrics when data is valid", %{conn: conn, metrics: %Metrics{id: id} = metrics} do
      conn = put(conn, Routes.metrics_path(conn, :update, metrics), metrics: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.metrics_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "test" => "some updated test"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, metrics: metrics} do
      conn = put(conn, Routes.metrics_path(conn, :update, metrics), metrics: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete metrics" do
    setup [:create_metrics]

    test "deletes chosen metrics", %{conn: conn, metrics: metrics} do
      conn = delete(conn, Routes.metrics_path(conn, :delete, metrics))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.metrics_path(conn, :show, metrics))
      end
    end
  end

  defp create_metrics(_) do
    metrics = metrics_fixture()
    %{metrics: metrics}
  end
end
