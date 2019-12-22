try do
  [nClients, nRequests] = System.argv
  # IO.inspect(number_of_nodes)
  # IO.inspect(number_of_requests)

  nUsers = String.to_integer(nClients)
  nTweets = String.to_integer(nRequests)
  Twitter.Main.start(nUsers, nTweets)

rescue
  MatchError -> IO.puts("Please enter the project line in format 'mix run project3.exs numNodes numRequests'")
  ArgumentError -> IO.puts("Please ensure that the number of nodes and number of requests are integer values")
end
