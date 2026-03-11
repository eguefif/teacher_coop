import gleam/dynamic/decode
import gleam/json

pub type School {
  School(name: String, city: String, departement: String)
}

pub fn school_to_json(school: School) -> json.Json {
  json.object([
    #("name", json.string(school.name)),
    #("name", json.string(school.city)),
    #("name", json.string(school.departement)),
  ])
}

pub fn school_from_json(school: String) -> Result(School, json.DecodeError) {
  let decoder = {
    use name <- decode.field("name", decode.string)
    use city <- decode.field("city", decode.string)
    use departement <- decode.field("departement", decode.string)

    decode.success(School(name:, city:, departement:))
  }

  json.parse(school, decoder)
}

pub fn school_list_to_json(schools: List(School)) -> json.Json {
  json.array(schools, school_to_json)
}
