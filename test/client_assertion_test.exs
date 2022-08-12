defmodule ClientAssertionTest do
  use ExUnit.Case

  @private_key File.read!("mykey.pem")
  @accounts_url Application.compile_env!(:client_assertion, :accounts_url)

  describe "generate/2" do
    test "uses \"stone_bank\" as the realm" do
      assert {:ok, %{"aud" => aud, "realm" => "stone_bank"}} =
               "client_id"
               |> ClientAssertion.generate(@private_key)
               |> Joken.peek_claims()

      assert String.ends_with?(aud, "/stone_bank")
    end
  end

  describe "generate/3" do
    setup do
      assertion = ClientAssertion.generate("client_id", "custom_realm", @private_key)
      {:ok, assertion: assertion}
    end

    test "creates header according to the spec", ctx do
      assert {:ok, %{"alg" => "RS256", "typ" => "JWT"}} == Joken.peek_header(ctx.assertion)
    end

    test "creates claims according to the spec", ctx do
      assert {:ok,
              %{
                "exp" => exp,
                "iat" => iat,
                "nbf" => nbf,
                "realm" => "custom_realm",
                "aud" => @accounts_url <> "/auth/realms/custom_realm",
                "iss" => "client_id",
                "sub" => "client_id",
                "clientId" => "client_id"
              }} = Joken.peek_claims(ctx.assertion)

      expiration_in_seconds = 15 |> :timer.minutes() |> div(1000)
      assert iat + expiration_in_seconds == exp
      assert iat == nbf
    end
  end
end
