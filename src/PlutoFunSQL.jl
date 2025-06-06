module PlutoFunSQL

using DBInterface
using DataFrames
using FunSQL
using FunSQL: @dissect, Chain, Fun, Var
using HypertextLiteral
using UUIDs

include("resolve.jl")
include("query.jl")
include("summary.jl")
include("inventory.jl")

# keep last; export all funsql_
include("duckdb.jl")

funsql_and = var"funsql_&&"
export funsql_and
funsql_or = var"funsql_||"
export funsql_or

end
