import gleam/dynamic/decode
import gleam/json

pub type School {
  School(id: String, name: String, city_name: String, code_departement: String)
}

pub fn school_to_json(school: School) -> json.Json {
  json.object([
    #("id", json.string(school.id)),
    #("name", json.string(school.name)),
    #("city_name", json.string(school.city_name)),
    #("code_departement", json.string(school.code_departement)),
  ])
}

pub fn school_from_json(school: String) -> Result(School, json.DecodeError) {
  json.parse(school, school_decoder())
}

pub fn school_decoder() -> decode.Decoder(School) {
  let decoder = {
    use id <- decode.field("id", decode.string)
    use name <- decode.field("name", decode.string)
    use city_name <- decode.field("city_name", decode.string)
    use code_departement <- decode.field("code_departement", decode.string)

    decode.success(School(id:, name:, city_name:, code_departement:))
  }
  decoder
}

pub fn school_list_to_json(schools: List(School)) -> json.Json {
  json.array(schools, school_to_json)
}

pub fn school_list_from_json(
  schools: String,
) -> Result(List(School), json.DecodeError) {
  json.parse(schools, decode.list(school_decoder()))
}
