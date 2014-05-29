defmodule Rockside.Doc do

  def tag(tag, attrs\\[], inner) do
    if attrs == [] do
      ["<#{tag}>", inner, "</#{tag}>"]
    else
      ["<#{tag} ", htmlize_attrs(attrs), ">", inner, "</#{tag}>"]
    end
  end

  def tag(tag), do: tag(tag, [], [])

  def tag1(tag, attrs\\[]) do
    if attrs == [] do
      "<#{tag} />"
    else
      ["<#{tag} ", htmlize_attrs(attrs), " />"]
    end
  end

  def flush(chunks) when is_list(chunks) do
    chunks |> List.flatten |> Enum.join
  end
  def flush(chunk) when is_binary(chunk), do: chunk
  # ^ needed only for plug-free tests, because patched Plug
  # accepts iolist as a resp body

  def html(attrs\\[], inner) do
    [ "<!DOCTYPE html>" | tag(:html, attrs, inner) ]
  end

  ~w[head title body]
    |> Enum.each fn name ->
      sym = :"#{name}"
      def unquote(sym)(attrs\\[], inner), do: tag(unquote(sym), attrs, inner)
      def unquote(sym)(), do: tag(unquote(sym))
    end
  ~w[meta]
    |> Enum.each fn name ->
      sym = :"#{name}"
      def unquote(sym)(attrs\\[]), do: tag1(unquote(sym), attrs)
    end

  defp htmlize_attrs(attrs) do
    Enum.map(attrs, fn {k,v} ->
      k = k |> to_string |> String.replace("_", "-")
      ~s/#{k}="#{v}"/
    end)
      |> Enum.intersperse(" ")
  end
end