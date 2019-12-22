defmodule Proj4Test do
  use ExUnit.Case
  doctest Proj4

  # Initial setup for the test cases to work upon
  @tag testCase: 1
  test "tables created check" do
    IO.puts "###################################################"
    IO.puts "Check if the tables are created when the server is started"
    {:ok,pid} = Twitter.Server.start_link()
    assert :ets.whereis(:allUsers) != :undefined
    assert :ets.whereis(:tweetsMade) != :undefined
    assert :ets.whereis(:followers) != :undefined
    assert :ets.whereis(:following) != :undefined
    assert :ets.whereis(:mentionsHashtags) != :undefined
    IO.puts "Tables were created successfully"
    IO.puts "####################################################"
  end

  @tag testCase: 2
  test "user registration check" do
    IO.puts " "
    IO.puts "####################################################"
    IO.puts "Check weather users can be registered"
    {:ok,_} = Twitter.Server.start_link()
    :global.register_name(:main, self())
    IO.inspect "Register some users"
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    assert :ets.lookup(:allUsers, 1) != []     #check wheather the user was added to the table
    assert :ets.lookup(:allUsers, 2) != []     #check wheather the user was added to the table
    assert :ets.lookup(:allUsers, 3) != []     #check wheather the user was added to the table
    IO.puts "The users were successfully added to the tables"
    IO.puts "#####################################################"
    IO.puts " "
  end

  @tag testCase: 3
  test "duplicate user addition" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Check weather duplicate user can be registered"
    {:ok,_} = Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    IO.puts "Try adding the same user1 again"
    Twitter.Server.register_user(1,12,true) |> IO.puts
    [{_,clientPID,_}] = :ets.lookup(:allUsers, 1)
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 4
  test "deletion of an account" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Delete an account and verify whether it is removed from all the tables"
    {:ok,_} = Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.delete_user(1) |> IO.puts
    assert :ets.lookup(:allUsers, 1) == []  #check if the user was deleted from the allUsers table
    assert :ets.lookup(:following, 1) == [] #check if the user was deleted from the following table
    assert :ets.lookup(:followers, 1) == []  #check if the user was deleted from the followers table
    assert :ets.lookup(:tweetsMade, 1) == []  #check if the user was deleted from the tweetsMade table
    IO.puts "The user was removed from all the tables"
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 5
  test "deleting of an account not present in the system" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Try deleting an account not present"
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    IO.inspect "Register some users"
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    assert :ets.lookup(:allUsers, 1) != []
    assert :ets.lookup(:allUsers, 2) != []
    assert :ets.lookup(:allUsers, 3) != []
    IO.puts "Try deleting user 4 which is not present"
    Twitter.Server.delete_user(4) |> IO.puts
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 6
  test "Check if followers are getting adding to the follwers list" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "User follows another user check"
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    IO.puts "The followers list of user 1 before adding the followers:"
    IO.inspect Twitter.Server.get_followers(1)
    Twitter.Server.add_follower(2,1)
    Twitter.Server.add_follower(3,1)
    :timer.sleep(10) #since add followers function is a cast call, introduce a delay before checking th result
    IO.puts "The updated followers list of user1 is:"
    IO.inspect Twitter.Server.get_followers(1)
    :timer.sleep(20)
    IO.puts "#########################################################"
    IO.puts " "
  end
##check from here
  @tag testCase: 7
  test "sending tweets" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Test: User tweets a message and is displayed to his/her followers "
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    Twitter.Server.add_follower(2,1) #user 2 following user 1
    Twitter.Server.add_follower(3,1) #user 3 following user 1
    #all the users are currently active. So, they should recieve the tweet made by User 1
    :timer.sleep(10)
    tweet_string = "check tweet"
    Twitter.Client.tweet(1,tweet_string)
    :timer.sleep(10)
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 8
  test "sending tweets offline check" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "User tweets made by a user not displayed to logged of users"
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    Twitter.Server.add_follower(2,1) #user 2 following user 1
    Twitter.Server.add_follower(3,1) #user 3 following user 1
    Twitter.Server.logout_user(2) #logging out user 2
    :timer.sleep(10)
    tweet_string = "check tweet"
    Twitter.Client.tweet(1,tweet_string) #since user 2 is logged out,it would not recieve the tweet made by user 1
    :timer.sleep(10)
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 9
  test "check login and logout" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Check if a user can be logged in and logged out"
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts ##user would be logged in when registering
    Twitter.Server.login_user(1)
    {_,_,status,_} = Twitter.Client.get_state(1)
    assert status == true ##verify whether the status is true
    Twitter.Server.logout_user(1)
    {_,_,status,_} = Twitter.Client.get_state(1)
    assert status == false #verify whether the state of the client gets updated to false
    :timer.sleep(10)
    IO.puts "#########################################################"
    IO.puts " "
  end




  @tag testCase: 10
  test "retweet with hashtag querying" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Retweet functionality"
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts
    Twitter.Server.register_user(4,1,true)
    Twitter.Server.add_follower(2,1)
    Twitter.Server.add_follower(3,1)
    Twitter.Server.add_follower(4,2)
    :timer.sleep(10)
    tweet_string = "#COP5615 is great"
    Twitter.Client.tweet(1,tweet_string) #users 2 and 3 should have recieved the message
    :timer.sleep(30)
    # # user 2 querying the hashtag and retweeting to its followers
    Twitter.Main.queryByHashtag(1,"#COP5615")
    #the queries with the given hashtag should be printed out
    Twitter.Main.waitFor(:queryTweet, 1)
    #the retweet was recieved by the user4 since it folloes user 1 and is live
    :timer.sleep(20)
    IO.puts "#########################################################"
    IO.puts " "
  end

  @tag testCase: 11
  test "mentions displayed live" do
    IO.puts " "
    IO.puts "#########################################################"
    IO.puts "Mentions displayed live functionality"
    #Register some users
    Twitter.Server.start_link()
    :global.register_name(:main, self())
    Twitter.Server.register_user(1,1,true) |> IO.puts
    Twitter.Server.register_user(2,1,true) |> IO.puts
    Twitter.Server.register_user(3,1,true) |> IO.puts

    #user1 mentioning user 2 in his tweet
    tweet = "Hello there @User#{2}."
    Twitter.Client.tweet(1, tweet)
    #Since user 2 is online when registering, the mention should displayed live in his feed
    :timer.sleep(100)

  end



end
