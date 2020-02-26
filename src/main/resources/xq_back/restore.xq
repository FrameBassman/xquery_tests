declare namespace reg = "http://www.springframework.org/schema/beans";
declare namespace s = "java.lang.System";

(: свойства, что собираемся переносить лежат в этом файле :)
(:declare variable $propertiesFile := doc('D:\visualization-system-config.xml');:)
declare variable $propertiesFile := doc('/home/d.romashov/projects/xquery_tests/src/main/resources/configs/modules/visualization/visualization-system-config.xml');


(: пароль доступа к БД catalog :)
declare variable $password := 'postgres';

(: login доступа к БД SET :)
declare variable $login := 'postgres';

(: URL для доступа до БД catalog :)
declare variable $url := "jdbc:postgresql://localhost:5432/catalog";


(:
  вернет коннекцию до БД catalog.
  NOTE: не забыть закрыть: sql:close($conn) в самом конце
:)
declare function local:getConnection() as xs:integer {
  sql:connect($url, $login, $password, map {'autocommit': true()})
};

(:
  выполняет указанный запрос.
  аргументы:
  conn - коннект до БД, на которой собираемся выполнить запрос
  query - сам SQL-запрос. что собираемся выполнить
:)
declare function local:executeSqlQuery($conn as xs:integer, $query as xs:string) as item()* {
  sql:execute($conn, $query),
  ()
};

declare function local:getPreviousValue($conn as xs:integer,
                                   $moduleName as xs:string,
                                   $propertyName as xs:string) as xs:string? {
  let $query := "SELECT property_value FROM sales_management_properties"
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "WHERE module_name = '", $moduleName, "' AND property_key = '", $propertyName, "' &#10;")

  return (
    local:executeSqlQuery($conn, $query)
  )
};

declare updating function local:deletePreviousValue($conn as xs:integer,
                                   $moduleName as xs:string,
                                   $propertyName as xs:string) {
  for $conn in
  let $query := "DELETE FROM sales_management_properties"
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "WHERE module_name = '", $moduleName, "' AND property_key = '", $propertyName, "' &#10;")

  return (
    local:executeSqlQuery($conn, $query)
  )
return()
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
declare updating function local:addProperty($propertyName as xs:string,
                                   $propertyValue as xs:string) {
for $x in $propertiesFile/reg:beans/reg:bean[@id='visualization']
return (
 if (not(exists($x/reg:property[@name=$propertyName])))
    then(
    insert node <property name="placeholder" value=""/>
    as last into $x,
                replace value of node $x/reg:property[@name="placeholder"]/@name with $propertyName,
                replace value of node $x/reg:property[@name=$propertyName]/@value with $propertyValue
         )
    else()
)
};

(:
  сама функция по копированию свойств из файла в БД
  аргументы:
  conn          - коннект до БД catalog
:)
declare %updating function local:addProperties($conn as xs:integer) {
  let $propertyName := 'RemindCardNotScanned'
  let $previousValue := local:getPreviousValue($conn, 'SCO', $propertyName)
  return (
    if (exists($previousValue)) then (
      local:addProperty($propertyName, $previousValue)
    )
    else (
      local:addProperty($propertyName, "true")
    )
  )
};

let $conn := local:getConnection()
let $propertyName := 'RemindCardNotScanned'
return (
  sql:init("org.postgresql.Driver"),
  local:addProperties($conn),
  local:deletePreviousValue($conn, 'SCO', $propertyName),
  sql:close($conn)
)
