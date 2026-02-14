DB = {}

function DB.execute(query, params)
    return exports.oxmysql:execute(query, params or {})
end

function DB.query(query, params)
    return exports.oxmysql:query_async(query, params or {})
end

function DB.scalar(query, params)
    return exports.oxmysql:scalar_async(query, params or {})
end