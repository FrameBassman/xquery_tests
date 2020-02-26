declare namespace reg = "http://www.springframework.org/schema/beans";
declare namespace s = "java.lang.System";

(: свойства, что собираемся переносить лежат в этом файле :)
declare variable $propertiesFile := doc('/home/d.romashov/projects/setretail10/SetRetail10_SCO/RobotSCO/configSCO/modules/visualization/visualization-system-config.xml');

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


declare updating function local:addPropertyIfNotExists($key as xs:string, $value as xs:string) {
    if (not(exists($propertiesFile/moduleConfig/property[@key = $key])))
    then (
    (: добавим это свойство :)
    insert node element property {
        attribute key {$key},
        attribute value {$value}
    }
    as last into $propertiesFile/reg:beans/reg:bean[@id='visualization']
    ) else (
    (: свойство уже есть :)
    )
};

declare function local:deletePreviousValue($conn as xs:integer,
                                   $moduleName as xs:string,
                                   $propertyName as xs:string) {
  let $query := "DELETE FROM sales_management_properties"
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "WHERE module_name = '", $moduleName, "' AND property_key = '", $propertyName, "' &#10;")

  return (
    local:executeSqlQuery($conn, $query)
  )
};

declare updating function local:addPropertyWithValueFromDb($conn as xs:integer, $propertyName as xs:string) {
  let $previousValue := local:getPreviousValue($conn, 'SCO', $propertyName)
  let $result := local:deletePreviousValue($conn, 'SCO', 'RemindCardNotScanned')

  return (
    local:addPropertyIfNotExists($propertyName, $previousValue)
  )
};

declare updating function local:addPropertyWithDefaultValue($propertyName as xs:string, $defaultValue as xs:string) {
  local:addPropertyIfNotExists($propertyName, $defaultValue)
};

declare variable $conn := local:getConnection();
declare variable $previousValue := local:getPreviousValue($conn, 'SCO', 'RemindCardNotScanned');

sql:init("org.postgresql.Driver"),
if (exists($previousValue)) then (
    local:addPropertyWithValueFromDb($conn, 'RemindCardNotScanned')
) else (
    local:addPropertyWithDefaultValue('RemindCardNotScanned', 'false')
),
sql:close($conn)
