declare default element namespace 'http://crystals.ru/cash/settings';

if (doc-available('config/plugins/barcodeScanner-d2-config.xml')) then (
  let $x := doc('config/plugins/barcodeScanner-d2-config.xml')/moduleConfig/property[@key = 'serviceClass']
  return (
    if (fn:exists($x)) then (
      replace value of node $x/@value with 'ru.crystals.pos.barcodescanner.ps2.BarcodeScannerPs2ServiceImpl'
    ) else ()
  )
) else (),

if (doc-available('modules/barcodeScanner/barcodeScanner-system-config.xml')) then (
  let $x := doc('modules/barcodeScanner/barcodeScanner-system-config.xml')/beans/bean[@class="ru.crystals.pos.barcodescanner.ps2.ServiceImpl"]
  return (
    if (fn:exists($x)) then (
      delete node $x
    ) else ()
  )
) else ()
