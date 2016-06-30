defmodule QueryTest do
  use ExUnit.Case, async: true
  import Fauna

  test "ref" do
    r = Fauna.expr do: ref("databases")
    j = ~s({"@ref":"databases"})
    assert r == %Fauna.Ref{value: "databases"}
    assert JSX.encode!(r) == j
    assert Fauna.Json.deserialize(JSX.decode!(j)) == r
  end

  test "setref" do
    r = %Fauna.SetRef{value: "databases"}
    assert JSX.encode!(r) == ~s({"@set":"databases"})
  end

  test "obj" do
    o = Fauna.expr do: obj(name: "foo")
    assert o == ["@object": [name: "foo"]]

    o = Fauna.expr do: obj(name: "foo", rank: "bar")
    assert o == ["@object": [name: "foo", rank: "bar"]]
  end

  test "let" do
    o = Fauna.expr do
      let [x: 3, y: 4] do
        [x, y]
      end
    end

    assert o == [let: [x: 3, y: 4], "in": [[var: "x"], [var: "y"]]]
  end

  test "var" do
    o = Fauna.expr do: var("x")
    assert o == [var: "x"]
  end

  test "if" do
    o = Fauna.expr do
      if true do
        "foo"
      else
        "bar"
      end
    end

    assert o == ["if": true, "then": "foo", "else": "bar"]
  end

  test "do" do
    o = Fauna.expr do
      "foo"
      "bar"
    end

    assert o == ["do": ["foo", "bar"]]
  end

  test "map" do
    o = Fauna.expr do
      map [1,2,3], fn x ->
        x
      end
    end

    assert o == [map: [lambda: "x", expr: [var: "x"]], collection: [1,2,3]]
  end

  test "foreach" do
    o = Fauna.expr do
      foreach [1,2,3], fn x ->
        x
      end
    end

    assert o == [foreach: [lambda: "x", expr: [var: "x"]], collection: [1,2,3]]
  end

  test "filter" do
    o = Fauna.expr do
      filter [1,2,3], fn x ->
        x
      end
    end

    assert o == [filter: [lambda: "x", expr: [var: "x"]], collection: [1,2,3]]
  end

  test "take" do
    o = Fauna.expr do: take(2, [1,2,3])
    assert o == [take: 2, collection: [1,2,3]]
  end

  test "drop" do
    o = Fauna.expr do: drop(2, [1,2,3])
    assert o == [drop: 2, collection: [1,2,3]]
  end

  test "prepend" do
    o = Fauna.expr do: prepend(1, [2,3])
    assert o == [prepend: 1, collection: [2,3]]

    o = Fauna.expr do: prepend([1,2], [3,4])
    assert o == [prepend: [1,2], collection: [3,4]]
  end

  test "append" do
    o = Fauna.expr do: append(1, [2,3])
    assert o == [append: 1, collection: [2,3]]

    o = Fauna.expr do: append([1,2], [3,4])
    assert o == [append: [1,2], collection: [3,4]]
  end

  test "get" do
    o = Fauna.expr do: get(ref("databases/foo"))
    assert o == [get: %Fauna.Ref{value: "databases/foo"}]

    o = Fauna.expr do: get(ref("databases/foo"), ts: 1234)
    assert o == [get: %Fauna.Ref{value: "databases/foo"}, ts: 1234]
  end

  test "paginate" do
    o = Fauna.expr do: paginate(ref("databases/foo"))
    assert o == [paginate: %Fauna.Ref{value: "databases/foo"}]

    o = Fauna.expr do: paginate(ref("databases/foo"), ts: 1234, after: 1234, size: 10, events: true, sources: false)
    assert o == [paginate: %Fauna.Ref{value: "databases/foo"}, ts: 1234, "after": 1234, size: 10, events: true, sources: false]
  end

  test "exists" do
    o = Fauna.expr do: exists(ref("databases/foo"))
    assert o == [exists: %Fauna.Ref{value: "databases/foo"}]

    o = Fauna.expr do: exists(ref("databases/foo"), ts: 1234)
    assert o == [exists: %Fauna.Ref{value: "databases/foo"}, ts: 1234]
  end

  test "count" do
    o = Fauna.expr do: count(match(ref("indexes/foo"), "bar"))
    assert o == [count: [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"]]

    o = Fauna.expr do: count(match(ref("indexes/foo"), "bar"), events: true)
    assert o == [count: [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"], events: true]
  end

  test "create" do
    o = Fauna.expr do: create(ref("databases"), name: "foo")
    assert o == [create: %Fauna.Ref{value: "databases"}, params: [name: "foo"]]
  end

  test "update" do
    o = Fauna.expr do: update(ref("databases/foo"), name: "foo")
    assert o == [update: %Fauna.Ref{value: "databases/foo"}, params: [name: "foo"]]
  end

  test "replace" do
    o = Fauna.expr do: replace(ref("databases/foo"), name: "foo")
    assert o == [replace: %Fauna.Ref{value: "databases/foo"}, params: [name: "foo"]]
  end

  test "delete" do
    o = Fauna.expr do: delete(ref("databases/foo"))
    assert o == [delete: %Fauna.Ref{value: "databases/foo"}]
  end

  test "insert" do
    o = Fauna.expr do: insert(ref("databases/foo"), 1234, "create", name: "foo")
    assert o == [insert: %Fauna.Ref{value: "databases/foo"}, ts: 1234, action: "create", params: [name: "foo"]]
  end

  test "remove" do
    o = Fauna.expr do: remove(ref("databases/foo"), 1234, "create")
    assert o == [remove: %Fauna.Ref{value: "databases/foo"}, ts: 1234, action: "create"]
  end

  test "match" do
    o = Fauna.expr do: match(ref("indexes/foo"), "bar")
    assert o == [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"]

    o = Fauna.expr do: match(ref("indexes/foo"), ["bar", "baz"])
    assert o == [match: %Fauna.Ref{value: "indexes/foo"}, terms: ["bar", "baz"]]
  end

  test "union" do
    o = Fauna.expr do
      union(
        match(ref("indexes/foo"), "bar"),
        match(ref("indexes/bar"), "baz"))
    end
    assert o == [union: [
      [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"],
      [match: %Fauna.Ref{value: "indexes/bar"}, terms: "baz"]]]
  end

  test "intersection" do
    o = Fauna.expr do
      intersection(
        match(ref("indexes/foo"), "bar"),
        match(ref("indexes/bar"), "baz"))
    end
    assert o == [intersection: [
      [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"],
      [match: %Fauna.Ref{value: "indexes/bar"}, terms: "baz"]]]
  end

  test "difference" do
    o = Fauna.expr do
      difference(
        match(ref("indexes/foo"), "bar"),
        match(ref("indexes/bar"), "baz"))
    end
    assert o == [difference: [
      [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"],
      [match: %Fauna.Ref{value: "indexes/bar"}, terms: "baz"]]]
  end

  test "distinct" do
    o = Fauna.expr do: distinct(match(ref("indexes/foo"), "bar"))
    assert o == [distinct: [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"]]
  end

  test "join" do
    o = Fauna.expr do: join(match(ref("indexes/foo"), "bar"), ref("indexes/bar"))
    assert o == [join: [match: %Fauna.Ref{value: "indexes/foo"}, terms: "bar"],
                 "with": %Fauna.Ref{value: "indexes/bar"}]
  end

  test "login" do
    o = Fauna.expr do: login(ref("foo"), password: "bar")
    assert o == [login: %Fauna.Ref{value: "foo"}, params: [password: "bar"]]
  end

  test "logout" do
    o = Fauna.expr do: logout(true)
    assert o == [logout: true]
  end

  test "identify" do
    o = Fauna.expr do: identify(ref("foo"), "bar")
    assert o == [identify: %Fauna.Ref{value: "foo"}, password: "bar"]
  end

  test "concat" do
    o = Fauna.expr do: concat(["a", "b", "c"])
    assert o == [concat: ["a", "b", "c"]]

    o = Fauna.expr do: concat(["a", "b", "c"], ", ")
    assert o == [concat: ["a", "b", "c"], separator: ", "]
  end

  test "casefold" do
    o = Fauna.expr do: casefold("Foo Bar")
    assert o == [casefold: "Foo Bar"]
  end

  test "time" do
    o = Fauna.expr do: time("1970-01-01T00:00:00+00:00")
    assert o == [time: "1970-01-01T00:00:00+00:00"]
  end

  test "epoch" do
    o = Fauna.expr do: epoch(0, "second")
    assert o == [epoch: 0, unit: "second"]
  end

  test "date" do
    o = Fauna.expr do: date("1970-01-01")
    assert o == [date: "1970-01-01"]
  end

  test "next_id" do
    o = Fauna.expr do: next_id
    assert o == [next_id: nil]
  end

  test "equals" do
    o = Fauna.expr do: equals(1,2,3)
    assert o == [equals: [1,2,3]]
    o = Fauna.expr do: 1 == 2
    assert o == [equals: [1,2]]
  end

  test "add" do
    o = Fauna.expr do: add(1,2,3)
    assert o == [add: [1,2,3]]
    o = Fauna.expr do: 1 + 2
    assert o == [add: [1,2]]
  end

  test "multiply" do
    o = Fauna.expr do: multiply(1,2,3)
    assert o == [multiply: [1,2,3]]
    o = Fauna.expr do: 1 * 2
    assert o == [multiply: [1,2]]
  end

  test "divide" do
    o = Fauna.expr do: divide(1,2,3)
    assert o == [divide: [1,2,3]]
    o = Fauna.expr do: 1 / 2
    assert o == [divide: [1,2]]
  end

  test "modulo" do
    o = Fauna.expr do: modulo(1,2,3)
    assert o == [modulo: [1,2,3]]
  end

  test "lt" do
    o = Fauna.expr do: lt(1,2,3)
    assert o == [lt: [1,2,3]]
    o = Fauna.expr do: 1 < 2
    assert o == [lt: [1,2]]
  end

  test "lte" do
    o = Fauna.expr do: lte(1,2,3)
    assert o == [lte: [1,2,3]]
    o = Fauna.expr do: 1 <= 2
    assert o == [lte: [1,2]]
  end

  test "gt" do
    o = Fauna.expr do: gt(1,2,3)
    assert o == [gt: [1,2,3]]
    o = Fauna.expr do: 1 > 2
    assert o == [gt: [1,2]]
  end

  test "gte" do
    o = Fauna.expr do: gte(1,2,3)
    assert o == [gte: [1,2,3]]
    o = Fauna.expr do: 1 >= 2
    assert o == [gte: [1,2]]
  end

  test "and" do
    o = Fauna.expr do: _and(1,2,3)
    assert o == ["and": [1,2,3]]
    o = Fauna.expr do: 1 && 2
    assert o == ["and": [1,2]]
  end

  test "or" do
    o = Fauna.expr do: _or(1,2,3)
    assert o == ["or": [1,2,3]]
    o = Fauna.expr do: 1 || 2
    assert o == ["or": [1,2]]
  end

  test "not" do
    o = Fauna.expr do: _not(true)
    assert o == ["not": true]
    o = Fauna.expr do: !true
    assert o == ["not": true]
  end

  test "contains" do
    o = Fauna.expr do: contains(["foo", "bar"], [foo: [bar: "baz"]])
    assert o == [contains: ["foo", "bar"], "in": [foo: [bar: "baz"]]]
  end

  test "select" do
    o = Fauna.expr do: select(["foo", "bar"], [foo: [bar: "baz"]])
    assert o == [select: ["foo", "bar"], from: [foo: [bar: "baz"]]]

    o = Fauna.expr do: select(["foo", "bar"], [foo: "baz"], default: 1)
    assert o == [select: ["foo", "bar"], from: [foo: "baz"], default: 1]
  end
end
