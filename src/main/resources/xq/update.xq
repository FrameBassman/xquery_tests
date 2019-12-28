declare namespace s = "java.lang.System";

(: свойства, что собираемся переносить лежат в этом файле :)
declare variable $propertiesFile := doc('/home/d.romashov/projects/XQueryTest/home/modules/visualization');

(: возвращает пароль доступа к БД SET :)
declare function local:getPassword() as xs:string {
  let $password := 'postgres'
  return $password
};

(: возвращает login доступа к БД SET :)
declare function local:getLogin() as xs:string {
  let $login := 'postgres'
  return $login
};

(:
  Вернет URL для доступа до БД SET.
:)
declare function local:getDbSetUrl() as xs:string {
  let $url := "jdbc:postgresql://localhost:5432/catalog"
  return $url
};


(:
  вернет коннекцию до БД SET.
  NOTE: не забыть закрыть: sql:close($conn) в самом конце
:)
declare function local:getConnection() as xs:integer {
  let $pass := local:getPassword()
  let $login := local:getLogin()
  let $url := local:getDbSetUrl()

  return sql:connect($url, $login, $pass, map {'autocommit': true()})
};

(:
  выполняет указанный запрос.
  аргументы:
  conn - коннект до БД, на которой собираемся выполнить запрос
  query - сам SQL-запрос. что собираемся выполнить
:)
declare function local:executeSqlQuery($conn as xs:integer, $query as xs:string) as empty-sequence() {
  sql:execute($conn, $query),
  ()
};

declare function local:getPreviousValue($propertyName as xs:integer) as xs:string {
  for $x in $propertiesFile//beans/bean[@id='visualization']/property[name()=$propertyName]
  return data($x/@value)
};

(:
  Добавит в БД указанную настройку, если ее еще нет
  аргументы:
  conn          - коннект до БД SET
  moduleName    - название модуля, которому "принадлежит" добавляемая настройка
  propertyName  - название свойства/настройки
  propertyValue - значение свойства/настройки
  description   - описание свойства/настройки
:)
declare function local:addProperty($conn as xs:integer,
                                   $moduleName as xs:string,
                                   $propertyName as xs:string,
                                   $propertyValue as xs:string,
                                   $description as xs:string) as empty-sequence () {
  let $query := "INSERT INTO sales_management_properties(module_name, property_key, property_value, description)"
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "SELECT '", $moduleName, "'")
  let $query := fn:concat($query, ", '", $propertyName, "'")

  (: А если NULL ? :)
  let $query := if (empty($propertyValue)) then
    fn:concat($query, ", NULL")
  else
    fn:concat($query, ", '", $propertyValue, "'")

  let $query := fn:concat($query, ", '", $description, "'")
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "WHERE NOT EXISTS (&#10;")
  let $query := fn:concat($query, "SELECT module_name, property_key, property_value, description FROM sales_management_properties &#10;")
  let $query := fn:concat($query, "WHERE module_name = '", $moduleName, "' AND property_key = '", $propertyName, "' &#10;")
  let $query := fn:concat($query, ")")

  return (
    local:executeSqlQuery($conn, $query)
  )
};

(:
  сама функция по копированию свойств из файла в БД
  аргументы:
  conn          - коннект до БД SET
:)
declare function local:addProperties($conn as xs:integer) as empty-sequence() {
  let $propertyName := 'RemindCardNotScanned'
(:  let $previousValue := local:getPreviousValue($propertyName):)
  return (
    local:addProperty($conn, 'SCO', $propertyName, 'true', '')
  )
};

let $conn := local:getConnection()
return (
  sql:init("org.postgresql.Driver"),
  local:addProperties($conn),
  sql:close($conn)
)
