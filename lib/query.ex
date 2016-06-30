defmodule Fauna.Logic do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: :functions

      def extract(vars, block), do: extract(vars, block, [])
      defp extract(vars, item, acc), do: acc ++ transpose(vars, item)
      def extract_params(vars, []), do: []
      def extract_params(vars, [params]), do: extract(vars, params)
    end
  end
end

defmodule Fauna do
  use Fauna.Logic

  defmacro query(options, [do: block]) do
    quote do: Fauna.HTTP.request(unquote(options), unquote(extract([], block)))
  end

  defmacro query!(options, [do: block]) do
    quote do: Fauna.HTTP.request!(unquote(options), unquote(extract([], block)))
  end

  defmacro expr(do: block) do
    extract([], block)
  end

  defp lambda(vars, {:fn, _, [{:->, _, [qvars, expr]}]}) do
    new_vars = Enum.map(qvars, fn {v, _, nil} -> v end)
    var_strs = Enum.map(new_vars, &Atom.to_string/1)
    args = if(length(var_strs) == 1, do: Enum.at(var_strs, 0), else: var_strs)

    [lambda: args,
     expr: extract(vars ++ new_vars, expr)]
  end

  def transpose(vars, block) do
    case block do
      {:ref, _, [ref]} ->
        quote do: %Fauna.Ref{value: unquote(extract(vars, ref))}

      {:obj, _, [object]} ->
        ["@obj": extract(vars, object)]

      {:let, _, [qvars, [do: block]]} ->
        new_vars = Keyword.keys qvars
        [let: extract(vars, qvars), "in": extract(vars ++ new_vars, block)]

      {:var, _, [name]} ->
        ["var": extract(vars, name)]

      {:if, _, [cnd, [do: thn, else: els]]} ->
        ["if": extract(vars, cnd),
         "then": extract(vars, thn),
         "else": extract(vars, els)]

      {:do, _, expr} ->
        ["do": extract(vars, expr)]

      {:map, _, [col, fun]} ->
        [map: lambda(vars, fun), collection: extract(vars, col)]

      {:foreach, _, [col, fun]} ->
        [foreach: lambda(vars, fun), collection: extract(vars, col)]

      {:filter, _, [col, fun]} ->
        [filter: lambda(vars, fun), collection: extract(vars, col)]

      {:take, _, [num, col]} ->
        [take: extract(vars, num), collection: extract(vars, col)]

      {:drop, _, [num, col]} ->
        [drop: extract(vars, num), collection: extract(vars, col)]

      {:prepend, _, [elems, col]} ->
        [prepend: extract(vars, elems), collection: extract(vars, col)]

      {:append, _, [elems, col]} ->
        [append: extract(vars, elems), collection: extract(vars, col)]

      {:get, _, [ref | params]} ->
        [get: extract(vars, ref)] ++ extract_params(vars, params)

      {:paginate, _, [set | params]} ->
        [paginate: extract(vars, set)] ++ extract_params(vars, params)

      {:exists, _, [set | params]} ->
        [exists: extract(vars, set)] ++ extract_params(vars, params)

      {:count, _, [set | params]} ->
        [count: extract(vars, set)] ++ extract_params(vars, params)

      {:create, _, [ref, data]} ->
        [create: extract(vars, ref),
         params: extract(vars, data)]

      {:update, _, [ref, data]} ->
        [update: extract(vars, ref),
         params: extract(vars, data)]

      {:replace, _, [ref, data]} ->
        [replace: extract(vars, ref),
         params: extract(vars, data)]

      {:delete, _, [ref]} ->
        [delete: extract(vars, ref)]

      {:insert, _, [ref, ts, action, params]} ->
        [insert: extract(vars, ref),
         ts: extract(vars, ts),
         action: extract(vars, action),
         params: extract(vars, params)]

      {:remove, _, [ref, ts, action]} ->
        [remove: extract(vars, ref),
         ts: extract(vars, ts),
         action: extract(vars, action)]

      {:match, _, [index, terms]} ->
        [match: extract(vars, index),
         terms: extract(vars, terms)]

      {:union, _, params} ->
        [union: extract(vars, params)]

      {:intersection, _, params} ->
        [intersection: extract(vars, params)]

      {:difference, _, params} ->
        [difference: extract(vars, params)]

      {:distinct, _, [set]} ->
        [distinct: extract(vars, set)]

      {:join, _, [src, wth]} ->
        [join: extract(vars, src), "with": extract(vars, wth)]

      {:login, _, [ref, params]} ->
        [login: extract(vars, ref), params: extract(vars, params)]

      {:logout, _, [all]} ->
        [logout: extract(vars, all)]

      {:identify, _, [ref, pass]} ->
        [identify: extract(vars, ref), password: extract(vars, pass)]

      {:concat, _, [strs, sep]} ->
        [concat: extract(vars, strs), separator: extract(vars, sep)]

      {:concat, _, [strs]} ->
        [concat: extract(vars, strs)]

      {:casefold, _, [strs]} ->
        [casefold: extract(vars, strs)]

      {:time, _, [strs]} ->
        [time: extract(vars, strs)]

      {:epoch, _, [num, unit]} ->
        [epoch: extract(vars, num), unit: extract(vars, unit)]

      {:date, _, [strs]} ->
        [date: extract(vars, strs)]

      {:next_id, _, nil} ->
        [next_id: nil]

      {:equals, _, args} ->
        [equals: extract(vars, args)]

      {:==, _, args} ->
        [equals: extract(vars, args)]

      {:add, _, args} ->
        [add: extract(vars, args)]

      {:+, _, args} ->
        [add: extract(vars, args)]

      {:multiply, _, args} ->
        [multiply: extract(vars, args)]

      {:*, _, args} ->
        [multiply: extract(vars, args)]

      {:divide, _, args} ->
        [divide: extract(vars, args)]

      {:/, _, args} ->
        [divide: extract(vars, args)]

      {:modulo, _, args} ->
        [modulo: extract(vars, args)]

      {:lt, _, args} ->
        [lt: extract(vars, args)]

      {:<, _, args} ->
        [lt: extract(vars, args)]

      {:lte, _, args} ->
        [lte: extract(vars, args)]

      {:<=, _, args} ->
        [lte: extract(vars, args)]

      {:gt, _, args} ->
        [gt: extract(vars, args)]

      {:>, _, args} ->
        [gt: extract(vars, args)]

      {:gte, _, args} ->
        [gte: extract(vars, args)]

      {:>=, _, args} ->
        [gte: extract(vars, args)]

      {:_and, _, args} ->
        ["and": extract(vars, args)]

      {:&&, _, args} ->
        ["and": extract(vars, args)]

      {:_or, _, args} ->
        ["or": extract(vars, args)]

      {:||, _, args} ->
        ["or": extract(vars, args)]

      {:!, _, [args]} ->
        ["not": extract(vars, args)]

      {:_not, _, [args]} ->
        ["not": extract(vars, args)]

      {:contains, _, [path, in_]} ->
        [contains: extract(vars, path), "in": extract(vars, in_)]

      {:select, _, [path, from | params]} ->
        [select: extract(vars, path),
         from: extract(vars, from)
        ] ++ extract_params(vars, params)

      {qvar, _, nil} ->
        if Enum.member?(vars, qvar) do
          ["var": Atom.to_string(qvar)]
        else
          block
        end

      {:__block__, _, block_list} ->
        [do: Enum.map(block_list, fn stmt -> extract(vars, stmt) end)]

      {key, value} ->
        {key, extract(vars, value)}

      arr when is_list(arr) ->
        arr |> Enum.map(fn n -> extract(vars, n) end)

      ast_node ->
        ast_node
    end
  end
end
