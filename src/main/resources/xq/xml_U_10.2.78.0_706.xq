declare default element namespace 'http://crystals.ru/cash/settings';

if (doc-available(doc('config/modules/bank-config.xml'))) then (
  let $x := doc('config/modules/bank-config.xml')/moduleConfig/property[@key = 'plugins']
  return (
    if (exists($x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl'])) then (
      replace value of node $x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl']/@key with 'ru.crystals.pos.bank.ucs.BankUcsEftpos'
    ) else ()
  )
) else (),

if (doc-available(doc('config/plugins/bank-ucs-config.xml'))) then (
  let $x := doc('config/plugins/bank-ucs-config.xml')/moduleConfig/property[@key = 'serviceClass']
  return (
    if (exists($x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl'])) then (
      replace value of node $x/property[@key='ru.crystals.pos.bank.ucs.ServiceImpl']/@key with 'ru.crystals.pos.bank.ucs.BankUcsEftpos'
    ) else ()
  )
) else (),

if (doc-available(doc('modules/bank/bank-system-config.xml'))) then (
  let $x := doc('modules/bank/bank-system-config.xml')/beans/bean[@class="ru.crystals.pos.bank.ucs.ServiceImpl"]
  return (
    if (fn:exists($x)) then (
      delete node $x
    ) else ()
  )
) else ()
