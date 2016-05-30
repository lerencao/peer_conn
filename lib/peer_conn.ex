defmodule PeerConn do
  @moduledoc """
  A Supervisor which supervise connections to multi peers.
  One can start http clients connecting to mulit api domains, and use it by name as needed.
  """

  use Supervisor

  @doc """
  Start a peer conn supervisor with registered name `name`
  (unless it is nil, which is the default value).
  """
  def start_link(name \\ nil) do
    opts = if is_nil(name) do
      []
    else
      [name: name]
    end
    Supervisor.start_link(__MODULE__, {}, opts)
  end

  def init({}) do
    children = [
    ]

    options = [
      strategy: :one_for_one,
      max_restarts: 3,
      max_seconds: 5
    ]

    supervise(children, options)
  end



  @doc """
  Create a conn of name `name` using module `transport` with args `conn_args`.
  The `name` should be unique under the supervisor.
  `transport` should implement `PeerConn.Transport` behaviour.
  """
  def create_conn(conn_sup, name, transport, conn_args) do
    conn_sup
    |> Supervisor.start_child(worker_spec(name, transport, conn_args))
    |> start_result()
  end

  @doc """
  Get the conn by `name`, return `{:error, :not_found}`
  if the conn is not created.
  """
  @spec get_conn(Supervisor.supervisor, atom) :: {:ok, pid} | {:error, :not_found}
  def get_conn(conn_sup, name) do
    conn = conn_sup
    |> Supervisor.which_children()
    |> List.keyfind(name, 0)
    if is_nil(conn) do
      {:error, :not_found}
    else
      {:ok, conn}
    end
  end

  @doc """
  Close the conn of `name`, return `{:error, :not_found}` if not present.
  """
  @spec get_conn(Supervisor.supervisor, atom) :: :ok | {:error, :not_found}
  def close_conn(conn_sup, name) do
    case conn_sup |> Supervisor.terminate_child(name) do
      :ok ->
        :ok = conn_sup |> Supervisor.delete_child(name)
        :ok
      {:error, :not_found} = err ->
        err
    end
  end

  defp worker_spec(name, transport, conn_args) do
    worker(transport, conn_args, id: name)
  end

  defp start_result(on_start_child) do
    case on_start_child do
      {:ok, _child} = r ->
        r
      {:ok, child, _info} ->
        {:ok, child}
      {:error, {:already_started, _child}} ->
        {:error, :already_created}
      {:error, :already_present} ->
        {:error, :already_created}
      {:error, _term} = err->
        err
    end
  end
end
