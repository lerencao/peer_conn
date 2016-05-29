defmodule PeerConn.Transport do
  @callback start_link(term) :: {:ok, pid} | {:error, term}
end
