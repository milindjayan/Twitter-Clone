defmodule Twitter.Client do
  use GenServer

  def delete_account(userId) do
    Twitter.Server.delete_user(userId)
  end

  def queryMentions(userId) do
    key = "User"<>Integer.to_string(userId)
    GenServer.cast(String.to_atom("User"<>Integer.to_string(userId)), {:queryTweet, "@"<>key})
  end


  def get_state(userId) do
    GenServer.call(String.to_atom("User"<>Integer.to_string(userId)),{:getState})
  end

  def tweet(userId,tweet) do
      GenServer.cast(String.to_atom("User"<>Integer.to_string(userId)), {:sendTweet, tweet})
  end


  def handle_call({:getState},_from,state) do
    {:reply,state,state}
  end

  def handle_cast({:querySubscribed,firstN},state) do
    {_userId, _nTweets, _isOnline, myTweets} = state
    tweetList = Enum.take(myTweets,firstN)
    send(:global.whereis_name(:main), {:querySubsResp})
    {:noreply, state}
  end

  def handle_cast({:queryTweet,key},state) do
    {userId, nTweets, isOnline, myTweets} = state
    GenServer.cast(:twitterServer,{:fetchAllMentionsAndHashtags,key,userId})
    receive do
      {:queryResult, list} -> Enum.each(list,fn tweet -> IO.inspect tweet end)
      {_,[]} ->[]
    end
    {:noreply, state}
  end

  def handle_cast({:tweetLive,tweet},state) do
    {userId, nTweets, isOnline, myTweets} = state
    if isOnline == true do
      IO.puts "#{tweet}"
    end
    {:noreply, {userId, nTweets, false, [tweet|myTweets]}}
  end

  def handle_cast({:logout,userId},state) do
    {userId, nTweets, isOnline, myTweets} = state
    IO.puts "User logged out: User#{userId}"
    {:noreply, {userId, nTweets, false, myTweets}}
  end

  def handle_cast({:login,userId},state) do
    {userId, nTweets, isOnline, myTweets} = state
    IO.puts "User logged in: User#{userId}"
    {:noreply, {userId, nTweets, true, myTweets}}
  end

  def handle_cast({:subscribe, toFollowId},state) do
    {userId, nTweets, isOnline, myTweets} = state
    if toFollowId != userId do
      GenServer.cast(:twitterServer,{:addFollower,userId,toFollowId})
      IO.puts "User#{userId} followed User#{toFollowId}."
    else
    end
    {:noreply, {userId, nTweets, true, myTweets}}
  end

  def handle_cast({:retweetSim,firstN},state) do
    {userId, nTweets, isOnline, myTweets} = state
    tweetList = Enum.take(myTweets,firstN)
    Enum.each(tweetList,fn(tweet) -> GenServer.cast(self(),{:sendRetweet, tweet}) end)
    {:noreply, {userId, nTweets, isOnline, myTweets}}
  end

  def handle_cast({:sendRetweet,tweet},state) do
    {userId, nTweets, isOnline, myTweets} = state
    GenServer.cast(:twitterServer,{:tweet,userId,tweet<>"-RT'd by User#{userId}"})
    IO.puts "User#{userId} retweeted \"#{tweet}-RT'd by User#{userId}\""
    {:noreply, {userId, nTweets, isOnline, myTweets}}
  end

  def handle_cast({:sendTweet,tweet},state) do
    {userId, nTweets, isOnline, myTweets} = state
    if isOnline == true do
      GenServer.cast(:twitterServer,{:tweet,userId,tweet<>"-by User#{userId}"})
    end
    IO.puts "User#{userId} tweeted \"#{tweet}-by User#{userId}\""
    {:noreply, {userId, nTweets, isOnline, myTweets}}
  end

  def start_link(userId,nTweets,isOnline) do
    {:ok,pid} = GenServer.start_link(__MODULE__, {userId,nTweets,isOnline},[name: String.to_atom("User"<>Integer.to_string(userId))])
    {:ok,pid}
  end

  def init({userId,_nTweets,isOnline}) do
    myTweets = []
    {:ok,{userId, [], isOnline, myTweets}}
  end
end
