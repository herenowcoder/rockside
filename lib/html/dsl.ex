alias Rockside.HTML

defmodule HTML.DSL do
  alias   Rockside.HTML.Assembly.St
  require St

  defmodule Helpers do
    defmacro tag_start(tag) do
      quote do: "<#{unquote(tag)}>"
    end
    defmacro tag_end(tag) do
      quote do: "</#{unquote(tag)}>"
    end
  end


  # basic api

  defmacro builder(do: body) do
    quote do
      alias Rockside.HTML.Assembly.St
      var!(st) = St.new
      unquote(body)
      St.release(var!(st))
    end
  end

  defmacro add_tag(tagname, content) do
    quote do
      import Helpers
      alias Rockside.HTML.Assembly.St
      var!(st) = var!(st) |> St.push(tag_start(unquote(tagname)))
      var!(st) = var!(st) |> St.push(unquote(content))
      var!(st) = var!(st) |> St.push(tag_end(unquote(tagname)))
    end
  end

  defmacro tag(tagname, do: body) do
    quote do
      add_tag(unquote(tagname), fn ->
        builder do: unquote(body)
      end.())
    end
  end

  defmacro tag(tagname, content) do
    quote do: add_tag(unquote(tagname), unquote(content))
  end

  ~w[
    html head title base link meta style
    script noscript template
    body section nav article aside h1 h2 h3 h4 h5 h6
    header footer address main
    p hr pre blockquote ol ul li dl dt dd figure figcaption div
    a em strong small s cite q dfn abbr data time code var samp kbd
    sub sup i b u mark ruby rt rp bdi bdo span br wbr
    ins del
    img iframe embed object param video audio source track canvas
    map area svg math
    table caption colgroup col tbody thead tfoot tr td th
    form fieldset legend label input button select datalist optgroup
    option textarea keygen output progress meter
    details summary menuitem menu
    ] |> Enum.each fn name ->
      sym = :"#{name}"
      defmacro unquote(sym)(whatever) do
        t = unquote(sym)
        quote do: tag(unquote(t), unquote(whatever))
      end
    end

  defmacro text(content) do
    quote do
      var!(st) = var!(st) |> St.push(unquote(content))
    end
  end

end
