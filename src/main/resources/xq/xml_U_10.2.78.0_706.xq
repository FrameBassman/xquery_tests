declare default element namespace 'http://crystals.ru/cash/settings';

if (doc-available(doc('config/modules/bank-config.xml'))) then (
  let $x := doc('config/modules/bank-config.xml')/moduleConfig/property[@key = 'plugins']
  return (
    if (exists($x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl'])) then (
      replace value of node $x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl']/@key with 'ru.crystals.pos.bank.ucs.BankUcsEftpos'
    ) else ()
  )
) else ()
