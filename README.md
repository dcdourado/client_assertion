# ClientAssertion

Client assertions consists of an identification of the client signed with it's private key.

This assertion can be used to authenticate with PandA to get an access token and possibly a
refresh token aswell.

## Example usage

Atach do IEx
```shell
iex -S mix
```

Generate the client assertion
```mix.exs
private_key = File.read!("mykey.pem")
ClientAssertion.generate("f29eb56b-0e16-4017-aefb-483557e7c3ec", "stone_account", private_key)
```
