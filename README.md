# ClientAssertion

Client assertions consists of an identification of the client signed with it's private key.

This assertion can be used to authenticate with PandA in Homolog or Sandbox to get an access token and possibly a
refresh token as well.

## Installation

1. Get and install [asdf](https://asdf-vm.com/guide/getting-started.html).
2. Clone and access the directory of this repository on terminal.
3. Install Elixir and Erlang with `asdf install`.
4. Install dependencies with `mix deps.get`.
5. Compile the project with `mix compile`.

## Example usage

Attach to IEx
```shell
iex -S mix
```

Generate the client assertion
```mix.exs
private_key = File.read!("mykey.pem")
assertion = ClientAssertion.generate("8befb5e2-f02d-43d6-b8d0-0978cfa2edcc", "stone_bank", private_key, "sandbox")
```

Authenticate to get access and refresh tokens
```mix.exs
ClientAssertion.authenticate(assertion, "sandbox")
```
