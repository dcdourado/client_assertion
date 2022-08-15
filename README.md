# ClientAssertion

Client assertions consists of an identification of the client signed with it's private key.

This assertion can be used to authenticate with PandA to get an access token and possibly a
refresh token aswell.

## Example usage

Attach to IEx
```shell
iex -S mix
```

Generate the client assertion
```mix.exs
private_key = File.read!("mykey.pem")
assertion = ClientAssertion.generate("8befb5e2-f02d-43d6-b8d0-0978cfa2edcc", "stone_bank", private_key)
```

Authenticate to get access and refresh tokens
```mix.exs
ClientAssertion.authenticate(assertion)
```
