declare default element namespace 'http://crystals.ru/cash/settings';

if (doc-available('config/plugins/barcodeScanner-d2-config.xml')) then (
  let $x := fn:doc('config/plugins/barcodeScanner-d2-config.xml')/moduleConfig/property[@key = 'serviceClass']
  return (
    if (fn:exists($x)) then (
      replace value of node $x/@value with 'ru.crystals.pos.barcodescanner.ps2.ServiceImpl'
    ) else ()
  )
) else ()
