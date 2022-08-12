defmodule ClientAssertion.Token do
  @moduledoc """
  This token follows the specification written on Stone's public documentation.

  Dynamic claims are defined on `ClientAssertion.generate/3`.

  Reference: https://docs.openbank.stone.com.br/docs/guias/token-de-acesso/#autentica%C3%A7%C3%A3o
  """

  use Joken.Config

  @exp_in_seconds 15 |> :timer.minutes() |> div(1000)

  @impl true
  def token_config do
    %{}
    |> add_claim("exp", &generate_exp/0, &valid_exp?/1)
    |> add_claim("iat", &current_time/0, &is_integer/1)
    |> add_claim("nbf", &current_time/0, &is_integer/1)
    |> add_claim("jti", fn -> UUID.uuid4() end, &match?({:ok, _}, UUID.info(&1)))
  end

  defp generate_exp, do: current_time() + @exp_in_seconds

  defp valid_exp?(exp) when is_integer(exp),
    do: exp >= current_time() && exp <= current_time() + @exp_in_seconds

  defp valid_exp?(_exp), do: false
end
