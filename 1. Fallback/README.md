# Fallback
Ethernaut'un ilk seviyesine ve akıllı sözleşmeler zaafiyeti öğrenme serüvenimize hepiniz hoşgeldiniz. Başlamadan önce bu reponun ana sayfasındaki yazdıklarımı okuduğunuzdan emin olun lütfen. Ethernaut ve platformda işlem yapabilmemiz için gerekli olan bütün bilgileri ve kurulumları orada bahsettim. İlk seviyeyi görüntülemek için [buraya](https://ethernaut.openzeppelin.com/level/0x9CB391dbcD447E645D6Cb55dE6ca23164130D008) tıklayabilirsiniz.

Fallback sözleşmesini incelemeden önce bu seviyeyi geçmek için neler yapmamız gerektiğine bakalım. Seviyeyi tamamlayabilmemiz için sözleşmenin sahipliğini ele geçirmemiz ve sözleşmenin bakiyesini sıfırlamamız gerekiyor. Ek olarak seviyeyi atlamamıza yardımcı olacak konseptleri de yazmışlar, bunları da aşağıya bırakıyorum:

 1. ABI'yi kullanarak sözleşmelere ether göndermek.
 2. ABI'nın dışında sözleşmeye ether göndermek.
 3. toWei/fromWei metotlarını kullanarak ether ve wei birim dönüşümlerini yapmak Tarayıcınızın konsoluna **help()** komutunu yazarak bu metotlar hakkında bilgi alabilirsiniz.
 4. Fallback metotları.

Öncelikle bu ABI (Application Binary Interface) neymiş onu öğrenelim. Öncelikle Ethereum üzerinde sözleşmelerinizi yayımlarken sözleşme adresinizle bytecode ilişkilendirilir ve Ethereum'da depolanır. Peki soracaksınız bu bytecode da ne? Bytecode, sizin Solidity dilinde yazdığınız kodun derlenmesi sonucu oluşur ve makinelerin, Ethereum Sanal Makinesi'nin anlayabileceği bir dildir. Gelin size basit bir sözleşmenin bytecode'unu göstereyim: 0x600a600c600039600a6000f3602a60805260206080f3. Bizim, Ethereum'da depolanan bytecode ile etkileşime websitelerde ve uygulamalarda geçebilmemiz için ABI'ye ihtiyaç duyuyoruz. ABI'de, sözleşmedeki metotları ve değişken tanımları hakkında bilgiler bulunur ve EVM'e bytecode'daki hangi kısımları kullanacağımızın bilgisi verilir. **Get New Instance** butonuna basarak sözleşme seviyesini yayımladıktan sonra tarayıcınızın konsoluna **contract.abi** yazarsanız Fallback sözleşmesinin ABI'sini görüntüleyebilirsiniz.

Evet, şimdi gelelim Fallback metotlarına. Eğer sözleşmeye gönderdiğiniz işlemde (transaction) kontrattaki herhangi bir fonksiyonu kullandığınızı belirten bir veri yoksa veya işleminiz veri barındırmıyorsa fallback metodumuz devreye girer. Fallback metotları **external** ve **payable** olarak belirtilmelidir. Sözleşmemizde fallback metotlarını belirtmenin birden fazla yolları var.

Bu yollardan bir tanesi ve Ethernaut sözleşmemizde de kullanılan **receive() external payable** ifadesidir. Sözleşmemizin yazıldığı ve derlendiği Solidity v0.6.0'e göre bahsi geçen fallback metodu, sözleşmeye gönderdiğimiz işlemde herhangi bir veri (call data) yoksa çağrılır. Call data sözleşmeden çağırmak istediğimiz metotun verisidir. Call data'nın olmaması ise şu demek: MetaMask'ı açıp Send butonuna basarsanız ve sözleşme adresine bir miktar Ether gönderdiğiniz zaman basit bir transfer işlemi gerçekleşir. Bu transfer işleminde call data bulunmaz, işte burada receive metodu devreye giriyor.

