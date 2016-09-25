
# Pedro

A very polite centralized notifications service

## What?

Pedro is an Elixir application that provides a notification service for any and many different notification types or channels. It handles the message reception, ensures its persistence, then manages to send to the requested target whenever the requested time arrives. Everything is handled so it respects given throttle levels for each defined notification mode.

The message itself can be any JSON. Time of Delivery can be any too. The actual ways to get to target can be several, chosen from many. Email, websocket broadcast, Telegram message, Slack channel, straight url visit... Please implement your favourite.

Passive notification is also supported. Some notifications are to be put into an inbox, or a dashboard, and must be left there until read, or even until explicit deletion. You can keep polling, or even use a websocket to get live notifications on an inbox, or a dashboard.

Notification requests are signed. Notification querying is too.

## Technologies

Pedro uses `Phoenix` to get web services, such as the notification reception and the inbox/dashboard reading.

`Cipher` to sign requests.

It uses `Mnesia` to persist data.

It uses `Bottler`/`Harakiri` for deploying tasks.

## TODOs

* Use https://github.com/klarna/mnesia_eleveldb

