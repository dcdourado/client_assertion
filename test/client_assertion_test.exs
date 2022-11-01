defmodule ClientAssertionTest do
  use ExUnit.Case

  @private_key File.read!("mykey.pem")
  
  @accounts_url_sandbox Application.compile_env!(:client_assertion, :accounts_url_sandbox)
  @accounts_url_homolog Application.compile_env!(:client_assertion, :accounts_url_homolog)

  describe "generate/3" do
    for environment <- ["sandbox", "homolog"] do
      test "uses \"stone_bank\" as the realm for #{environment}" do
        env = unquote(environment)
        assert {:ok, %{"aud" => aud, "realm" => "stone_bank"}} =
                "client_id"
                |> ClientAssertion.generate(@private_key, env)
                |> Joken.peek_claims()

        assert String.ends_with?(aud, "/stone_bank")
      end
    end
  end

  describe "generate/4" do
    setup do
      sandbox_assertion = ClientAssertion.generate("client_id", "custom_realm", @private_key, "sandbox")
      homolog_assertion = ClientAssertion.generate("client_id", "custom_realm", @private_key, "homolog")
      {:ok, sandbox_assertion: sandbox_assertion, homolog_assertion: homolog_assertion}
    end

    for environment <- ["sandbox", "homolog"] do
      test "creates header according to the spec for #{environment}" do
        assertion = ClientAssertion.generate("client_id", "custom_realm", @private_key, unquote(environment))
        assert {:ok, %{"alg" => "RS256", "typ" => "JWT"}} == Joken.peek_header(assertion)
      end

      test "creates claims according to the spec - #{environment}", ctx do
        url = if unquote(environment) == "sandbox", do: @accounts_url_sandbox <> "/auth/realms/custom_realm", else: @accounts_url_homolog <> "/auth/realms/custom_realm"
        assertion = if unquote(environment) == "sandbox", do: ctx.sandbox_assertion, else: ctx.homolog_assertion
        assert {:ok,
                %{
                  "exp" => exp,
                  "iat" => iat,
                  "nbf" => nbf,
                  "realm" => "custom_realm",
                  "aud" => ^url,
                  "iss" => "client_id",
                  "sub" => "client_id",
                  "clientId" => "client_id"
                }} = Joken.peek_claims(assertion)

        expiration_in_seconds = 15 |> :timer.minutes() |> div(1000)
        assert iat + expiration_in_seconds == exp
        assert iat == nbf
      end
    end

  end
end
