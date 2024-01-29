# stream_remote_process_logs

A proof of concept on how to run a process remotely and have its logs
streamed through a websocket.

## Installation

1. Build this piece of shyte

```sh
$ git clone https://github.com/kwalter94/stream_remote_process_logs.git
$ cd stream_remote_process_logs
$ shards install
$ make
```

2. Install redis

## Usage

1. Start redis on http://localhost:6379

2. Start (websocket) server

```sh
./stream_remote_process_logs serve
```

3. Run a command

```sh
./stream_remote_process_logs exec -- journalctl -f # journalctl -f is the command we want to stream
```

4. Copy command id from process above and input it at http://localhost:8000 to start
receiving logs from the process. You can run a `sudo` command in another window to
force some logs to be appended to the journal.

## Limitations/Notes

- Redis pub/sub is fire and forget... So you will miss some (a lot) of messages
- Redis streams would be better for this but the underlying library used here does not
support them (yet)

## Contributing

1. Fork it (<https://github.com/kwalter94/stream_remote_process_logs/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Walter Kaunda](https://github.com/kwalter94) - creator and maintainer
