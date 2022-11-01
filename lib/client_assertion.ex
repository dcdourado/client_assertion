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

  @accounts_url_sandbox Application.compile_env!(:client_assertion, :accounts_url_sandbox)
  @accounts_url_homolog Application.compile_env!(:client_assertion, :accounts_url_homolog)

  @doc "Uses `generate/4` with \"stone_bank\" audience"
  @spec generate(client_id :: uuid(), private_key :: pem(), environment :: String.t()) :: assertion()
  def generate(client_id, private_key, environment) when is_binary(client_id) and is_binary(private_key),
    do: generate(client_id, "stone_bank", private_key, environment)

  @doc "Generates a JWT with required claims and signs it using given private key"
  @spec generate(
          client_id :: uuid(),
          realm :: String.t(),
          private_key :: pem(),
          environment :: String.t()
        ) :: assertion()
  def generate(client_id, realm, private_key, environment)
      when is_binary(client_id) and is_binary(realm) and is_binary(private_key) and
             is_binary(environment) do
    ClientAssertion.Token.generate_and_sign!(
      %{
        "iss" => client_id,
        "sub" => client_id,
        "clientId" => client_id,
        "realm" => realm,
        "aud" => aud(realm, environment)
      },
      signer(private_key)
    )
  end

  defp aud(realm, "sandbox"), do: @accounts_url_sandbox <> "/auth/realms/" <> realm
  defp aud(realm, "homolog"), do: @accounts_url_homolog <> "/auth/realms/" <> realm

  defp signer(private_key), do: Joken.Signer.create("RS256", %{"pem" => private_key})

  @type http_client_response ::
          {:ok, status_code :: pos_integer(),
           headers :: list({name :: String.t(), value :: String.t()}), body :: String.t()}
          | {:error, term()}

  @doc "Makes the authentication request with given client assertion to the accounts URL"
  @spec authenticate(assertion :: assertion(), environment :: String.t()) ::
          http_client_response()
  def authenticate(assertion, environment) when is_binary(assertion) do
    {:ok, %{"realm" => realm, "iss" => client_id}} = Joken.peek_claims(assertion)

    url =
      if environment == "sandbox",
        do:
          (@accounts_url_sandbox <> "/auth/realms/#{realm}/protocol/openid-connect/token")
          |> IO.inspect(),
        else:
          (@accounts_url_homolog <> "/auth/realms/#{realm}/protocol/openid-connect/token")
          |> IO.inspect()

    :hackney.request(
      "post",
      url,
      [
        {"user-agent", "ClientAssertion"},
        {"content-type", "application/x-www-form-urlencoded"}
      ],
      {:form,
       [
         {"client_id", client_id},
         {"grant_type", "client_credentials"},
         {"client_assertion", assertion},
         {"client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"}
       ]},
      [:with_body]
    )
  end
end
