
# Pedro

A very polite centralized notifications service

# What?

Pedro is an Elixir application that provides a notification service for any and many different notification types or channels. It handles the message reception, ensures its persistence, then manages to send to the requested target whenever the requested time arrives. 

The message itself can be any JSON. Time of Delivery can be any too. The actual ways to get to target can be several, chosen from many. Email, websocket broadcast, Telegram message, Slack channel, straight url visit... Please implement your favourite.

Passive notification is there too. Some notifications are to be put into an inbox, and must be left there until read, or even until explicit deletion. That is supported too.

Notification requests are signed. Notification querying is too.
