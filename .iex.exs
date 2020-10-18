# import_file_if_available("~/.iex.exs")

# IO.puts(Mix.env())

# color =
#   if Mix.env() == "prod" do
#     IO.ANSI.red()
#   else
#     IO.ANSI.green()
#   end

# reset = IO.ANSI.reset()

# IEx.configure(
#   colors: [enabled: true],
#   history_size: -1,
#   default_prompt: "#{color}#{prefix}#{reset}_%prefix(%counter)>",
#   alive_prompt: "#{color}#{prefix}#{reset}_%prefix(%node)%counter>"
# )

alias Posa.Github.Storage
alias Posa.Github.Data
alias Posa.Github.API
