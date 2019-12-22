# Project 4.1 - Twitter-Clone using elixir

## Members
Milind Jayan - 8168 9617
Sagar Jayanth Shetty - 43517929

## Implementation
`mix run proj4.exs numClients numTweets`

## What is working
- Twitter Engine 
- Twitter Client
- Users following users
- Users sending tweets
- Tweets displayed livev when the user is connected
- Querting tweets based on mentions and hashtags and subscribed to tweets
- Retweets

## Testing
Type in the following command for testing the whole test cases:
- mix test

To run individual test cases, runt he following commands
- mix test <test case tag>
For example, for running test case 1:
-mix test --only testCase:1

testCase:1  - Test if all the tables are getting intialised when starting the server
testCase:2  -  Test if the user registration functionality is working
testCase:3  - Test if a duplicate user can be added
testCase:4  - delete an account and check whether it is being removed from all the tables
testCase:5 - Test to check if an account not present in the system can be deleted
testCase:6 - check if the followers are getting added to the follwers list
testCase:7- sending tweets check
testCase:8 - sending tweets and verify wheather the offline users are recieveing live tweets
testCase:9 - check if users can be logged in and logged out
testCase:10 - retweet functionality by querying hashtags
taestCase:11 - is a user is mentioend in a tweet, it is displayed live to his feed if online