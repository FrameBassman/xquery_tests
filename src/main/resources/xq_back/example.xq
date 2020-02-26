(: ESB-118: перенесем настройки из products.properties в БД :)
declare namespace ns='urn:jboss:domain:1.2';
declare namespace dsns='urn:jboss:domain:datasources:1.0';

declare namespace p = "java.util.Properties";
declare namespace fr = "java.io.FileReader";
declare namespace s = "java.lang.System";

(: свойства, что собираемся переносить лежат в этом файле :)
declare variable $propertiesFile := fn:concat(s:getProperty("user.dir"),'/standalone/configuration/modules/products/products.properties');

(: документ standalone.xml :)
declare variable $standaloneXmlDoc := doc('standalone/configuration/standalone.xml');

(: вот эти свойства будем переносить в БД :)
declare variable $propertiesToMove := (
  'goods.catalog.split.recods');

(:
  а это - описания тех же самых настроек.
  Просто не знал как по 2D массиву итерировать - а то бы в одном массиве описал и настройки и описания
:)
declare variable $propertyDescriptions := (
  'Максимальное количество товарных справочников из erpi_goodscatalog, что обрабатывать за 1 итерацию. Настройка действует только в ЦО');

(: возвращает пароль доступа к БД SET :)
declare function local:getPassword() as xs:string {
  let $profilePath := $standaloneXmlDoc//ns:server/ns:profile
  let $dsPath := $profilePath/dsns:subsystem/dsns:datasources/dsns:xa-datasource[@jndi-name="java:/SETv6_DS"]
  let $securityPath := $dsPath/dsns:security

  return $securityPath/dsns:password
};

(: возвращает login доступа к БД SET :)
declare function local:getLogin() as xs:string {
  let $profilePath := $standaloneXmlDoc//ns:server/ns:profile
  let $dsPath := $profilePath/dsns:subsystem/dsns:datasources/dsns:xa-datasource[@jndi-name="java:/SETv6_DS"]
  let $securityPath := $dsPath/dsns:security

  return $securityPath/dsns:user-name
};

(:
  Вернет URL для доступа до БД SET.
:)
declare function local:getDbSetUrl() as xs:string {
  let $profilePath := $standaloneXmlDoc//ns:server/ns:profile
  let $dsPath := $profilePath/dsns:subsystem/dsns:datasources/dsns:xa-datasource[@jndi-name="java:/SETv6_DS"]

  let $host := $dsPath/dsns:xa-datasource-property[@name="ServerName"]
  let $host := if (empty($host)) then "localhost" else fn:normalize-space($host)

  let $port := $dsPath/dsns:xa-datasource-property[@name="PortNumber"]
  let $port := if (empty($host)) then "5432" else fn:normalize-space($port)

  return fn:concat("jdbc:postgresql://", $host, ":", $port, "/set")
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
  Добавит в БД указанную настройку (если ее еще нет), значение которой равно NULL
  NOTE: не знал как кастовать NULL к xs:string - иначе можно было бы одним методом обойтись
  аргументы:
  conn          - коннект до БД SET
  moduleName    - название модуля, которому "принадлежит" добавляемая настройка
  propertyName  - название свойства/настройки
  description   - описание свойства/настройки
:)
declare function local:addPropertyWithNullValue($conn as xs:integer,
                                   $moduleName as xs:string,
                                   $propertyName as xs:string,
                                   $description as xs:string) as empty-sequence () {
  let $query := "INSERT INTO sales_management_properties(module_name, property_key, property_value, description)"
  let $query := fn:concat($query, "&#10;")
  let $query := fn:concat($query, "SELECT '", $moduleName, "'")
  let $query := fn:concat($query, ", '", $propertyName, "'")
  let $query := fn:concat($query, ", NULL")
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
  let $p := p:new()
  let $file := fr:new($propertiesFile)
  return (
    p:load($p, $file),
    (: да, нумерация с 1. 0й индекс, видимо, зарезервирован под сам массив :)
    for $idx in 1 to 1
      let $value := p:get($p, $propertiesToMove[$idx])
      return if (empty($value)) then
                local:addPropertyWithNullValue($conn, 'SET_PRODUCTS', $propertiesToMove[$idx], $propertyDescriptions[$idx])
             else
                local:addProperty($conn, 'SET_PRODUCTS', $propertiesToMove[$idx], $value, $propertyDescriptions[$idx]),
    fr:close($file)
  )
};

let $conn := local:getConnection()
return (
  sql:init("org.postgresql.Driver"),
  local:addProperties($conn),
  sql:close($conn)
)
