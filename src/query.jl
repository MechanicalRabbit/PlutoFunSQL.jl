function query_macro(__module__, __source__, db, q)
    db = esc(db)
    ex = FunSQL.transliterate(q, FunSQL.TransliterateContext(__module__, __source__))
    return :(PlutoFunSQL.query($db, $ex))
end

function query(database, query)
    PlutoFunSQL.DataFrames.DataFrame(
        PlutoFunSQL.DBInterface.execute(database, query))
end
