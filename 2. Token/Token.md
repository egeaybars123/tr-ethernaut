# Token
Ethernaut'un beşinci seviyesi olan Token sözleşmesiyle devam edelim. Bu seviyenin içeriğine erişmek için [buraya](https://ethernaut.openzeppelin.com/level/0x63bE8347A617476CA461649897238A31835a32CE) tıklayabilirsiniz.

Eğer ilk çözdüğümüz seviyeyi hatırlıyorsanız, OpenZeppelin'in SafeMath kütüphanesinin kullanıldığının görmüşsünüzdür. Solidity'de dört işlem yapabildiğimiz halde neden bir dört işlem kütüphanesini kullanalım, ne gerek var? İşte bu seviyede Solidity'de akıllı sözleşme yazarken dört işlem kullanmanın yaratabileceği zaafiyetleri ve SafeMath kütüphanesinin önemini öğreneceğiz. Başlamadan önce bir noktadan bahsetmek istiyorum. Bu Ethernaut seviyesi Solidity v0.6.0'a göre yazılmış ve derlenmiş (compiled). Bu seviyedeki zaafiyet Solidity v0.8.0'e göre bir sorun yaşamadan revert (iptal) ediliyor ve güvenlik sorunu yaşanmıyor. 0.8.0 versiyonundan düşük versiyonlar kullanıyorsanız bu seviye, sözleşmenizin güvenliği için önemli olabilir. O zaman hadi başlayalım!

Seviyeyi tamamlamak için başlangıçta sözleşmede bize verilen 20 tokenlik bakiyemizi arttırmak, tercihen çok yüksek miktarda arttırabiliriz. Peki, bunu nasıl başarabiliriz? Gelin sözleşmeyi inceleyim!

Token sözleşmesi basit bir token sözleşmesi; yani her adresin bakiyesi bulunur ve bakiyeleri kadar başka adreslere transfer yapabilirler. **Get New Instance** butonuna basıp sözleşme seviyesini yayımlayalım (deploy). Bakiyemizi kontrol etmek için şu kodu yazabiliriz:

    await contract.balanceOf(player);

Player değişkeni Ethernaut websitesine MetaMask aracılığıyla bağladığımız Ethereum adresimiz. Gelen çıktıdaki words anahtarına tıklarsanız sıfırıncı indexte 20 sayısını göreceksiniz. Evet, 20 tokenimiz varmış ve biz elimizdeki token sayısını nasıl arttırabiliriz? Gelin transfer() metodunu inceleyelim.

Transfer metodunda tokenlerimizi göndermek istediğimiz adresi ve miktarı parametre olarak sağlıyoruz. Metodun ilk satırında bakiyemiz kadar transfer yapıp yapmadığımızın kontrolü yapılıyor fakat yapılan çıkarma işleminde SafeMath kütüphanesi kullanılmıyor. Gelin bakalım buradaki zaafiyet neymiş öğrenelim!

Solidity uint256 veri yapılarında en yüksek sayı 2^(256)-1'dir. Uint yapılarında negatif sayılar da kullanılamadığı için en küçük sayı 0'dır. 0 sayısından 1 çıkardığımızda en düşük desteklenen değerden daha küçük bir değeri kullanmaya çalıştığımız için **integer underflow** olayı gerçekleşir ve 0-1 işleminin sonucu 2^(256) -1 oluyor, yani desteklenen en yüksek değer. Eğer
2^(256) -1 + 1 işlemini yapsaydık, sonucumuz 0 çıkacaktı çünkü daha yüksek bir değer desteklenmiyor, buna da **integer overflow** diyoruz.

Bu durumu kilometre sayacına benzetebiliriz. Maksimum 5 haneli bir kilometre sayacımız var diyelim. 99999 km yol yaptık ve sonrasında ne olur sizce? Sayacımız 100 bininci km'i gösteremez ve sayaç sıfırlanır. Bunu anladıysak gelin bu zaafiyetten yararlanarak elimizdeki token sayısını arttıralım.

Elimizdeki token sayısı 20 olduğu için göndermek istediğimiz değerin 21 olduğunuzu belirterek transfer metodunu çağırırsak **integer underflow** gerçekleşir. Transfer metodunun ikinci satırında bakiyemiz **20-21** olarak gerçekleşir, yani yeni bakiyemiz 2^(256)- 1 olur. Göndermek istediğiniz adresi ise MetaMask cüzdanınızda ikinci bir Ethereum adresi oluşturup o adrese gönderebilirsiniz. Gelin konsolumuza bu kodu yazalım:

    await contract.transfer("ikinci adres", 21);

Böylelikle Token bakiyemizi arttırmış oluyoruz. Eğer Solidity v0.8.0'dan düşük bir versiyon kullanıyorsanız, integer underflow ve overflow konseptlerinin yaratabileceği zaafiyetlere mutlaka dikkat edin. SafeMath kütüphanesini kullanarak bu zaafiyetlerin önüne geçebilirsiniz. **Submit New Instance** butonuna tıklayarak seviyemizin kontrol edilmesi için sunalım ve konsoldaki tebrik mesajının da keyfini çıkaralım! Bir sonraki seviyede görüşmek üzere, sağlıcakla kalın.


