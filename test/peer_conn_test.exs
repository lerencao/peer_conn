defmodule PeerConnTest do
  use ExUnit.Case
  doctest PeerConn

  defmodule RedisTransport do
    @behaviour PeerConn.Transport
    def start_link(conn_opts) do
      # host, port
      Redix.start_link(conn_opts)
    end
  end


  setup _context do
    {:ok, peer_conn} = PeerConn.start_link()
    on_exit(fn -> Supervisor.stop(peer_conn) end)
    {:ok, %{peer_conn: peer_conn}}
  end

  test "create_conn: create a conn under the peer conn supervisor",%{
    peer_conn: peer_conn
  } do
    {:ok, _c} = peer_conn |>
      PeerConn.create_conn(:localhost, RedisTransport, [[]])

    {:error, :already_created} = peer_conn |>
      PeerConn.create_conn(:localhost, RedisTransport, [[]])
  end
end
