defmodule ClientAssertion do
  @moduledoc """
  Client assertions consists of an identification of the client signed with it's private key.

  This assertion can be used to authenticate with PandA to get an access token and possibly a
  refresh token aswell.
  """

  @typedoc "Assertion used on OAuth2 flows"
  @type assertion :: String.t()

  @typep uuid :: String.t()
  @typep pem :: String.t()

  @accounts_url Application.compile_env!(:client_assertion, :accounts_url)

  @doc "Uses `generate/3` with \"stone_bank\" audience"
  @spec generate(client_id :: uuid(), private_key :: pem()) :: assertion()
  def generate(client_id, private_key), do: generate(client_id, "stone_bank", private_key)

  @doc "Generates a JWT with required claims and signs it using given private key"
  @spec generate(client_id :: uuid(), realm :: String.t(), private_key :: pem()) :: assertion()
  def generate(client_id, realm, private_key) do
    ClientAssertion.Token.generate_and_sign!(
      %{
        "iss" => client_id,
        "sub" => client_id,
        "clientId" => client_id,
        "realm" => realm,
        "aud" => aud(realm)
      },
      signer(private_key)
    )
  end

  defp aud(realm), do: @accounts_url <> "/auth/realms/" <> realm

  defp signer(private_key), do: Joken.Signer.create("RS256", %{"pem" => private_key})
end
