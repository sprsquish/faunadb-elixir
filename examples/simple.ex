import Fauna

db_props = [
  secret: "secret",
  scheme: "http",
  domain: "localhost",
  port: 8443
]

r = %Fauna.Ref{value: "keys"}
z = "4"
q1 = query(db_props) do
  #create ref("databases"), name: "test-db"
  #create ref("keys"), role: "server", database: ref("databases/test-db")

  let [x: "2", y: "3"] do
    map ["a", "b"], fn str ->
      [concat([x, y, z, "foo", str], ":"),
       next_id,
      ref("databases"),
      obj(foo: "bar"),
      r]
    end
  end
end
IO.puts inspect(q1)

#pigkeepers = expr do
  #match ref("indexes/users_by_profession"), "Pigkeeper"
#end

#oracles = expr do
  #match ref("indexes/users_by_profession"), "Oracle"
#end

#q2 = query(db_props) do
  #paginate union(pigkeepers, oracles)

  #map ["a", "b"], fn name ->
    #create ref("databases"), name: name
  #end
#end

#IO.puts inspect(q1)
#IO.puts inspect(q2)
