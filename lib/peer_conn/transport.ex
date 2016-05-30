defmodule PeerConn.Transport do
  @moduledoc """
  The module used in `PeerConn.create_conn` should implement
  this behaviour.
  """

  @doc """
  start a process which will supervised by the `PeerConn`.
  """
  @callback start_link(term) :: {:ok, pid} | {:error, term}
end
