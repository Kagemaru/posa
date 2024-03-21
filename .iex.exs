import_file_if_available("~/.iex.exs")
import_file_if_available(".iex.env.exs")

color = CustomIEx.color()
prefix = CustomIEx.env()
reset = IO.ANSI.reset()

IEx.configure(
  colors: [enabled: true],
  history_size: -1,
  default_prompt: "#{color}#{prefix}#{reset}_%prefix(%counter)>",
  alive_prompt: "#{color}#{prefix}#{reset}_%prefix(%node)%counter>"
)

alias Posa.Github.{API, Data, Metrics, Storage, Sync}
alias Posa.Github.Storage.{Etags, Events, Organizations, Users}