Diğer yol ise **fallback() external [payable]** ifadesidir. Eğer sözleşmeye gönderdiğiniz işlem call data'sında sözleşmede bulunmayan bir metoda ait veriler bulunuyorsa fallback metodu devreye giriyor. Payable kısmı opsiyoneldir.

Ethernaut sözleşmesindeki zaafiyeti tespit etmek için gerekli bilgileri öğrendiğimize göre saldırıya başlayabiliriz!

Fallback sözleşmemiz bir bağış fonuna benzemekte fakat oldukça sorunlu bir sözleşme. Bir mapping veri yapısı içerisinde bu fona katkı sağlayanlar depolanıyor. Sözleşmenin sahibi olmak için mevcut sözleşme sahibinden daha fazla fon yatırmak gerekiyor, bunu **contribute()** metodunda görebilirsiniz. Yatırmamız gereken miktar ise 1000 Ether, bunu da constructor metodunda görebilirsiniz; sözleşme oluşturulurken constructor metodu devreye giriyor ve sözleşmeyi oluşturan adresin bakiyesine 1000 birim ekleniyor. Rinkeby Testnet faucet'ten 1000 Ether alamayacağımıza göre başka bir yol denemeliyiz. Evet, bildiniz fallback metotları!

Sözleşmemizdeki fallback metotu receive() metodu. Require kısmındaki gerekli koşulları sağladığımız zaman işlemi gönderen kişi (msg.sender) sözleşme sahibi oluyor. Require kısmındaki koşullardan bir tanesi fona katkıda bulunmaz, yani contribute() metodunu çağırmamız lazım. Gelin bu metodu konsoldan nasıl çağıracağımızı öğrenelim.

"contract" ifadesini kullandığımız zaman sözleşme objesine erişiyoruz ve bunu kullanarak sözleşmede bulunan metotları çağırabiliriz. Gelin öncelikle adresimizin mapping'te depolanmasını sağlayalım ki sonradan fallback metodundaki require'da bulunan koşulu sağlayabilelim. Tarayıcı konsolunuza aşağıdaki kodu yazarak saldırıya başlayabiliriz!

    await contract.contribute({value: toWei("0.0001")});
toWei metotu içine yazdığınız Ether değerini wei birimine çeviriyor. Eğer payable metotlarını çağırmak istiyorsanız wei ile işlem yapmalısınız. Contribute metodundaki require koşullarından birisi 0.001 Ether'den daha düşük bir miktar göndermekti, bu yüzden 0.0001 Ether göndermeyi tercih ettim. Evet, şimdi kendimizi sözleşme sahibi yapma zamanı!

    await contract.sendTransaction({value: toWei("0.0001")});

Fallback metodundaki koşullardan ikincisini sağladık, diğeri ise sözleşmeye 0'dan fazla herhangi bir miktarda Ether göndermemizdi. Ve böylece yeni sözleşme sahibi biziz! Şimdi ise hasılatı toplama zamanı, yani fondaki Etherleri kendimize aktaralım.
    await contract.withdraw();
Yazdığımız kodların sağlamasını yapmak için konsola şunu yazabilirsiniz:

    await contract.owner();

Yukarıdaki kod sözleşmenin sahibini gösteriyor. Kendi adresinizi göremiyorsanız kodları doğru yazdığınızdan emin olun.

Kontratın sahibi olduğumuza göre şimdi kontrattaki Ether'leri çekebilme yetkisine sahibiz. Hadi Etherlerimizi çekelim ve seviyeyi tamamlayalım!

    await contract.withdraw();

Bütün bunları yaptıktan sonra **Submit Instance** butonuna basıp seviyeyi geçtiğimizi Ethernaut sözleşmesine bildirelim. Seviyeyi geçmeniz halinde konsolda ışıklı bir tebrik mesajını görmek için konsolu açık tutmanızı tavsiye ederim. Bir sonraki seviyede görüşmek üzere!
