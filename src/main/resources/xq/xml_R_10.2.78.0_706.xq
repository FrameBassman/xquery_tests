declare default element namespace 'http://crystals.ru/cash/settings';

if (doc-available('config/modules/bank-config.xml')) then (
  let $x := fn:doc('config/modules/bank-config.xml')/moduleConfig/property[@key = 'plugins']
  return (
    if (exists($x/property[@key='ru.crystals.pos.bank.ucs.BankUcsEftpos'])) then (
      replace value of node $x/property[@key='ru.crystals.pos.bank.ucs.BankUcsEftpos']/@key with 'ru.crystals.pos.bank.ucs.ServiceImpl'
    ) else ()
  )
) else ()
